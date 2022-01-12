import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../pattern/pattern.dart';
import '../../provider/export.dart';
import '../../widgets/image_text.dart';
import '../book_info/info_page.dart';

/// [T]: context.read()使用
class TopCtgListView<T> extends StatefulWidget {
  const TopCtgListView({
    Key? key,
    required this.index,
  }) : super(key: key);
  final int index;
  @override
  _TopCtgListViewState<T> createState() => _TopCtgListViewState<T>();
}

class _TopCtgListViewState<T> extends State<TopCtgListView<T>>
    with AutomaticKeepAliveClientMixin {
  late TopNotifier<T> _categNotifier;
  TabController? controller;

  final scrollController = ScrollController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categNotifier = context.read();
    controller?.removeListener(onUpdate);
    controller = DefaultTabController.of(context);
    controller?.addListener(onUpdate);

    onUpdate();
  }

  void onUpdate() {
    if (widget.index == controller?.index && _categNotifier.dataResolve == null)
      _categNotifier.getNextData();
  }

  @override
  void dispose() {
    controller?.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: RepaintBoundary(
        child: AnimatedBuilder(
            animation: _categNotifier,
            builder: (context, _) {
              final data = _categNotifier.dataResolve;
              if (data == null) {
                return loadingIndicator();
              } else {
                return data.map((data) {
                  // 如果任务完成，数据没有加载进来，
                  // 加载指示器会显示在顶部而不是在屏幕中间
                  if (data.data?.isEmpty == true) {
                    return loadingIndicator();
                  }
                  return wrapWidget(data.data);
                }, loading: (data) {
                  return wrapWidget(data.data, loading: true);
                }, failed: (data) {
                  return wrapWidget(data.data, failed: true);
                }, done: (data) {
                  return wrapWidget(data.data, hasNext: false);
                });
              }
            }),
      ),
    );
  }

  Widget wrapWidget(List<BookTopList>? data,
      {bool loading = false, bool hasNext = true, bool failed = false}) {
    final _data = data;
    if (_data == null) {
      return reloadBotton(() => _categNotifier.getNextData());
    } else if (_data.isEmpty && loading) {
      return loadingIndicator();
    }
    return ListViewBuilder(
      scrollController: scrollController,
      cacheExtent: 100,
      color: !context.isDarkMode ?  const Color.fromRGBO(236, 236, 236, 1) : Color.fromRGBO(25, 25, 25, 1),
      itemCount: _data.length + 1,
      finishLayout: (first, end) {
        final length = _data.length;
        if (length == end) {
          if (!loading && hasNext) {
            _categNotifier.getNextData();
          }
        }
      },
      itemBuilder: (context, index) {
        if (index == _data.length) {
          if (!hasNext || failed)
            return SizedBox(
              height: 50,
              child: Center(child: failed ? Text('加载失败!') : Text('到底了~')),
            );
          return SizedBox(height: 50, child: loadingIndicator());
        }
        final item = _data[index];
        return ListItem(
          bgColor: !context.isDarkMode ? null : Colors.grey.shade900,
          splashColor:
              !context.isDarkMode ? null : Color.fromRGBO(60, 60, 60, 1),
          onTap: () {
            if (item.id != null) {
              BookInfoPage.push(item.id!, ApiType.biquge);
            }
          },
          child: ImageTextLayout(
            img: item.img,
            top: item.name,
            center: '${item.cname} | ${item.author}',
            topRightScore: '${item.score}分',
            bottom: item.desc,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

typedef CtgDataResolve = DataResolve<List<BookTopList>>;

class TopNotifier<T> extends ChangeNotifier {
  TopNotifier(this.getData, this.ctg, this.date);

  final FutureOr<BookTopData?> Function(
    T c,
    String date,
    int index,
  ) getData;
  final T ctg;
  final String date;

  Future<void> getNextData() => EventQueue.runOne(this, _getNextData);

  // 是数据，也是状态
  CtgDataResolve? dataResolve;

  FutureOr<void> _getNextData({CtgDataResolve? newDatResolve}) {
    dataResolve ??= CtgDataResolve([], 0);
    final useData = newDatResolve ?? dataResolve;

    final work = useData!.map(
        (data) async {
          final dataSource = data.data ?? [];
          final currentIndex = data.index;
          final nextIndex = currentIndex + 1;

          dataResolve = CtgDataResolve.loading(dataSource, nextIndex);
          notifyListeners();

          // 任务最小时长
          final wait = release(const Duration(milliseconds: 400));

          final _da =
              await getData(ctg, date, nextIndex) ?? const BookTopData();

          final bookList = _da.bookList;
          final hasNext = _da.hasNext;
          if (bookList != null) {
            // success
            dataSource.addAll(bookList);
            dataResolve = CtgDataResolve(dataSource, nextIndex);
          } else if (hasNext == false) {
            dataResolve = CtgDataResolve.done(dataSource, currentIndex);
          } else {
            dataResolve = CtgDataResolve.failed(dataSource, currentIndex);
          }
          await wait;
          notifyListeners();
        },
        loading: (_) {},
        failed: (data) {
          final newData = CtgDataResolve(data.data, data.index);
          // 不更改[dataResolve]，使用一个新的数据源进行模式匹配
          return _getNextData(newDatResolve: newData);
        },
        done: (data) {
          // final active = EventQueue.getQueueState(_doneReloadKey) ?? false;
          // if(active) {
          //   // reload
          //   final newData = DataResolve(data.data, data.index);
          //   return _getNextData(newDatResolve: newData);
          // }
          // EventQueue.runOne(_doneReloadKey,() => release(const Duration(milliseconds: 5000)));
        });
    return work;
  }

  // ignore: unused_field
  late final Object _doneReloadKey = Object();

  @override
  void notifyListeners() {
    if (_dispose) return;
    super.notifyListeners();
  }

  /// 不可再通知
  bool _dispose = false;
  @override
  void dispose() {
    _dispose = true;
    super.dispose();
  }
}
