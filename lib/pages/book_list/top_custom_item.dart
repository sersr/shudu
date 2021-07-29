import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart' show BookTopList;
import '../../event/event.dart' show Repository;
import '../../widgets/image_text.dart';
import '../../widgets/text_builder.dart';
import '../book_info/info_page.dart' show BookInfoPage;
import '../../widgets/images.dart' show ImageResolve;
import 'booklist.dart';

class TopCustomItem extends StatelessWidget {
  const TopCustomItem({Key? key, required this.item}) : super(key: key);
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

class TopListView extends StatefulWidget {
  const TopListView({
    Key? key,
    required this.index,
    required this.ctg,
    required this.date,
  }) : super(key: key);
  final String ctg;
  final String date;
  final int index;
  @override
  _TopListViewState createState() => _TopListViewState();
}

class _TopListViewState extends State<TopListView> {
  var _topNotifier = TopNotifier();

  @override
  void initState() {
    super.initState();
  }

  TabController? controller;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    _topNotifier.repository = repository;
    controller?.removeListener(onUpdate);
    controller = DefaultTabController.of(context);
    controller?.addListener(onUpdate);
    onUpdate();
  }

  void onUpdate() {
    if (controller?.index == widget.index) {
      if (!_topNotifier.initialized)
        _topNotifier.getNextData(widget.ctg, widget.date);
    }
  }

  @override
  void didUpdateWidget(covariant TopListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ctg != widget.ctg || oldWidget.date != widget.date) {
      _topNotifier = _topNotifier.copy();
      onUpdate();
    }
  }

  @override
  void dispose() {
    controller?.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _topNotifier,
        builder: (context, _) {
          final _data = _topNotifier.data;
          if (!_topNotifier.initialized)
            return loadingIndicator(radius: 30);
          else if (_data.isEmpty) {
            return reloadBotton(() {
              _topNotifier.getNextData(widget.ctg, widget.date);
            });
          }

          return ListViewBuilder(
            cacheExtent: 100,
            finishLayout: (first, last) {
              final state = _topNotifier.state;

              if (last == _data.length) {
                if (state == LoadingStatus.success && _topNotifier._hasNext) {
                  _topNotifier.getNextData(widget.ctg, widget.date);
                }
              }
            },
            itemBuilder: (context, index) {
              if (index == _data.length) {
                final state = _topNotifier.state;
                if (!_topNotifier._hasNext)
                  return SizedBox(
                      height: 50, child: Center(child: Text('到底了~')));

                var child = loadingIndicator();

                if (state == LoadingStatus.error ||
                    state == LoadingStatus.failed) {
                  child = reloadBotton(
                      () => _topNotifier.getNextData(widget.ctg, widget.date));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: child,
                );
              }

              final _item = _data[index];
              return ListItem(
                  onTap: () {
                    if (_item.id != null) BookInfoPage.push(context, _item.id!);
                  },
                  child: TopCustomItem(item: _item));
            },
            itemCount: _data.length + 1,
          );
        }
        // ),
        );
  }
}

class TopNotifier extends ChangeNotifier {
  Repository? repository;

  TopNotifier copy() {
    return TopNotifier()..repository = repository;
  }

  List<BookTopList>? _data;
  List<BookTopList> get data => _data ?? const <BookTopList>[];
  String? _ctg, _date;
  int _index = 0;
  bool _hasNext = true;
  bool get initialized => _data != null;
  LoadingStatus state = LoadingStatus.initial;

  final _event = EventQueue();

  Future<void> getNextData(String ctg, String date) {
    return _event.addOneEventTask(() => _getNextData(ctg, date));
  }

  Future<void> _getNextData(String ctg, String date) async {
    if (!correct(ctg, date)) {
      _reset();
      _ctg = ctg;
      _date = date;
    }

    if (!_hasNext) {
      notifyListeners();
      return;
    }
    state = LoadingStatus.loading;
    notifyListeners();
    _index++;
    final _oldIndex = _index;
    final success = await getData(ctg, date, _index);

    if (_index == _oldIndex) {
      if (!success) _index--;
      // TODO: 使用页面动画监听替代
      await release(const Duration(milliseconds: 500));
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    scheduleMicrotask(super.notifyListeners);
  }

  Future<bool> getData(String ctg, String date, int index) async {
    final _da =
        await repository!.bookEvent.customEvent.getTopLists(ctg, date, index);
    // 状态已改变，无效
    if (correct(ctg, date) && _index == index) {
      if (_da != null) {
        if (_da.bookList != null) {
          _hasNext = _da.hasNext ?? true;
          _data ??= <BookTopList>[];
          _data!.addAll(_da.bookList!);
          state = LoadingStatus.success;
          return true;
        } else {
          state = LoadingStatus.failed;
        }
      } else {
        Log.e('failed');
        state = LoadingStatus.error;
      }
    }
    return false;
  }

  // 添加到异步队列
  // void reset(String ctg, String date) {
  //   _event.addEventTask(() {
  //     _reset();
  //     return _getNextData(ctg, date);
  //   });
  // }

  // 同步
  void _reset() {
    _ctg = _date = null;
    _index = 0;
    _hasNext = true;
    state = LoadingStatus.initial;
    _data = null;
  }

  bool correct(String ctg, String date) => ctg == _ctg && date == _date;
}
