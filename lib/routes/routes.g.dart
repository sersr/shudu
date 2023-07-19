// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

// ignore_for_file: prefer_const_constructors

class Routes {
  Routes._() {
    _init();
  }

  static Routes? _instance;

  factory Routes({bool newInstance = false}) {
    if (!newInstance && _instance != null) {
      return _instance!;
    }
    return _instance = Routes._();
  }

  void _init() {
    _root = NopRoute(
      name: '/',
      fullName: '/',
      childrenLate: () => [
        __bookContentPage,
        __bookInfoPage,
        __bookHistory,
        __booklistDetailPage,
        __booklistPage,
        __cacheManager,
        __listCatetoryPage,
        __setting,
        __topPage
      ],
      builder: (context, arguments, group) => const Nop(
        child: MyHomePage(),
      ),
    );

    __bookContentPage = NopRoute(
      name: '/bookContentPage',
      fullName: '/bookContentPage',
      builder: (context, arguments, group) => const Nop(
        child: BookContentPage(),
      ),
    );

    __bookInfoPage = NopRoute(
      name: '/bookInfoPage',
      fullName: '/bookInfoPage',
      builder: (context, arguments, group) => Nop(
        builders: const [ShuduRoute._builder],
        child: BookInfoPage(id: arguments['id'], api: arguments['api']),
      ),
    );

    __bookHistory = NopRoute(
      name: '/bookHistory',
      fullName: '/bookHistory',
      builder: (context, arguments, group) => const Nop(
        child: BookHistory(),
      ),
    );

    __booklistDetailPage = NopRoute(
      name: '/booklistDetailPage',
      fullName: '/booklistDetailPage',
      builder: (context, arguments, group) => Nop(
        child: BooklistDetailPage(
            total: arguments['total'], index: arguments['index']),
      ),
    );

    __booklistPage = NopRoute(
      name: '/booklistPage',
      fullName: '/booklistPage',
      builder: (context, arguments, group) => const Nop(
        child: BooklistPage(),
      ),
    );

    __cacheManager = NopRoute(
      name: '/cacheManager',
      fullName: '/cacheManager',
      builder: (context, arguments, group) => const Nop(
        child: CacheManager(),
      ),
    );

    __listCatetoryPage = NopRoute(
      name: '/listCatetoryPage',
      fullName: '/listCatetoryPage',
      childrenLate: () => [__categegoryView],
      builder: (context, arguments, group) => const Nop(
        child: ListCatetoryPage(),
      ),
    );

    __categegoryView = NopRoute(
      name: '/categegoryView',
      fullName: '/listCatetoryPage/categegoryView',
      builder: (context, arguments, group) => Nop(
        child: CategegoryView(title: arguments['title'], ctg: arguments['ctg']),
      ),
    );

    __setting = NopRoute(
      name: '/setting',
      fullName: '/setting',
      builder: (context, arguments, group) => const Nop(
        child: Setting(),
      ),
    );

    __topPage = NopRoute(
      name: '/topPage',
      fullName: '/topPage',
      builder: (context, arguments, group) => const Nop(
        child: TopPage(),
      ),
    );
  }

  late final NopRoute _root;
  static NopRoute get root => Routes()._root;
  late final NopRoute __bookContentPage;
  static NopRoute get _bookContentPage => Routes().__bookContentPage;
  late final NopRoute __bookInfoPage;
  static NopRoute get _bookInfoPage => Routes().__bookInfoPage;
  late final NopRoute __bookHistory;
  static NopRoute get _bookHistory => Routes().__bookHistory;
  late final NopRoute __booklistDetailPage;
  static NopRoute get _booklistDetailPage => Routes().__booklistDetailPage;
  late final NopRoute __booklistPage;
  static NopRoute get _booklistPage => Routes().__booklistPage;
  late final NopRoute __cacheManager;
  static NopRoute get _cacheManager => Routes().__cacheManager;
  late final NopRoute __listCatetoryPage;
  static NopRoute get _listCatetoryPage => Routes().__listCatetoryPage;
  late final NopRoute __categegoryView;
  static NopRoute get _categegoryView => Routes().__categegoryView;
  late final NopRoute __setting;
  static NopRoute get _setting => Routes().__setting;
  late final NopRoute __topPage;
  static NopRoute get _topPage => Routes().__topPage;
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
