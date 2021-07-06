import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../provider/provider.dart';
import '../../data/data.dart';
import '../../event/event.dart';
import '../../utils/utils.dart';
import '../../utils/widget/page_animation.dart';
import '../book_info_view/book_info_page.dart';
import '../embed/images.dart';
import 'list_shudan.dart';
import 'top_view.dart';

class ListCatetoryPage extends StatefulWidget {
  @override
  _ListCatetoryPageState createState() => _ListCatetoryPageState();
}

class _ListCatetoryPageState extends State<ListCatetoryPage>
    with PageAnimationMixin {
  final _category = CategoryListNotifier();
  late TextStyleConfig ts;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    ts = context.read<TextStyleConfig>();

    _category.repository = repository;
  }

  @override
  void complete() => _category.getCategories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('分类'),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: disallowGlow,
            child: AnimatedBuilder(
              animation: _category,
              builder: (context, _) {
                final data = _category.data;
                if (data == null) {
                  return const CircularProgressIndicator();
                } else if (data.isEmpty) {
                  return reloadBotton(_category.getCategories);
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final e = data[index];
                      return Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            btn1(
                              onTap: () {
                                CategegoryView.push(context, e.name ?? '',
                                    int.tryParse(e.id ?? '') ?? index);
                              },
                              radius: 6,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(child: ImageResolve(img: e.image)),
                                  const SizedBox(height: 4),
                                  Text('${e.name}', style: ts.title2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent: 124,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 0,
                        crossAxisCount: 2),
                  ),
                );
              },
            ),
          ),
        ));
  }

  bool disallowGlow(notification) {
    notification.disallowGlow();
    return false;
  }
}

class CategoryListNotifier extends ChangeNotifier {
  Repository? repository;
  List<BookCategoryData>? data;

  Future<void> getCategories() async {
    if (repository == null && data != null && data!.isNotEmpty) return;
    final _data = await repository!.bookEvent.customEvent.getCategoryData();
    data = _data ?? const [];
    notifyListeners();
  }
}

class CategegoryView extends StatelessWidget {
  const CategegoryView({Key? key, required this.title, required this.ctg})
      : super(key: key);
  final String title;
  final int ctg;

  static Future push(context, String title, int ctg) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CategegoryView(title: title, ctg: ctg)));
  }

  @override
  Widget build(BuildContext context) {
    return Categories(index: ctg, title: title);
  }
}

class Categories extends StatefulWidget {
  const Categories({Key? key, required this.index, required this.title})
      : super(key: key);
  final int index;
  final String title;
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final _titles = <String>['最热', '最新', '评分', '完结'];
  final _urlKeys = <String>['hot', 'new', 'vote', 'over'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _titles.length,
      child: Scaffold(
        body: RepaintBoundary(
          child: BarLayout(
            title: Text(widget.title),
            body: TabBarView(
              children: List.generate(
                _titles.length,
                (index) => CategListView(
                  ctg: widget.index,
                  date: _urlKeys[index],
                ),
              ),
            ),
            bottom: TabBar(
              labelColor: TextStyleConfig.blackColor7,
              unselectedLabelColor: TextStyleConfig.blackColor2,
              tabs: _titles
                  .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class CategListView extends StatefulWidget {
  const CategListView({
    Key? key,
    required this.ctg,
    required this.date,
  }) : super(key: key);
  final int ctg;
  final String date;
  @override
  _CategListViewState createState() => _CategListViewState();
}

class _CategListViewState extends State<CategListView>
    with PageAnimationMixin, AutomaticKeepAliveClientMixin {
  final _categNotifier = TopNotifier();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    _categNotifier.repository = repository;
  }

  @override
  void didUpdateWidget(covariant CategListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _categNotifier.reset();
    complete();
  }

  @override
  void complete() {
    final _f = () {
      _categNotifier.getNextData(widget.ctg, widget.date);
    };
    if (widget.ctg != 0)
      Future.delayed(const Duration(milliseconds: 300), _f);
    else
      _f();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return NotificationListener(
      onNotification: (no) {
        if (no is OverscrollIndicatorNotification) {
          if (!no.leading) _categNotifier.getNextData(widget.ctg, widget.date);
        } else if (no is UserScrollNotification) {
          final mcs = no.metrics;
          if (mcs.pixels >= mcs.maxScrollExtent - size.height / 10 &&
              _categNotifier._task == null) {
            _categNotifier.getNextData(widget.ctg, widget.date);
          }
        }
        return false;
      },
      child: AnimatedBuilder(
          animation: _categNotifier,
          builder: (context, _) {
            final _data = _categNotifier.data;
            if (!_categNotifier._failed && _categNotifier._index == 0)
              return Center(child: CircularProgressIndicator());
            else if (_categNotifier._failed) {
              return Center(
                child: btn1(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  bgColor: Colors.blue,
                  splashColor: Colors.blue.shade200,
                  radius: 40,
                  child: Text(
                    '重新加载',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    _categNotifier.getNextData(widget.ctg, widget.date);
                  },
                ),
              );
            }

            return ListView.builder(
                itemBuilder: (context, index) {
                  if (index == _data.length) {
                    if (!_categNotifier._hasNext)
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
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300, width: 1))),
                        child: BookListItem(item: _item),
                      ));
                },
                itemCount: _data.length + 1);
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TopNotifier extends ChangeNotifier {
  Repository? repository;
  final _data = <BookTopList>[];
  List<BookTopList> get data => _data;
  int? _ctg;
  String? _date;
  int _index = 0;
  bool _hasNext = true;
  bool _failed = false;

  Future? _task;
  Future<void> getNextData(int ctg, String date) async {
    if (_task != null) return;

    await _task;
    _task ??= _getNextData(ctg, date)..whenComplete(() => _task = null);
  }

  Future<void> _getNextData(int ctg, String date) async {
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
    notifyListeners();
  }

  Future<void> getData(int ctg, String date, int index) async {
    final _da = await repository!.bookEvent.customEvent
            .getCategLists(ctg, date, index) ??
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

  bool isCurrentItem(int ctg, String date) => ctg == _ctg && date == _date;
}
