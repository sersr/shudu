import 'dart:async';

import 'package:nop_db/database/nop.dart';
import 'package:path/path.dart';
import 'package:useful_tools/common.dart';

import '../../database/database.dart';
import '../base/book_event.dart';

// 数据库接口实现
mixin DatabaseMixin implements DatabaseEvent {
  String get appPath;
  String get name => 'nop_book_database.nopdb';
  int get version => 1;

  late final bookCache = db.bookCache;
  late final bookContentDb = db.bookContentDb;
  late final bookIndex = db.bookIndex;

  String get _url => name.isEmpty || name == NopDatabase.memory
      ? NopDatabase.memory
      : join(appPath, name);

  late final db = BookDatabase(_url, version);

  @override
  Stream<List<BookCache>> watchBookCacheCid(int id) {
    final query = bookCache.query
      ..chapterId.bookId
      ..where.bookId.equalTo(id);

    return query.watchToTable;
  }

  @override
  int updateBook(int id, BookCache book) {
    final update = bookCache.update..where.bookId.equalTo(id);
    bookCache.updateBookCache(update, book);
    return update.go;
  }

  int insertOrUpdateContent(BookContentDb contentDb) {
    var count = 0;
    bookContentDb.query.where
      ..select.count.all.push
      ..bookId.equalTo(contentDb.bookId!).and
      ..cid.equalTo(contentDb.cid!)
      ..whereEnd.let((s) {
        count = s.go.first.columnAt(0) as int? ?? count;
      });

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

  List<BookContentDb> getContentDb(int bookid, int contentid) {
    late List<BookContentDb> c;

    bookContentDb.query.where
      ..bookId.equalTo(bookid)
      ..and.cid.equalTo(contentid)
      ..whereEnd.let((s) => c = s.goToTable);

    Log.i('${c.length}');
    return c;
  }

  @override
  Set<int> getAllBookId() {
    final query = bookCache.query.bookId;
    return query.goToTable.map((e) => e.bookId).whereType<int>().toSet();
  }

  @override
  int deleteCache(int bookId) {
    final delete = bookContentDb.delete..where.bookId.equalTo(bookId);
    final d = delete.go;
    print('delete: $d');
    return d;
  }

  int insertOrUpdateIndexs(int id, String indexs) {
    var count = 0;

    // assert(() {
    //   final d = bookIndex.delete..where.bookId.isNull;
    //   // return d.go == 0;
    //   return true;
    // }(), 'bookId == null');

    bookIndex.query.where
      ..select.count.all.push
      ..bookId.equalTo(id)
      ..whereEnd.let((s) {
        final q = s.go;
        count = q.first.columnAt(0) as int? ?? count;
      });

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

  List<BookIndex> getIndexsDb(int bookid) {
    late List<BookIndex> l;

    bookIndex.query.bIndexs
      ..where.bookId.equalTo(bookid)
      ..let((s) => l = s.goToTable);

    return l;
  }

  List<BookIndex> getIndexsDbAll() {
    late List<BookIndex> l;

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
  List<BookContentDb> getCacheContentsCidDb(int bookid) {
    late List<BookContentDb> l;

    bookContentDb.query.cid.cname
      ..where.bookId.equalTo(bookid)
      ..let((s) => l = s.goToTable);

    return l;
  }

  @override
  int insertBook(BookCache cache) {
    // assert(cache.notNullIgnores(['id']));
    var count = 0;

    bookCache.query
      ..select.count.all.push
      ..where.bookId.equalTo(cache.bookId!)
      ..let((s) {
        final q = s.go;
        final _count = q.first.values.first ?? 0;

        Log.i('insertBook: $count');
        if (_count == 0) count = bookCache.insert.insertTable(cache).go;
      });

    return count;
  }

  @override
  int deleteBook(int id) {
    late int d;

    bookCache.delete
      ..where.bookId.equalTo(id)
      ..let((s) => d = s.go);

    return d;
  }

  @override
  List<BookCache> getMainBookListDb() => bookCache.query.goToTable;
  List<BookCache> getBookCacheDb(int bookid) =>
      bookCache.query.where.bookId.equalTo(bookid).back.whereEnd.goToTable;

  @override
  Stream<List<BookCache>> watchMainBookListDb() {
    return bookCache.query.all.watchToTable;
  }
}
