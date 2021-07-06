import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../provider/provider.dart' show TextStyleConfig;
import '../../data/data.dart' show BookTopData, BookTopList;
import '../../event/event.dart' show Repository;
import '../../utils/utils.dart' show Log, btn1, loadingIndicator, reloadBotton;
import '../../utils/widget/page_animation.dart' show PageAnimationMixin;
import '../../widgets/async_text.dart';
import '../book_info_view/book_info_page.dart' show BookInfoPage;
import '../embed/images.dart' show ImageResolve;
import 'list_shudan_detail.dart';

class BookListItem extends StatelessWidget {
  const BookListItem({Key? key, required this.item}) : super(key: key);
  final BookTopList item;

  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TextStyleConfig>(context);

    final img = item.img;
    final name = item.name;
    final cname = item.cname;
    final author = item.author;
    final desc = item.desc;
    final score = item.score;
    return Container(
      height: 112,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 112,
            child: ImageResolve(img: img),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
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
                                    text: '$cname | $author', style: ts.body2),
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
                          return CustomMultiChildLayout(
                            delegate: ItemDetailWidget(112),
                            children: [
                              LayoutId(
                                  id: 'top', child: AsyncText.async(data[0])),
                              LayoutId(
                                  id: 'topRight',
                                  child: AsyncText.async(data[1])),
                              LayoutId(
                                  id: 'center',
                                  child: AsyncText.async(data[2])),
                              LayoutId(
                                  id: 'bottom',
                                  child: AsyncText.async(data[3])),
                            ],
                          );
                        }
                        return SizedBox();
                      });
                },
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
    final size = MediaQuery.of(context).size;
    return NotificationListener(
      onNotification: (no) {
        if (no is OverscrollIndicatorNotification) {
          Log.w('$no OverscrollIndicatorNotification');
          if (!no.leading) _topNotifier.getNextData(widget.ctg, widget.date);
          // } else if (no is OverscrollNotification) {
          //   if (no.overscroll > 0) {
          //     _topNotifier.getNextData(widget.ctg, widget.date);
          //   }
        } else if (no is UserScrollNotification) {
          final mcs = no.metrics;
          if (mcs.pixels >= mcs.maxScrollExtent - size.height / 10 &&
              _topNotifier._task == null) {
            _topNotifier.getNextData(widget.ctg, widget.date);
          }
        }
        return false;
      },
      child: AnimatedBuilder(
          animation: _topNotifier,
          builder: (context, _) {
            final _data = _topNotifier.data;
            if (!_topNotifier._failed && _topNotifier._index == 0)
              return loadingIndicator(radius: 30);
            else if (_topNotifier._failed) {
              return reloadBotton(() {
                _topNotifier.getNextData(widget.ctg, widget.date);
              });
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                if (index == _data.length) {
                  if (!_topNotifier._hasNext)
                    return Container(
                        height: 50, child: Center(child: Text('到底了~')));
                  return Container(height: 50, child: loadingIndicator());
                }
                final _item = _data[index];
                return btn1(
                    onTap: () {
                      if (_item.id != null)
                        BookInfoPage.push(context, _item.id!);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(255, 230, 230, 230),
                                  width: 1))),
                      child: BookListItem(item: _item),
                    ));
              },
              itemCount: _data.length + 1,
            );
          }),
    );
  }
}

class TopNotifier extends ChangeNotifier {
  Repository? repository;
  final _data = <BookTopList>[];
  List<BookTopList> get data => _data;
  String? _ctg, _date;
  int _index = 0;
  bool _hasNext = true;
  bool _failed = false;

  Future? _task;
  Future<void> getNextData(String ctg, String date) async {
    if (_task != null) return;
    await _task;
    _task ??= _getNextData(ctg, date)..whenComplete(() => _task = null);
  }

  Future<void> _getNextData(String ctg, String date) async {
    if (!isCurrentItem(ctg, date)) {
      _ctg = ctg;
      _date = date;
      _index = 0;
      _hasNext = true;
      _data.clear();
    }
    if (!_hasNext) {
      notifyListeners();
      return;
    }
    if (_failed) notifyListeners();

    _failed = false;
    _index++;
    await getData(ctg, date, _index);
  }

  Future<void> getData(String ctg, String date, int index) async {
    final _da =
        await repository!.bookEvent.customEvent.getTopLists(ctg, date, index) ??
            const BookTopData();
    _hasNext = _da.hasNext ?? true;
    if (_da.bookList != null) {
      _data.addAll(_da.bookList!);
    } else {
      Log.e('failed');
      _index--;
      _failed = true;
    }
    notifyListeners();
  }

  void reset() {
    _ctg = _date = null;
    _index = 0;
    _hasNext = true;
    _data.clear();
  }

  bool isCurrentItem(String ctg, String date) => ctg == _ctg && date == _date;
}
