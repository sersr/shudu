import 'dart:async';
import 'dart:convert';

import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:path/path.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:utils/utils.dart';

import '../../../database/database.dart';
import '../../../pages/book_list/cache_manager.dart';
import '../../base/export.dart';

// 数据库接口实现
mixin DatabaseMixin on Resolve implements DatabaseEvent {
  String get appPath;
  String get name => 'nop_book_database.nopdb';

  late final bookCache = db.bookCache;
  late final bookContentDb = db.bookContentDb;
  late final bookIndex = db.bookIndex;

  String get _url => name.isEmpty || name == NopDatabase.memory
      ? NopDatabase.memory
      : join(appPath, name);

  @override
  FutureOr<void> onClose() async {
    await db.dispose();
    return super.onClose();
  }

  @override
  void initStateListen(add) {
    super.initStateListen(add);
    add(_initDb());
  }

  FutureOr<void> _initDb() {
    if (_url != NopDatabase.memory && !kIsWeb) {
      const fs = LocalFileSystem();
      final dir = fs.currentDirectory.childDirectory(appPath);
      dir.createSync(recursive: true);
    }
    return db.initDb();
  }

  late final db = BookDatabase(_url);

  @override
  FutureOr<int> updateBook(int id, BookCache book) {
    final update = bookCache.update..where.bookId.equalTo(id);
    bookCache.updateBookCache(update, book);
    return update.go;
  }

  @override
  FutureOr<int> deleteCache(int bookId) {
    final delete = bookContentDb.delete..where.bookId.equalTo(bookId);
    return delete.go;
  }

  @override
  Stream<List<BookCache>> watchCurrentCid(int id) {
    final query = bookCache.query
      ..chapterId.bookId
      ..where.bookId.equalTo(id);

    return query.watchToTable;
  }

  @override
  Stream<List<BookContentDb>> watchBookContentCid(int bookid) {
    late Stream<List<BookContentDb>> w;
    bookContentDb.query.cid
      ..where.bookId.equalTo(bookid)
      ..let((s) => w = s.watchToTable);

    return w;
  }

  @override
  FutureOr<int> insertBook(BookCache cache) async {
    FutureOr<int> count = 0;

    final q = bookCache.query;
    q
      ..select.count.all.push
      ..where.bookId.equalTo(cache.bookId!);
    final g = q.go;
    final _count = await g.first.values.first ?? 0;
    if (_count == 0) count = bookCache.insert.insertTable(cache).go;

    return count;
  }

  @override
  FutureOr<int> deleteBook(int id) {
    late FutureOr<int> d;

    bookCache.delete
      ..where.bookId.equalTo(id)
      ..let((s) => d = s.go);

    return d;
  }

  @override
  FutureOr<Option<List<BookCache>>> getMainList() =>
      bookCache.query.goToTable.then((v) => Some(v));

  @override
  Stream<List<BookCache>> watchMainList() {
    return bookCache.query.all.watchToTable;
  }

  Future<void> updateIndexCacheLength(int bookId) async {
    final cacheLength = await getBookContentCid(bookId) ?? 0;
    final update = bookIndex.update.cacheItemCounts.set(cacheLength)
      ..where.bookId.equalTo(bookId);
    await update.go;
  }

  FutureOr<int?> getBookContentCid(int bookid) async {
    final q = bookContentDb.query
      ..select.count.all.push
      ..where.bookId.equalTo(bookid);
    final count = await (q.go.first.values.first) as int? ?? 0;
    assert(Log.i('count: $count'));
    return count;
  }

  FutureOr<List<BookContentDb>> contentDb(int bookid, int contentid) {
    final query = bookContentDb.query
      ..index.by(db.index)
      ..where.cid.equalTo(contentid).and.bookId.equalTo(bookid);
    return query.goToTable;
  }

  @override
  Future<RawContentLines?> getContentDb(int bookid, int contentid) async {
    final queryList = await contentDb(bookid, contentid);
    if (queryList.isNotEmpty) {
      final bookContent = queryList.last;
      if (bookContent.content != null) {
        final lines = LineSplitter.split(bookContent.content!).toList();

        return RawContentLines(
          source: lines,
          nid: bookContent.nid,
          pid: bookContent.pid,
          cid: bookContent.cid,
          hasContent: bookContent.hasContent,
          cname: bookContent.cname,
        );
      }
    }
    return null;
  }

  FutureOr<List<BookIndex>> getIndexsDbCacheItem() {
    final q = bookIndex.query.itemCounts.cacheItemCounts.bookId;
    return q.goToTable;
  }

  @override
  Future<List<CacheItem>> getCacheItems() async {
    final list = <CacheItem>[];
    final stop = Stopwatch()..start();
    var queryList = await getIndexsDbCacheItem();
    var map =
        queryList.asMap().map((key, value) => MapEntry(value.bookId, value));

    var allBookids = await getAllBookId();

    for (var a in allBookids) {
      final index = map[a];
      final itemCounts = index?.itemCounts;
      if (itemCounts != null) {
        final item = CacheItem(a, itemCounts, index?.cacheItemCounts ?? 0);
        list.add(item);
      } else {
        list.add(CacheItem(a, 0, 0));
      }
    }
    stop.stop();
    Log.w('use time: ${stop.elapsedMilliseconds} ms', onlyDebug: false);
    return list;
  }

  FutureOr<Set<int>> getAllBookId() {
    final query = bookCache.query.bookId;
    return query.goToTable
        .then((value) => value.map((e) => e.bookId).whereType<int>().toSet());
  }
}
