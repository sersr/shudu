import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:flutter_nop/router.dart';
import 'package:nop_annotations/nop_annotations.dart';

import '../api/api.dart';
import '../modules/book_content/views/book_content_page.dart';
import '../modules/book_info/views/info_page.dart';
import '../modules/book_list/views/book_history.dart';
import '../modules/book_list/views/booklist.dart';
import '../modules/book_list/views/booklist_detail.dart';
import '../modules/book_list/views/cache_manager.dart';
import '../modules/book_list/views/category.dart';
import '../modules/book_list/views/top.dart';
import '../modules/home/views/home_page.dart';
import '../modules/setting/views/setting.dart';

part 'routes.g.dart';

final router = Routes.router;

@RouterMain(
  page: MyHomePage,
  restorationId: 'main',
  pages: [
    RouterPage(page: BookContentPage),
    RouterPage(page: BookInfoPage),
    RouterPage(page: BookHistory),
    RouterPage(page: BooklistDetailPage),
    RouterPage(page: BooklistPage),
    RouterPage(page: CacheManager),
    RouterPage(
      page: ListCatetoryPage,
      pages: [
        RouterPage(page: CategegoryView),
      ],
    ),
    RouterPage(page: Setting),
    RouterPage(page: TopPage),
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
        notifier.select((parent) => local < parent.value - 3);
    return notifierSelector;
  }

  @RouteBuilderItem(pages: [BookInfoPage])
  static Widget _builder(Widget child) {
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
