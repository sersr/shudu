import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import '../../widgets/page_animation.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../event/event.dart';
import '../../provider/provider.dart';

import '../../widgets/images.dart';
import '../book_info/info_page.dart';
import 'booklist.dart';
import 'top_custom_item.dart';

class ListCatetoryPage extends StatefulWidget {
  @override
  _ListCatetoryPageState createState() => _ListCatetoryPageState();
}

class _ListCatetoryPageState extends State<ListCatetoryPage>
    with PageAnimationMixin {
  final _category = CategoryListNotifier();
  late TextStyleConfig ts;

  @override
  void initState() {
    super.initState();
    addListener(complete);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    ts = context.read<TextStyleConfig>();

    _category.repository = repository;
  }

  void complete() {
    _category.getCategories();
    removeListener(complete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('分类'),
          centerTitle: true,
          // backgroundColor: Colors.white,
          elevation: 1.0,
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
                        // child: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        child: btn1(
                          onTap: () {
                            final name = e.name;
                            final id = e.id;
                            if (name != null && id != null) {
                              final _index = int.tryParse(id);
                              if (_index != null)
                                CategegoryView.push(context, name, _index);
                            }
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
                        //   ],
                        // ),
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
                  index: index,
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
    required this.index,
  }) : super(key: key);
  final int ctg;
  final String date;
  final int index;
  @override
  _CategListViewState createState() => _CategListViewState();
}

class _CategListViewState extends State<CategListView>
    with AutomaticKeepAliveClientMixin {
  final _categNotifier = TopNotifier();
  TabController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    _categNotifier.repository = repository;

    controller?.removeListener(onUpdate);
    controller = DefaultTabController.of(context);
    controller?.addListener(onUpdate);

    onUpdate();
  }

  void onUpdate() {
    if (widget.index == controller?.index && !_categNotifier.initialized)
      _categNotifier.getNextData(widget.ctg, widget.date);
  }

  @override
  void didUpdateWidget(covariant CategListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ctg != widget.ctg || oldWidget.date != widget.date) {
      _categNotifier.reset();
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
    super.build(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
          animation: _categNotifier,
          builder: (context, _) {
            final _data = _categNotifier.data;
            if (!_categNotifier.initialized) {
              if (!_categNotifier.failed)
                return loadingIndicator();
              else
                return reloadBotton(
                    () => _categNotifier.getNextData(widget.ctg, widget.date));
            }

            return ListViewBuilder(
              cacheExtent: 100,
              itemCount: _data.length + 1,
              finishLayout: (first, last) {
                final length = _data.length;
                if (length == last) {
                  if (!_categNotifier.loading && _categNotifier._hasNext) {
                    _categNotifier.getNextData(widget.ctg, widget.date);
                  }
                }
              },
              itemBuilder: (context, index) {
                if (index == _data.length) {
                  if (!_categNotifier._hasNext)
                    return Container(
                        height: 50, child: Center(child: Text('到底了~')));
                  return Container(height: 50, child: loadingIndicator());
                }
                final _item = _data[index];
                return ListItem(
                  onTap: () => _item.id != null
                      ? BookInfoPage.push(context, _item.id!)
                      : null,
                  child: TopCustomItem(item: _item),
                );
              },
            );
          }),
    );
    // );
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
  bool get loading => _task != null;
  bool get failed => _failed;
  bool get initialized => _index != 0;

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
    if (isCurrentItem(ctg, date) && _index == index) {
      _hasNext = _da.hasNext ?? true;
      if (_da.bookList != null) {
        _data.addAll(_da.bookList!);
      } else {
        Log.e('failed');
        _index--;
        _failed = true;
      }
      await release(const Duration(milliseconds: 500));
    }
  }

  @override
  void notifyListeners() {
    scheduleMicrotask(super.notifyListeners);
  }

  void reset() {
    _ctg = _date = null;
    _index = 0;
    _hasNext = true;
    _data.clear();
  }

  bool isCurrentItem(int ctg, String date) => ctg == _ctg && date == _date;
}
