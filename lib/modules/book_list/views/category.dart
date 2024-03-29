import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:flutter_nop/router.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../data/data.dart';
import '../../../event/export.dart';
import '../../../routes/routes.dart';
import '../../../widgets/images.dart';
import '../../../widgets/page_animation.dart';
import '../../text_style/text_style.dart';
import 'booklist.dart';
import '../widgets/top_item.dart';

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
    final repository = context.grass<Repository>();
    ts = context.grass<TextStyleConfig>().data;

    _category.repository = repository;
  }

  void complete() {
    _category.getCategories();
    removeListener(complete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('分类'), centerTitle: true, elevation: 1.0),
      body: Center(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: disallowGlow,
          child: AnimatedBuilder(
            animation: _category,
            builder: (context, _) {
              final data = _category.data;
              if (data == null) {
                return loadingIndicator();
              } else if (data.isEmpty) {
                return reloadBotton(_category.getCategories);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = data[index];

                    return Center(
                      child: btn1(
                        radius: 6,
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          final name = item.name;
                          final id = item.id;
                          if (name != null && id != null) {
                            final _index = int.tryParse(id);
                            if (_index != null)
                              CategegoryView.push(context, name, _index);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: ImageResolve(img: item.image)),
                            const SizedBox(height: 4),
                            Text(item.name ?? '', style: ts.title2),
                          ],
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 124,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 0,
                    crossAxisCount: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool disallowGlow(notification) {
    notification.disallowGlow();
    return false;
  }
}

class CategoryListNotifier extends ChangeNotifierBase {
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
    final entry = NavRoutes.categegoryView(title: title, ctg: ctg);
    return entry.go().popped;
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
    var body = TabBarView(
      children: List.generate(
        _titles.length,
        (index) {
          return Green(
            create: (context) => TopNotifier<int>(
              context.grass<Repository>().getCategLists,
              widget.index,
              _urlKeys[index],
            ),
            child: TopCtgListView<int>(index: index),
          );
        },
      ),
    );

    return DefaultTabController(
      length: _titles.length,
      child: Scaffold(
        body: RepaintBoundary(
          child: BarLayout(
            title: Text(widget.title),
            body: body,
            bottom: TabBar(
              unselectedLabelColor: !context.isDarkMode
                  ? const Color.fromARGB(255, 204, 204, 204)
                  : const Color.fromARGB(255, 110, 110, 110),
              labelColor: const Color.fromARGB(255, 255, 255, 255),
              indicatorColor: const Color.fromARGB(255, 252, 137, 175),
              tabs: _titles.map(map).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget map(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(text),
    );
  }
}
