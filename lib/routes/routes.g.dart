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
    bool updateLocation = false,
    List<NavigatorObserver> observers = const [],
  }) {
    if (!newInstance && _instance != null) {
      return _instance!;
    }
    final instance = _instance = Routes._();
    instance._init(params, extra, groupId, observers, updateLocation);
    return instance;
  }

  void _init(
    Map<String, dynamic> params,
    Map<String, dynamic>? extra,
    Object? groupId,
    List<NavigatorObserver> observers,
    bool updateLocation,
  ) {
    __bookContentPage = NPage(
      path: 'bookContentPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const BookContentPage());
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
            child: ShuduRoute._builder(BookInfoPage(id: id, api: api)));
      },
    );

    __bookHistory = NPage(
      path: 'bookHistory',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const BookHistory());
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
            child: BooklistDetailPage(total: total, index: index));
      },
    );

    __booklistPage = NPage(
      path: 'booklistPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const BooklistPage());
      },
    );

    __cacheManager = NPage(
      path: 'cacheManager',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const CacheManager());
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
            child: CategegoryView(title: title, ctg: ctg));
      },
    );

    __listCatetoryPage = NPage(
      pages: [__categegoryView],
      path: 'listCatetoryPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const ListCatetoryPage());
      },
    );

    __setting = NPage(
      path: 'setting',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const Setting());
      },
    );

    __topPage = NPage(
      path: 'topPage',
      pageBuilder: (entry) {
        return MaterialIgnorePage(
            key: entry.pageKey, entry: entry, child: const TopPage());
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
            key: entry.pageKey, entry: entry, child: const MyHomePage());
      },
    );

    _router = NRouter(
      rootPage: _myHomePage,
      restorationId: 'main',
      params: params,
      extra: extra,
      groupId: groupId,
      observers: observers,
      updateLocation: updateLocation,
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

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction bookContentPage({groupId}) {
    return RouterAction(Routes._bookContentPage, Routes.router,
        groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction bookInfoPage(
      {required int id, required ApiType api, groupId}) {
    return RouterAction(Routes._bookInfoPage, Routes.router,
        extra: {'id': id, 'api': api}, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction bookHistory({groupId}) {
    return RouterAction(Routes._bookHistory, Routes.router, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction booklistDetailPage({int? total, int? index, groupId}) {
    return RouterAction(Routes._booklistDetailPage, Routes.router,
        extra: {'total': total, 'index': index}, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction booklistPage({groupId}) {
    return RouterAction(Routes._booklistPage, Routes.router, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction cacheManager({groupId}) {
    return RouterAction(Routes._cacheManager, Routes.router, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction categegoryView(
      {required String title, required int ctg, groupId}) {
    return RouterAction(Routes._categegoryView, Routes.router,
        extra: {'title': title, 'ctg': ctg}, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction listCatetoryPage({groupId}) {
    return RouterAction(Routes._listCatetoryPage, Routes.router,
        groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction setting({groupId}) {
    return RouterAction(Routes._setting, Routes.router, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction topPage({groupId}) {
    return RouterAction(Routes._topPage, Routes.router, groupId: groupId);
  }

  /// [groupId]
  /// see: [NPage.newGroupKey]
  static RouterAction myHomePage({groupId}) {
    return RouterAction(Routes.myHomePage, Routes.router, groupId: groupId);
  }
}
