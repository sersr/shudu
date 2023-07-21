// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

// ignore_for_file: prefer_const_constructors

class Routes {
  Routes._();

  static Routes? _instance;

  static Routes init({bool newInstance = false}) {
    if (!newInstance && _instance != null) {
      return _instance!;
    }
    final instance = _instance = Routes._();
    instance._init();
    return instance;
  }

  void _init() {
    __bookContentPage = NopRoute(
        name: '/bookContentPage',
        fullName: '/bookContentPage',
        builder: (context, arguments, group) => const BookContentPage());

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
        builder: (context, arguments, group) => const BookHistory());

    __booklistDetailPage = NopRoute(
        name: '/booklistDetailPage',
        fullName: '/booklistDetailPage',
        builder: (context, arguments, group) => BooklistDetailPage(
            total: arguments['total'], index: arguments['index']));

    __booklistPage = NopRoute(
        name: '/booklistPage',
        fullName: '/booklistPage',
        builder: (context, arguments, group) => const BooklistPage());

    __cacheManager = NopRoute(
        name: '/cacheManager',
        fullName: '/cacheManager',
        builder: (context, arguments, group) => const CacheManager());

    __categegoryView = NopRoute(
        name: '/categegoryView',
        fullName: '/listCatetoryPage/categegoryView',
        builder: (context, arguments, group) =>
            CategegoryView(title: arguments['title'], ctg: arguments['ctg']));

    __listCatetoryPage = NopRoute(
        name: '/listCatetoryPage',
        fullName: '/listCatetoryPage',
        children: [__categegoryView],
        builder: (context, arguments, group) => const ListCatetoryPage());

    __setting = NopRoute(
        name: '/setting',
        fullName: '/setting',
        builder: (context, arguments, group) => const Setting());

    __topPage = NopRoute(
        name: '/topPage',
        fullName: '/topPage',
        builder: (context, arguments, group) => const TopPage());

    _root = NopRoute(
        name: '/',
        fullName: '/',
        children: [
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
        builder: (context, arguments, group) => const MyHomePage());
  }

  late final NopRoute __bookContentPage;
  static NopRoute get _bookContentPage => _instance!.__bookContentPage;
  late final NopRoute __bookInfoPage;
  static NopRoute get _bookInfoPage => _instance!.__bookInfoPage;
  late final NopRoute __bookHistory;
  static NopRoute get _bookHistory => _instance!.__bookHistory;
  late final NopRoute __booklistDetailPage;
  static NopRoute get _booklistDetailPage => _instance!.__booklistDetailPage;
  late final NopRoute __booklistPage;
  static NopRoute get _booklistPage => _instance!.__booklistPage;
  late final NopRoute __cacheManager;
  static NopRoute get _cacheManager => _instance!.__cacheManager;
  late final NopRoute __categegoryView;
  static NopRoute get _categegoryView => _instance!.__categegoryView;
  late final NopRoute __listCatetoryPage;
  static NopRoute get _listCatetoryPage => _instance!.__listCatetoryPage;
  late final NopRoute __setting;
  static NopRoute get _setting => _instance!.__setting;
  late final NopRoute __topPage;
  static NopRoute get _topPage => _instance!.__topPage;
  late final NopRoute _root;
  static NopRoute get root => _instance!._root;
}

class NavRoutes {
  NavRoutes._();
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

  static NopRouteAction<T> categegoryView<T>(
      {BuildContext? context, required String title, required int ctg}) {
    return NopRouteAction(
        context: context,
        route: Routes._categegoryView,
        arguments: {'title': title, 'ctg': ctg});
  }

  static NopRouteAction<T> listCatetoryPage<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes._listCatetoryPage, arguments: const {});
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

  static NopRouteAction<T> root<T>({
    BuildContext? context,
  }) {
    return NopRouteAction(
        context: context, route: Routes.root, arguments: const {});
  }
}
