import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

import '../database/nop_database.dart';
import '../event/export.dart';
import 'book_index_notifier.dart';

class Cache {
  static const none = Cache._();
  const Cache._({
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

  final String? name;
  final String? img;
  final String? updateTime;
  final String? lastChapter;
  final int? chapterId;
  final int? bookId;
  final int? page;
  final int? sortKey;
  final bool? isTop;
  final bool? isNew;
  final bool? isShow;
  final ApiType api;
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
    final dataList = <Cache>[];
    final fn1 = repository.bookCacheEvent.getMainList().mapOption(
        ifNone: () {},
        ifSome: (data) =>
            dataList.addAll(data.map((e) => Cache.fromBookCache(e))));
    await fn1;
    return dataList;
  }

  Future<void> _update() async {
    if (showChildren.isEmpty) {
      await _awaitData();
    }
    final list = showChildren;
    final futureAny = FutureAny();
    for (var item in list) {
      final f = updateBookStatus(item.bookId!, item.api);
      futureAny.add(f);

      if (futureAny.length >= 6) {
        await futureAny.any;
      }
    }
    await futureAny.wait;
  }

  Future<void> load({bool update = false}) async {
    final runner = update ? EventQueue.run : EventQueue.runOne;
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
    await repository.bookCacheEvent.insertBook(bookCache);
    load();
  }

  Future<void> updateTop(int id, bool isTop, ApiType api) {
    return _updateBook(id, BookCache(isTop: isTop, sortKey: sortKey));
  }

  Future<void> updateShow(int id, bool isShow, ApiType api) {
    return _updateBook(id, BookCache(isShow: isShow, sortKey: sortKey));
  }

  Future<void> _updateBook(int id, BookCache book) async {
    await repository.bookCacheEvent.updateBook(id, book);
    return load();
  }

  Future<void> deleteBook(int? id, ApiType api) async {
    if (id == null) return;
    await repository.bookCacheEvent.deleteBook(id);

    load();
  }

  Future<void> updateBookStatus(int id, ApiType api) async {
    await repository.getInfo(id);
  }
}
