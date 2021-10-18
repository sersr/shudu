import 'dart:async';
import 'dart:convert';

import 'package:nop_db/database/nop.dart';
import 'package:nop_db/database/statement.dart';
import 'package:nop_db/database/table.dart';
import 'package:nop_db/extensions/future_or_ext.dart';
import 'package:path/path.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/book_index.dart';
import '../../database/database.dart';
import '../base/book_event.dart';

// 数据库接口实现
mixin DatabaseMixin implements DatabaseEvent {
  String get appPath;
  String get name => 'nop_book_database.nopdb';

  bool get useFfi => false;
  bool get useSqflite3 => false;

  late final bookCache = db.bookCache;
  late final bookContentDb = db.bookContentDb;
  late final bookIndex = db.bookIndex;

  String get _url => name.isEmpty || name == NopDatabase.memory
      ? NopDatabase.memory
      : join(appPath, name);

  FutureOr<void> initDb() => db.initDb();

  late final db = BookDatabase(_url, useFfi, useSqflite3);

  @override
  FutureOr<int> updateBook(int id, BookCache book) {
    final update = bookCache.update..where.bookId.equalTo(id);
    bookCache.updateBookCache(update, book);
    return update.go;
  }

  FutureOr<int> insertOrUpdateContent(BookContentDb contentDb) async {
    var count = 0;
    final q = bookContentDb.query;
    q.where
      ..select.count.all.push
      ..bookId.equalTo(contentDb.bookId!).and
      ..cid.equalTo(contentDb.cid!);

    count = await q.go.first.values.first as int? ?? count;

    if (count > 0) {
      final update = bookContentDb.update
        ..pid.set(contentDb.pid).nid.set(contentDb.nid)
        ..hasContent.set(contentDb.hasContent).content.set(contentDb.content);

      update.where
        ..bookId.equalTo(contentDb.bookId!).and
        ..cid.equalTo(contentDb.cid!);

      final x = update.go;
      assert(Log.i('update: $x, ${update.updateItems}'));
      return x;
    } else {
      final insert = bookContentDb.insert.insertTable(contentDb);
      final x = insert.go;
      assert(Log.i('insert: $x , ${insert.updateItems}, ${contentDb.bookId}'));

      /// update Index cacheItemCounts
      updateIndexCacheLength(contentDb.bookId!);

      return x;
    }
  }

  Future<void> updateIndexCacheLength(int bookId) async {
    final cacheLength = await getCacheContentsCidDb(bookId) ?? 0;
    final update = bookIndex.update.cacheItemCounts.set(cacheLength)
      ..where.bookId.equalTo(bookId);
    await update.go;
  }

  FutureOr<List<BookContentDb>> getContentDb(int bookid, int contentid) {
    late FutureOr<List<BookContentDb>> c;

    bookContentDb.query.where
      ..bookId.equalTo(bookid)
      ..and.cid.equalTo(contentid)
      ..whereEnd.let((s) => c = s.goToTable);

    //  Log.i('${c.length}');
    return c;
  }

  @override
  FutureOr<Set<int>> getAllBookId() {
    final query = bookCache.query.bookId;
    return query.goToTable
        .then((value) => value.map((e) => e.bookId).whereType<int>().toSet());
  }

  @override
  FutureOr<int> deleteCache(int bookId) {
    final delete = bookContentDb.delete..where.bookId.equalTo(bookId);
    final d = delete.go;
    Log.i('delete: $d');
    return d;
  }

  FutureOr<int> insertOrUpdateIndexs(int id, String indexs) async {
    var count = 0;

    final q = bookIndex.query;
    q.where
      ..select.count.all.push
      ..bookId.equalTo(id);
    count = await q.go.first.values.first as int? ?? count;
    final bIndexs = indexs;

    var itemCounts = _computeIndexLength(bIndexs);

    if (count > 0) {
      final update = bookIndex.update
        ..bIndexs.set(indexs)
        ..itemCounts.set(itemCounts)
        ..where.bookId.equalTo(id);
      return update.go;
    } else {
      final insert = bookIndex.insert.insertTable(
          BookIndex(bookId: id, bIndexs: indexs, itemCounts: itemCounts));

      return insert.go;
      // ..whenComplete(() => updateIndexCacheLength(id));
    }
  }

  int _computeIndexLength(String rawIndexs) {
    var itemCounts = 0;
    final decodeIndexs = BookIndexRoot.fromJson(jsonDecode(rawIndexs)).data ??
        const NetBookIndex();
    final list = decodeIndexs.list;
    var length = 0;
    if (list != null && list.isNotEmpty) {
      for (var item in list) length += item.list?.length ?? 0;

      itemCounts = length;
    }
    return itemCounts;
  }

  FutureOr<List<BookContentDb>> getCacheContentsCidDbAll() {
    return bookContentDb.query.bookId.goToTable;
  }

  FutureOr<List<BookIndex>> getIndexsDb(int bookid) {
    final q = bookIndex.query.bIndexs..where.bookId.equalTo(bookid);
    return q.goToTable;
  }

  FutureOr<List<BookIndex>> getIndexsDbCacheItemBookid(int bookid) async {
    final q = bookIndex.query.itemCounts.cacheItemCounts
      ..where.bookId.equalTo(bookid);
    var data = await q.goToTable;
    final shouldUpdate = data.isNotEmpty && data.last.itemCounts == null;
    if (shouldUpdate) {
      final index = await getIndexsDb(bookid);
      // Log.i('itemCounts index: $index', onlyDebug: false);

      if (index.isNotEmpty) {
        await insertOrUpdateIndexs(bookid, index.last.bIndexs!);
        data = await q.goToTable;
      }
    }
    return data;
  }

  FutureOr<List<BookIndex>> getIndexsDbCacheItem() {
    final q = bookIndex.query.itemCounts.cacheItemCounts.bookId;
    return q.goToTable;
  }

  FutureOr<List<BookIndex>> getIndexsDbAll() {
    late FutureOr<List<BookIndex>> l;

    bookIndex.query
      ..select.all
      ..let((s) => l = s.goToTable);

    return l;
  }

  @override
  Stream<List<BookCache>> watchBookCacheCid(int id) {
    final query = bookCache.query
      ..chapterId.bookId
      ..where.bookId.equalTo(id);

    return query.watchToTable;
  }

  @override
  Stream<List<BookContentDb>> watchCacheContentsCidDb(int bookid) {
    late Stream<List<BookContentDb>> w;

    bookContentDb.query.cid
      ..where.bookId.equalTo(bookid)
      ..let((s) => w = s.watchToTable);

    return w;
  }

  @override
  FutureOr<int?> getCacheContentsCidDb(int bookid) {
    final q = bookContentDb.query
      ..select.count.all.push
      ..where.bookId.equalTo(bookid);
    return (q.go.first.values.first) as FutureOr<int?>;
  }

  QueryStatement getCacheContentsCidDbStatement(int bookid) {
    final q = bookContentDb.query
      ..select.count.all.push
      ..where.bookId.equalTo(bookid);
    return q;
  }

  @override
  FutureOr<int> insertBook(BookCache cache) async {
    // assert(cache.notNullIgnores(['id']));
    FutureOr<int> count = 0;

    final q = bookCache.query;
    q
      ..select.count.all.push
      ..where.bookId.equalTo(cache.bookId!);
    final g = q.go;
    final _count = await g.first.values.first ?? 0;

    Log.i('insertBook: $count');
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
  FutureOr<List<BookCache>> getMainBookListDb() => bookCache.query.goToTable;

  @override
  FutureOr<List<BookCache>> getBookCacheDb(int bookid) =>
      bookCache.query.where.bookId.equalTo(bookid).back.whereEnd.goToTable;

  @override
  Stream<List<BookCache>> watchMainBookListDb() {
    return bookCache.query.all.watchToTable;
  }
}
