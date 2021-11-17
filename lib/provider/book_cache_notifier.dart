import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

import '../database/nop_database.dart';
import '../event/event.dart';
import 'book_index_notifier.dart';

class Cache {
  Cache._({
    this.name,
    this.img,
    this.updateTime,
    this.lastChapter,
    this.chapterId,
    this.bookId,
    this.page,
    this.sortKey,
    this.isTop,
    this.isNew,
    this.isShow,
    this.api = ApiType.biquge,
  });

  factory Cache.fromBookCache(BookCache book) {
    return Cache._(
      name: book.name,
      img: book.img,
      updateTime: book.updateTime,
      lastChapter: book.lastChapter,
      chapterId: book.chapterId,
      bookId: book.bookId,
      page: book.page,
      sortKey: book.sortKey,
      isTop: book.isTop,
      isNew: book.isNew,
      isShow: book.isShow,
      api: ApiType.biquge,
    );
  }
  factory Cache.fromZdCache(ZhangduCache book) {
    return Cache._(
      name: book.name,
      img: book.picture,
      updateTime: book.chapterUpdateTime,
      chapterId: book.chapterId,
      lastChapter: book.chapterName,
      bookId: book.bookId,
      page: book.page,
      sortKey: book.sortKey,
      isTop: book.isTop,
      isNew: book.isNew,
      isShow: book.isShow,
      api: ApiType.zhangdu,
    );
  }

  String? name;
  String? img;
  String? updateTime;
  String? lastChapter;
  int? chapterId;
  int? bookId;
  int? page;
  int? sortKey;
  bool? isTop;
  bool? isNew;
  bool? isShow;
  ApiType api;
}

class BookCacheNotifier extends ChangeNotifier {
  BookCacheNotifier(this.repository);
  final Repository repository;

  List<Cache>? _rawList;

  List<Cache>? get rawList => _rawList;

  List<Cache>? _sortChildren;
  List<Cache> get sortChildren {
    if (_sortChildren != null) return _sortChildren!;
    final _list = _rawList;
    if (_list != null && _list.isNotEmpty) {
      _list.sort((p, n) =>
          n.sortKey == null || p.sortKey == null ? 0 : n.sortKey! - p.sortKey!);
      final isTop = _list.where((element) => element.isTop == true);
      final custom = _list.where((element) => element.isTop != true);
      _sortChildren = [...isTop, ...custom];
    } else {
      _sortChildren = <Cache>[];
    }

    return _sortChildren!;
  }

  bool get initialized => _rawList != null;

  List<Cache>? _showChildren;
  List<Cache> get showChildren {
    final sort = sortChildren;

    _showChildren ??= sort.where((e) => e.isShow == true).toList();

    return _showChildren!;
  }

  FutureOr<List<Cache>> get getList async {
    final zdf = repository.bookEvent.zhangduEvent.getZhangduMainList();
    final data = await repository.bookEvent.bookCacheEvent.getMainList();
    final dataList = <Cache>[];
    if (data != null) {
      final tran = data.map((e) => Cache.fromBookCache(e));
      dataList.addAll(tran);
    }
    final zdData = await zdf;
    if (zdData != null) {
      final tran = zdData.map((e) => Cache.fromZdCache(e));
      dataList.addAll(tran);
    }

    return dataList;
  }

  Future<void> _update() async {
    if (showChildren.isEmpty) {
      await _awaitData();
    }
    final list = showChildren;
    final futureAny = FutureAny();
    for (var item in list) {
      if (item.api == ApiType.biquge) {}
      final f = updateBookStatus(item.bookId!, item.api);
      futureAny.add(f);

      if (futureAny.length >= 6) {
        await futureAny.any;
      }
    }
    await futureAny.wait;
  }

  Future<void> load({bool update = false}) async {
    final runner =
        update ? EventQueue.runTaskOnQueue : EventQueue.runOneTaskOnQueue;
    return runner(_load, () => _load(update: update));
  }

  Future<void> _load({bool update = false}) async {
    if (update) {
      await _update();
    }
    await _awaitData();

    notifyListeners();
  }

  Future<void> _awaitData() async {
    final list = await getList;
    _showChildren = _sortChildren = null;
    _rawList = list;
  }

  Future<void> addBook(BookCache bookCache) async {
    await repository.bookEvent.bookCacheEvent.insertBook(bookCache);
    load();
  }

  Future<void> addZdBook(ZhangduCache book) async {
    await repository.bookEvent.zhangduEvent.insertZhangduBook(book);
    load();
  }

  Future<void> updateTop(int id, bool isTop, ApiType api) {
    if (api == ApiType.biquge) {
      return _updateBook(id, BookCache(isTop: isTop, sortKey: sortKey));
    } else {
      return updateZdTop(id, isTop);
    }
  }

  Future<void> updateShow(int id, bool isShow, ApiType api) {
    if (api == ApiType.biquge) {
      return _updateBook(id, BookCache(isShow: isShow, sortKey: sortKey));
    } else {
      Log.i('show: $isShow');
      return updateZdShow(id, isShow);
    }
  }

  Future<void> _updateBook(int id, BookCache book) async {
    await repository.bookEvent.bookCacheEvent.updateBook(id, book);
    return load();
  }

  Future<void> updateZdTop(int id, bool isTop) {
    return _updateZdBook(id, ZhangduCache(isTop: isTop, sortKey: sortKey));
  }

  Future<void> updateZdShow(int id, bool isShow) {
    return _updateZdBook(id, ZhangduCache(isShow: isShow, sortKey: sortKey));
  }

  Future<void> _updateZdBook(int id, ZhangduCache book) async {
    await repository.bookEvent.zhangduEvent.updateZhangduBook(id, book);
    return load();
  }

  Future<void> deleteBook(int? id, ApiType api) async {
    if (id == null) return;
    if (api == ApiType.biquge) {
      await repository.bookEvent.bookCacheEvent.deleteBook(id);
    } else {
      await repository.bookEvent.zhangduEvent.deleteZhangduBook(id);
    }
    load();
  }

  Future<void> deleteZdBook(int? id) async {
    if (id == null) return;
    await repository.bookEvent.zhangduEvent.deleteZhangduBook(id);
    load();
  }

  Future<int> updateBookStatus(int id, ApiType api) async {
    if (api == ApiType.biquge) {
      return await repository.bookEvent.updateBookStatus(id) ?? 0;
    } else {
      return await updateZdStatus(id);
    }
  }

  Future<int> updateZdStatus(int id) async {
    return await repository.bookEvent.zhangduEvent
            .updateZhangduMainStatus(id) ??
        0;
  }
}
