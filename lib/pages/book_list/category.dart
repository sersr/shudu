import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../event/export.dart';
import '../../provider/export.dart';
import '../../widgets/images.dart';
import '../../widgets/page_animation.dart';
import 'booklist.dart';
import 'top_item.dart';

class ListCatetoryPage extends StatefulWidget {
  const ListCatetoryPage({Key? key}) : super(key: key);

  @override
  _ListCatetoryPageState createState() => _ListCatetoryPageState();
}

class _ListCatetoryPageState extends State<ListCatetoryPage>
    with PageAnimationMixin {
  final _category = CategoryListNotifier();
  late TextStyleData ts;

  @override
  void initState() {
    super.initState();
    addListener(complete);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    ts = context.read<TextStyleConfig>().data;

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
                              Text(e.name ?? '', style: ts.title2),
                            ],
                          ),
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
  CategoryListNotifier();
  Repository? repository;
  List<BookCategoryData>? data;

  Future<void> getCategories() async {
    if (repository == null && data != null && data!.isNotEmpty) return;
    final _data = await repository!.customEvent.getCategoryData();
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
                (index) => ChangeNotifierProvider(
                  create: (context) => TopNotifier<int>(
                      context.read<Repository>().getCategLists,
                      widget.index,
                      _urlKeys[index]),
                  child: TopCtgListView<int>(index: index),
                ),
              ),
            ),
            bottom: TabBar(
              unselectedLabelColor: !context.isDarkMode
                  ? const Color.fromARGB(255, 204, 204, 204)
                  : const Color.fromARGB(255, 110, 110, 110),
              labelColor: const Color.fromARGB(255, 255, 255, 255),
              indicatorColor: const Color.fromARGB(255, 252, 137, 175),
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
