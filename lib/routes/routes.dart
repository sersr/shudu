import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nop/nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../pages/book_content/book_content_page.dart';
import '../pages/book_info/info_page.dart';
import '../pages/book_list/book_history.dart';
import '../pages/book_list/booklist.dart';
import '../pages/book_list/booklist_detail.dart';
import '../pages/book_list/cache_manager.dart';
import '../pages/book_list/category.dart';
import '../pages/book_list/top.dart';
import '../pages/home/home_page.dart';
import '../pages/setting/setting.dart';
import '../provider/export.dart';

part 'routes.g.dart';

@NopRouteMain(
  main: MyHomePage,
  pages: [
    RouteItem(page: BookContentPage),
    RouteItem(page: BookInfoPage),
    RouteItem(page: BookHistory),
    RouteItem(page: BooklistDetailPage),
    RouteItem(page: BooklistPage),
    RouteItem(page: CacheManager),
    RouteItem(
      page: ListCatetoryPage,
      pages: [
        RouteItem(page: CategegoryView),
      ],
    ),
    RouteItem(page: Setting),
    RouteItem(page: TopPage),
  ],
)
class ShuduRoute {
  ShuduRoute._(); // 智能提示中不显示构造器

  static final _notifierMap = <Object, ValueNotifier<int>>{};

  static ValueNotifier<int> get(Object key) =>
      _notifierMap.putIfAbsent(key, () => ValueNotifier(0));
  static void remove(Object key) => _notifierMap.remove(key);

  static ValueNotifier<int> get getInfo => get('info');
  static get removeInfo => _notifierMap.remove('info');

  static ValueListenable<bool> getNotifier(Object key) {
    final notifier = _notifierMap.putIfAbsent(key, () => ValueNotifier(0));
    final local = notifier.value;

    final notifierSelector =
        notifier.selector((parent) => local < parent.value - 3);
    return notifierSelector;
  }

  @RouteBuilderItem(pages: [BookInfoPage])
  static Widget _builder(BuildContext context, Widget child) {
    final listenable = getNotifier('info');
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, child) {
        return TickerMode(
          enabled: !listenable.value,
          child: Offstage(offstage: listenable.value, child: child),
        );
      },
      child: child,
    );
  }
}
