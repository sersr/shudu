// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

// ignore_for_file: prefer_const_constructors

class Routes {
  Routes._();

  static Routes? _instance;

  static Routes init({
    bool newInstance = false,
    Map<String, dynamic> params = const {},
    Map<String, dynamic>? extra,
    Object? groupId,
    List<NavigatorObserver> observers = const [],
  }) {
    if (!newInstance && _instance != null) {
      return _instance!;
    }
    return _instance = Routes._().._init(params, extra, groupId, observers);
  }

  void _init(
    Map<String, dynamic> params,
    Map<String, dynamic>? extra,
    Object? groupId,
    List<NavigatorObserver> observers,
  ) {
    __bookContentPage = NPage(
      path: 'bookContentPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: BookContentPage(),
          ),
        );
      },
    );

    __bookInfoPage = NPage(
      path: 'bookInfoPage',
      pageBuilder: (entry) {
        var id = entry.queryParams['id'];
        if (id is! int?) {
          id = jsonDecodeCustom(id);
        }
        var api = entry.queryParams['api'];
        if (api is! ApiType?) {
          api = ApiType.fromJson(api);
        }
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: Nop.page(
            builders: const [ShuduRoute._builder],
            child: BookInfoPage(id: id, api: api),
          ),
        );
      },
    );

    __bookHistory = NPage(
      path: 'bookHistory',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: BookHistory(),
          ),
        );
      },
    );

    __booklistDetailPage = NPage(
      path: 'booklistDetailPage',
      pageBuilder: (entry) {
        var total = entry.queryParams['total'];
        if (total is! int?) {
          total = jsonDecodeCustom(total);
        }
        var index = entry.queryParams['index'];
        if (index is! int?) {
          index = jsonDecodeCustom(index);
        }
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: Nop.page(
            child: BooklistDetailPage(total: total, index: index),
          ),
        );
      },
    );

    __booklistPage = NPage(
      path: 'booklistPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: BooklistPage(),
          ),
        );
      },
    );

    __cacheManager = NPage(
      path: 'cacheManager',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: CacheManager(),
          ),
        );
      },
    );

    __categegoryView = NPage(
      path: 'categegoryView',
      pageBuilder: (entry) {
        var title = entry.queryParams['title'];
        var ctg = entry.queryParams['ctg'];
        if (ctg is! int?) {
          ctg = jsonDecodeCustom(ctg);
        }
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: Nop.page(
            child: CategegoryView(title: title, ctg: ctg),
          ),
        );
      },
    );

    __listCatetoryPage = NPage(
      pages: [__categegoryView],
      path: 'listCatetoryPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: ListCatetoryPage(),
          ),
        );
      },
    );

    __setting = NPage(
      path: 'setting',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: Setting(),
          ),
        );
      },
    );

    __topPage = NPage(
      path: 'topPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: TopPage(),
          ),
        );
      },
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
      pageBuilder: (entry) {
        return MaterialIgnorePage(
          key: entry.pageKey,
          entry: entry,
          child: const Nop.page(
            child: MyHomePage(),
          ),
        );
      },
    );

    _router = NRouter(
      rootPage: _myHomePage,
      restorationId: 'main',
      params: params,
      extra: extra,
      groupId: groupId,
      observers: observers,
    );
  }

  late final NRouter _router;
  static NRouter get router => _instance!._router;
  late final NPage __bookContentPage;
  static NPage get _bookContentPage => _instance!.__bookContentPage;
  late final NPage __bookInfoPage;
  static NPage get _bookInfoPage => _instance!.__bookInfoPage;
  late final NPage __bookHistory;
  static NPage get _bookHistory => _instance!.__bookHistory;
  late final NPage __booklistDetailPage;
  static NPage get _booklistDetailPage => _instance!.__booklistDetailPage;
  late final NPage __booklistPage;
  static NPage get _booklistPage => _instance!.__booklistPage;
  late final NPage __cacheManager;
  static NPage get _cacheManager => _instance!.__cacheManager;
  late final NPage __categegoryView;
  static NPage get _categegoryView => _instance!.__categegoryView;
  late final NPage __listCatetoryPage;
  static NPage get _listCatetoryPage => _instance!.__listCatetoryPage;
  late final NPage __setting;
  static NPage get _setting => _instance!.__setting;
  late final NPage __topPage;
  static NPage get _topPage => _instance!.__topPage;
  late final NPageMain _myHomePage;
  static NPageMain get myHomePage => _instance!._myHomePage;
}

class NavRoutes {
  NavRoutes._();

  static RouterAction bookContentPage() {
    return RouterAction(Routes._bookContentPage, Routes.router);
  }

  static RouterAction bookInfoPage({required int id, required ApiType api}) {
    return RouterAction(Routes._bookInfoPage, Routes.router,
        extra: {'id': id, 'api': api});
  }

  static RouterAction bookHistory() {
    return RouterAction(Routes._bookHistory, Routes.router);
  }

  static RouterAction booklistDetailPage({int? total, int? index}) {
    return RouterAction(Routes._booklistDetailPage, Routes.router,
        extra: {'total': total, 'index': index});
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
        extra: {'title': title, 'ctg': ctg});
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
