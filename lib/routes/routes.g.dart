// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouterGenerator
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
    __bookContentPage = NPage(
      path: 'bookContentPage',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: BookContentPage(),
          )),
    );

    __bookInfoPage = NPage(
      path: 'bookInfoPage',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: Nop.page(
            builders: const [ShuduRoute._builder],
            child:
                BookInfoPage(id: entry.params['id'], api: entry.params['api']),
          )),
    );

    __bookHistory = NPage(
      path: 'bookHistory',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: BookHistory(),
          )),
    );

    __booklistDetailPage = NPage(
      path: 'booklistDetailPage',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: Nop.page(
            child: BooklistDetailPage(
                total: entry.params['total'], index: entry.params['index']),
          )),
    );

    __booklistPage = NPage(
      path: 'booklistPage',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: BooklistPage(),
          )),
    );

    __cacheManager = NPage(
      path: 'cacheManager',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: CacheManager(),
          )),
    );

    __categegoryView = NPage(
      path: 'categegoryView',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: Nop.page(
            child: CategegoryView(
                title: entry.params['title'], ctg: entry.params['ctg']),
          )),
    );

    __listCatetoryPage = NPage(
      pages: [__categegoryView],
      path: 'listCatetoryPage',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: ListCatetoryPage(),
          )),
    );

    __setting = NPage(
      path: 'setting',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: Setting(),
          )),
    );

    __topPage = NPage(
      path: 'topPage',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: TopPage(),
          )),
    );

    _myHomePage = NPageMain(
      pages: [
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
      path: '/',
      pageBuilder: (entry) => MaterialIgnorePage(
          key: entry.pageKey,
          child: const Nop.page(
            child: MyHomePage(),
          )),
    );
  }

  static NRouter get router => Routes()._router;
  late final NRouter _router = NRouter(rootPage: myHomePage);
  late final NPage __bookContentPage;
  static NPage get _bookContentPage => Routes().__bookContentPage;
  late final NPage __bookInfoPage;
  static NPage get _bookInfoPage => Routes().__bookInfoPage;
  late final NPage __bookHistory;
  static NPage get _bookHistory => Routes().__bookHistory;
  late final NPage __booklistDetailPage;
  static NPage get _booklistDetailPage => Routes().__booklistDetailPage;
  late final NPage __booklistPage;
  static NPage get _booklistPage => Routes().__booklistPage;
  late final NPage __cacheManager;
  static NPage get _cacheManager => Routes().__cacheManager;
  late final NPage __categegoryView;
  static NPage get _categegoryView => Routes().__categegoryView;
  late final NPage __listCatetoryPage;
  static NPage get _listCatetoryPage => Routes().__listCatetoryPage;
  late final NPage __setting;
  static NPage get _setting => Routes().__setting;
  late final NPage __topPage;
  static NPage get _topPage => Routes().__topPage;
  late final NPageMain _myHomePage;
  static NPageMain get myHomePage => Routes()._myHomePage;
}

class NavRoutes {
  NavRoutes._();

  static RouterAction bookContentPage() {
    return RouterAction(Routes._bookContentPage, Routes.router);
  }

  static RouterAction bookInfoPage({required int id, required ApiType api}) {
    return RouterAction(Routes._bookInfoPage, Routes.router,
        params: {'id': id, 'api': api});
  }

  static RouterAction bookHistory() {
    return RouterAction(Routes._bookHistory, Routes.router);
  }

  static RouterAction booklistDetailPage({int? total, int? index}) {
    return RouterAction(Routes._booklistDetailPage, Routes.router,
        params: {'total': total, 'index': index});
  }

  static RouterAction booklistPage() {
    return RouterAction(Routes._booklistPage, Routes.router);
  }

  static RouterAction cacheManager() {
    return RouterAction(Routes._cacheManager, Routes.router);
  }

  static RouterAction categegoryView(
      {required String title, required int ctg}) {
    return RouterAction(Routes._categegoryView, Routes.router,
        params: {'title': title, 'ctg': ctg});
  }

  static RouterAction listCatetoryPage() {
    return RouterAction(Routes._listCatetoryPage, Routes.router);
  }

  static RouterAction setting() {
    return RouterAction(Routes._setting, Routes.router);
  }

  static RouterAction topPage() {
    return RouterAction(Routes._topPage, Routes.router);
  }

  static RouterAction myHomePage() {
    return RouterAction(Routes.myHomePage, Routes.router);
  }
}
