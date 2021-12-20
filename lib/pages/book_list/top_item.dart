import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../pattern/pattern.dart';
import '../../provider/provider.dart';
import '../../widgets/image_text.dart';
import '../../widgets/images.dart' show ImageResolve;
import '../../widgets/images.dart';
import '../../widgets/text_builder.dart';
import '../book_info/info_page.dart';

class TopItem extends StatelessWidget {
  const TopItem({Key? key, required this.item}) : super(key: key);
  final BookTopList item;

  @override
  Widget build(BuildContext context) {
    final img = item.img;
    final name = item.name;
    final cname = item.cname;
    final author = item.author;
    final desc = item.desc;
    final topRightScore = '${item.score}分';
    final center = '$cname | $author';
    return Container(
      constraints: const BoxConstraints(maxHeight: 112, minHeight: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ImageResolve(img: img),
              ),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: TextAsyncLayout(
                    topRightScore: topRightScore,
                    top: name ?? '',
                    center: center,
                    bottom: desc ?? ''),
              ),
            ),
          )
        ],
      ),
    );
  }
}

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
    return RepaintBoundary(
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
      color: !context.isDarkMode ? null : Color.fromRGBO(25, 25, 25, 1),
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
        final _item = _data[index];
        return ListItem(
          bgColor: !context.isDarkMode ? null : Colors.grey.shade900,
          splashColor:
              !context.isDarkMode ? null : Color.fromRGBO(60, 60, 60, 1),
          onTap: () => _item.id != null
              ? BookInfoPage.push(context, _item.id!, ApiType.biquge)
              : null,
          child: TopItem(item: _item),
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

  Future<void> getNextData() =>
      EventQueue.runOneTaskOnQueue(this, _getNextData);

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
          if (bookList != null) { // success
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
          // EventQueue.runOneTaskOnQueue(_doneReloadKey,() => release(const Duration(milliseconds: 5000)));
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
