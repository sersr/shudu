import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../data/data.dart' show BookTopData, BookTopList;
import '../../event/event.dart' show Repository;
import '../../provider/provider.dart' show TextStyleConfig;
import '../../utils/utils.dart'
    show Log, loadingIndicator, release, reloadBotton;
import '../../utils/widget/page_animation.dart' show PageAnimationMixin;
import '../../widgets/async_text.dart';
import '../../widgets/image_text.dart';
import '../book_info_view/book_info_page.dart' show BookInfoPage;
import '../embed/images.dart' show ImageResolve;
import '../embed/list_builder.dart';
import 'list_shudan.dart';
import 'list_shudan_detail.dart';

class BookListItem extends StatelessWidget {
  const BookListItem({Key? key, required this.item}) : super(key: key);
  final BookTopList item;

  @override
  Widget build(BuildContext context) {
    final ts = context.read<TextStyleConfig>();

    final img = item.img;
    final name = item.name;
    final cname = item.cname;
    final author = item.author;
    final desc = item.desc;
    final score = item.score;
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ImageResolve(img: img),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final topRight = AsyncText.asyncLayout(
                        constraints.maxWidth,
                        TextPainter(
                            text: TextSpan(
                              text: '$score分',
                              style: ts.body2
                                  .copyWith(color: Colors.yellow.shade700),
                            ),
                            maxLines: 1,
                            textDirection: TextDirection.ltr));

                    return FutureBuilder<List<TextPainter>>(
                        future: Future.wait<TextPainter>([
                          topRight.then((value) => AsyncText.asyncLayout(
                              constraints.maxWidth - value.width,
                              TextPainter(
                                  text: TextSpan(text: name!, style: ts.title3),
                                  maxLines: 1,
                                  textDirection: TextDirection.ltr))),
                          topRight,
                          AsyncText.asyncLayout(
                              constraints.maxWidth,
                              TextPainter(
                                  text: TextSpan(
                                      text: '$cname | $author',
                                      style: ts.body2),
                                  maxLines: 1,
                                  textDirection: TextDirection.ltr)),
                          AsyncText.asyncLayout(
                              constraints.maxWidth,
                              TextPainter(
                                  text: TextSpan(text: desc!, style: ts.body3),
                                  maxLines: 2,
                                  textDirection: TextDirection.ltr)),
                        ]),
                        builder: (context, snap) {
                          if (snap.hasData) {
                            final data = snap.data!;
                            return ItemWidget(
                                top: AsyncText.async(data[0]),
                                topRight: AsyncText.async(data[1]),
                                center: AsyncText.async(data[2]),
                                bottom: AsyncText.async(data[3]));
                          }
                          return SizedBox();
                        });
                  },
                ),
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
    required this.ctg,
    required this.date,
  }) : super(key: key);
  final String ctg;
  final String date;
  @override
  _TopListViewState createState() => _TopListViewState();
}

class _TopListViewState extends State<TopListView> with PageAnimationMixin {
  final _topNotifier = TopNotifier();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    _topNotifier.repository = repository;
  }

  @override
  void didUpdateWidget(covariant TopListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _topNotifier.reset();
    complete();
  }

  @override
  void complete() {
    final _f = () {
      _topNotifier.getNextData(widget.ctg, widget.date);
    };
    if (widget.date != 'week') {
      Future.delayed(const Duration(milliseconds: 300), _f);
    } else
      _f();
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
            itemBuilder: (context, index) {
              if (index == _data.length) {
                final state = _topNotifier.state;
                if (!_topNotifier._hasNext)
                  return Container(
                      height: 50, child: Center(child: Text('到底了~')));

                var child = loadingIndicator();

                if (state == LoadingStatus.error ||
                    state == LoadingStatus.failed) {
                  child = reloadBotton(
                      () => _topNotifier.getNextData(widget.ctg, widget.date));
                } else if (state != LoadingStatus.loading) {
                  _topNotifier.getNextData(widget.ctg, widget.date);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: child,
                );
              }

              final _item = _data[index];
              return ListItemBuilder(
                  onTap: () {
                    if (_item.id != null) BookInfoPage.push(context, _item.id!);
                  },
                  child: BookListItem(item: _item));
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

  List<BookTopList>? _data;
  List<BookTopList> get data => _data ?? const <BookTopList>[];
  String? _ctg, _date;
  int _index = 0;
  bool _hasNext = true;
  bool get initialized => _data != null;
  LoadingStatus state = LoadingStatus.failed;
  Future? _task;
  Future<void> getNextData(String ctg, String date) async {
    if (_task != null) return;
    _task ??= _getNextData(ctg, date)..whenComplete(() => _task = null);
  }

  Future<void> _getNextData(String ctg, String date) async {
    if (!correct(ctg, date)) {
      reset();
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
    await getData(ctg, date, _index);

    if (state == LoadingStatus.failed) {
      _index--;
    }
    // TODO: 使用页面动画监听替代
    await release(const Duration(milliseconds: 300));
    notifyListeners();
  }

  Future<void> getData(String ctg, String date, int index) async {
    final _da =
        await repository!.bookEvent.customEvent.getTopLists(ctg, date, index);
    if (_da != null) {
      if (_da.bookList != null) {
        _hasNext = _da.hasNext ?? true;
        _data ??= <BookTopList>[];
        _data!.addAll(_da.bookList!);
        state = LoadingStatus.success;
      } else {
        state = LoadingStatus.failed;
      }
    } else {
      Log.e('failed');
      state = LoadingStatus.error;
    }
  }

  void reset() {
    _ctg = _date = null;
    _index = 0;
    _hasNext = true;
    state = LoadingStatus.failed;
    _data = null;
  }

  bool correct(String ctg, String date) => ctg == _ctg && date == _date;
}
