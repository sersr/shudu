import 'dart:async';

import 'package:nop_db/database/nop.dart';
import 'package:path/path.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../database/database.dart';
import '../base/book_event.dart';

// 数据库接口实现
mixin DatabaseMixin implements DatabaseEvent {
  String get appPath;
  String get name => 'nop_book_database.nopdb';
  int get version => 1;

  bool get useFfi => false;
  bool get useSqflite3 => false;

  late final bookCache = db.bookCache;
  late final bookContentDb = db.bookContentDb;
  late final bookIndex = db.bookIndex;

  String get _url => name.isEmpty || name == NopDatabase.memory
      ? NopDatabase.memory
      : join(appPath, name);

  FutureOr<void> initDb() => db.initDb();

  late final db = BookDatabase(_url, version, useFfi, useSqflite3);

  @override
  Stream<List<BookCache>> watchBookCacheCid(int id) {
    final query = bookCache.query
      ..chapterId.bookId
      ..where.bookId.equalTo(id);

    return query.watchToTable;
  }

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
      Log.i('update: $x, ${update.updateItems}');
      return x;
    } else {
      bookContentDb.pid;
      final insert = bookContentDb.insert.insertTable(contentDb);
      final x = insert.go;
      Log.i('insert: $x , ${insert.updateItems}, ${contentDb.bookId}');
      return x;
    }
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

    if (count > 0) {
      final update = bookIndex.update
        ..bIndexs.set(indexs)
        ..where.bookId.equalTo(id);
      return update.go;
    } else {
      final insert =
          bookIndex.insert.insertTable(BookIndex(bookId: id, bIndexs: indexs));
      return insert.go;
    }
  }

  FutureOr<List<BookIndex>> getIndexsDb(int bookid) {
    final q = bookIndex.query.bIndexs..where.bookId.equalTo(bookid);
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
  Stream<List<BookContentDb>> watchCacheContentsCidDb(int bookid) {
    late Stream<List<BookContentDb>> w;

    bookContentDb.query.cid
      ..where.bookId.equalTo(bookid)
      ..let((s) => w = s.watchToTable);

    return w;
  }

  @override
  FutureOr<List<BookContentDb>> getCacheContentsCidDb(int bookid) {
    late FutureOr<List<BookContentDb>> l;

    bookContentDb.query.cid.cname
      ..where.bookId.equalTo(bookid)
      ..let((s) => l = s.goToTable);

    return l;
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
