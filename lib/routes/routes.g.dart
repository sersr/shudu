// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

// ignore_for_file: prefer_const_constructors

class Routes {
  Routes._();
  static final root = NopRoute(
    name: '/',
    fullName: '/',
    children: [
      _bookContentPage,
      _bookInfoPage,
      _bookHistory,
      _booklistDetailPage,
      _booklistPage,
      _cacheManager,
      _listCatetoryPage,
      _setting,
      _topPage
    ],
    builder: (context, arguments) => const Nop(
      child: MyHomePage(),
    ),
  );

  static final _bookContentPage = NopRoute(
    name: '/bookContentPage',
    fullName: '/bookContentPage',
    builder: (context, arguments) => const Nop(
      child: BookContentPage(),
    ),
  );

  static final _bookInfoPage = NopRoute(
    name: '/bookInfoPage',
    fullName: '/bookInfoPage',
    builder: (context, arguments) => Nop(
      builders: const [ShuduRoute._builder],
      child: BookInfoPage(id: arguments['id'], api: arguments['api']),
    ),
  );

  static final _bookHistory = NopRoute(
    name: '/bookHistory',
    fullName: '/bookHistory',
    builder: (context, arguments) => const Nop(
      child: BookHistory(),
    ),
  );

  static final _booklistDetailPage = NopRoute(
    name: '/booklistDetailPage',
    fullName: '/booklistDetailPage',
    builder: (context, arguments) => Nop(
      child: BooklistDetailPage(
          total: arguments['total'], index: arguments['index']),
    ),
  );

  static final _booklistPage = NopRoute(
    name: '/booklistPage',
    fullName: '/booklistPage',
    builder: (context, arguments) => const Nop(
      child: BooklistPage(),
    ),
  );

  static final _cacheManager = NopRoute(
    name: '/cacheManager',
    fullName: '/cacheManager',
    builder: (context, arguments) => const Nop(
      child: CacheManager(),
    ),
  );

  static final _listCatetoryPage = NopRoute(
    name: '/listCatetoryPage',
    fullName: '/listCatetoryPage',
    children: [_categegoryView],
    builder: (context, arguments) => const Nop(
      child: ListCatetoryPage(),
    ),
  );

  static final _categegoryView = NopRoute(
    name: '/categegoryView',
    fullName: '/listCatetoryPage/categegoryView',
    builder: (context, arguments) => Nop(
      child: CategegoryView(title: arguments['title'], ctg: arguments['ctg']),
    ),
  );

  static final _setting = NopRoute(
    name: '/setting',
    fullName: '/setting',
    builder: (context, arguments) => const Nop(
      child: Setting(),
    ),
  );

  static final _topPage = NopRoute(
    name: '/topPage',
    fullName: '/topPage',
    builder: (context, arguments) => const Nop(
      child: TopPage(),
    ),
  );
}

class NavRoutes {
  NavRoutes._();
  static NopRouteAction<T> root<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes.root, arguments: const {});
  }

  static NopRouteAction<T> bookContentPage<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._bookContentPage, arguments: const {});
  }

  static NopRouteAction<T> bookInfoPage<T>(
      {BuildContext? context, required int id, required ApiType api}) {
    return NopRouteAction(
        context: context,
        route: Routes._bookInfoPage,
        arguments: {'id': id, 'api': api});
  }

  static NopRouteAction<T> bookHistory<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._bookHistory, arguments: const {});
  }

  static NopRouteAction<T> booklistDetailPage<T>(
      {BuildContext? context, int? total, int? index}) {
    return NopRouteAction(
        context: context,
        route: Routes._booklistDetailPage,
        arguments: {'total': total, 'index': index});
  }

  static NopRouteAction<T> booklistPage<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._booklistPage, arguments: const {});
  }

  static NopRouteAction<T> cacheManager<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._cacheManager, arguments: const {});
  }

  static NopRouteAction<T> listCatetoryPage<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._listCatetoryPage, arguments: const {});
  }

  static NopRouteAction<T> categegoryView<T>(
      {BuildContext? context, required String title, required int ctg}) {
    return NopRouteAction(
        context: context,
        route: Routes._categegoryView,
        arguments: {'title': title, 'ctg': ctg});
  }

  static NopRouteAction<T> setting<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._setting, arguments: const {});
  }

  static NopRouteAction<T> topPage<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._topPage, arguments: const {});
  }
}
