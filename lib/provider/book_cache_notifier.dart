import 'dart:async';

import 'package:flutter/material.dart';
import 'package:useful_tools/event_queue.dart';

import '../database/nop_database.dart';
import '../event/event.dart';

class BookCacheNotifier extends ChangeNotifier {
  BookCacheNotifier(this.repository);
  final Repository repository;

  List<BookCache>? _rawList;

  List<BookCache>? _sortChildren;
  List<BookCache> get sortChildren {
    if (_sortChildren != null) return _sortChildren!;
    final _list = _rawList;
    if (_list != null && _list.isNotEmpty) {
      _list.sort((p, n) => n.sortKey! - p.sortKey!);
      final isTop = _list.where((element) => element.isTop == true);
      final custom = _list.where((element) => element.isTop != true);
      _sortChildren = [...isTop, ...custom];
    } else {
      _sortChildren = <BookCache>[];
    }

    return _sortChildren!;
  }

  bool get initialized => _rawList != null;

  List<BookCache>? _showChildren;
  List<BookCache> get showChildren {
    final sort = sortChildren;

    _showChildren ??= sort.where((e) => e.isShow == true).toList();

    return _showChildren!;
  }

  FutureOr<List<BookCache>> get getList async {
    return await repository.bookEvent.bookCacheEvent.getMainBookListDb() ??
        _rawList ??
        const [];
  }

  Future<void> _update() async {
    final list = await getList;
    final futureAny = FutureAny();
    for (var item in list) {
      final f = updateBookStatus(item.bookId!);
      futureAny.add(f);

      if (futureAny.length >= 6) {
        await futureAny.future;
      }
    }
    await futureAny.waitAll;
  }

  Future<void> load({bool update = false}) async {
    if (update) {
      await _update();
    }

    final list = await getList;

    _showChildren = _sortChildren = null;
    _rawList = list;

    notifyListeners();
  }

  Future<void> addBook(BookCache bookCache) async {
    await repository.bookEvent.bookCacheEvent.insertBook(bookCache);
    load();
  }

  Future<void> updateTop(int id, bool isTop) {
    return _updateBook(id, BookCache(isTop: isTop, sortKey: sortKey));
  }

  Future<void> updateShow(int id, bool isShow) {
    return _updateBook(id, BookCache(isShow: isShow, sortKey: sortKey));
  }

  Future<void> _updateBook(int id, BookCache book) async {
    await repository.bookEvent.bookCacheEvent.updateBook(id, book);
    return load();
  }

  Future<void> deleteBook(int? id) async {
    if (id == null) return;
    await repository.bookEvent.bookCacheEvent.deleteBook(id);
    load();
  }

  Future<int> updateBookStatus(int id) async {
    return await repository.bookEvent.updateBookStatus(id) ?? 0;
  }
}
