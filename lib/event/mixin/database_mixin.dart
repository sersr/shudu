import 'dart:async';
import 'package:path/path.dart';
import 'package:nop_db/nop_db.dart';

import '../../database/database.dart';
import '../../utils/utils.dart';
import '../base/book_event.dart';

// 数据库接口实现
mixin DatabaseMixin implements DatabaseEvent {
  String get appPath;
  String get name => 'nop_book_database.nopdb';
  int get version => 1;

  late final bookCacheTable = db.bookCacheTable;
  late final bookContentDbTable = db.bookContentDbTable;
  late final bookIndexTable = db.bookIndexTable;

  String get _url => name.isEmpty ? ':memory:' : join(appPath, name);

  late final db = BookDatabase(_url, version);

  int updateBookStatusImpl(int id, String cname, String updateTime) {
    final query = bookCacheTable.query.lastChapter..where.bookId.equal(id);
    final _cname = bookCacheTable.toTable(query.go);

    if (_cname.isNotEmpty) {
      if (_cname.first.lastChapter != cname) {
        final update = bookCacheTable.update
          ..lastChapter.set(cname)
          ..isNew.set(true)
          ..updateTime.set(updateTime)
          ..where.bookId.equal(id);
        return update.go;
      }
    }
    return 0;
  }

  @override
  Stream<List<BookCache>> watchBookCacheCid(int id) {
    final query = bookCacheTable.query
      ..chapterId.bookId
      ..where.bookId.equal(id);

    return query.watchToTable;
  }

  @override
  int updateBookStatusCustom(int id, int cid, int page) {
    final update = bookCacheTable.update
      ..chapterId.page.isNew.sortKey
      ..withArgs([cid, page, false, DateTime.now().millisecondsSinceEpoch])
      ..where.bookId.equal(id);
    return update.go;
  }

  @override
  int updateBookStatusAndSetTop(int id, bool isTop, bool isShow) {
    final update = bookCacheTable.update
      ..isTop.sortKey.isShow
      ..withArgs([isTop, DateTime.now().millisecondsSinceEpoch, isShow])
      ..where.bookId.equal(id);
    return update.go;
  }

  int insertOrUpdateContent(BookContentDb contentDb) {
    final query = bookContentDbTable.query
        .count('*')[(where) => where
          ..bookId.equal(contentDb.bookId!).and
          ..cid.equal(contentDb.cid!)]
        .go;

    final count = query.first.columnAt(0) as int? ?? 0;

    if (count > 0) {
      final update = bookContentDbTable.update
        ..pid.nid
        ..withArgs([contentDb.pid, contentDb.nid])
        ..hasContent.content
        ..withArgs([contentDb.hasContent, contentDb.content])
        ..[(where) => where
          ..bookId.equal(contentDb.bookId!).and
          ..cid.equal(contentDb.cid!)];

      final x = update.go;
      Log.i('update: $x, ${update.updateItems}');
      return x;
    } else {
      bookContentDbTable.pid;
      final insert = bookContentDbTable.insert.insertTable(contentDb);
      final x = insert.go;
      Log.i('insert: $x , ${insert.updateItems}, ${contentDb.bookId}');
      return x;
    }
  }

  List<BookContentDb> getContentDb(int bookid, int contentid) {
    final query = bookContentDbTable.query;

    query.where
      ..bookId.equal(bookid).and
      ..cid.equal(contentid);

    final c = query.goToTable;
    Log.i('${c.length}');
    return c;
  }

  @override
  Set<int> getAllBookId() {
    final query = bookCacheTable.query.bookId;
    return query.goToTable.map((e) => e.bookId).whereType<int>().toSet();
  }

  @override
  int deleteCache(int bookId) {
    final delete = bookContentDbTable.delete..where.bookId.equal(bookId);
    final d = delete.go;
    print('delete: $d');
    return d;
  }

  @override
  int insertOrUpdateIndexs(int id, String indexs) {
    int? count = 0;
    assert(() {
      final d = bookIndexTable.delete..where.bookId.isNull;
      return d.go == 0;
    }(), 'bookId == null');

    final query = bookIndexTable.query.count('*')..where.bookId.equal(id);
    final q = query.go;
    count = q.first.columnAt(0) as int? ?? count;

    if (count > 0) {
      final update = bookIndexTable.update
        ..bIndexs.withArgs(indexs)
        ..where.bookId.equal(id);
      return update.go;
    } else {
      final insert = bookIndexTable.insert
          .insertTable(BookIndex(bookId: id, bIndexs: indexs));
      return insert.go;
    }
  }

  List<BookIndex> getIndexsDb(int bookid) {
    final query =
        bookIndexTable.query.bIndexs[(where) => where.bookId.equal(bookid)];
    return query.goToTable;
  }

  @override
  Stream<List<BookContentDb>> watchCacheContentsCidDb(int bookid) {
    final query = bookContentDbTable.query
      ..cid
      ..where.bookId.equal(bookid);
    return query.watchToTable;
  }

  @override
  List<BookContentDb> getCacheContentsCidDb(int bookid) {
    final query = bookContentDbTable.query
      ..cid.cname
      ..where.bookId.equal(bookid);
    return query.goToTable;
  }

  @override
  int insertBook(BookCache cache) {
    int? count = 0;
    final query = bookCacheTable.query.count('*')
      ..where.bookId.equal(cache.bookId!);
    final q = query.go;

    count = q.first.values.first as int? ?? count;
    Log.i('insertBook: $count');
    if (count == 0) return bookCacheTable.insert.insertTable(cache).go;
    return 0;
  }

  @override
  int deleteBook(int id) {
    final d = bookCacheTable.delete..where.bookId.equal(id);
    return d.go;
  }

  @override
  List<BookCache> getMainBookListDb() => bookCacheTable.query.goToTable;

  @override
  Stream<List<BookCache>> watchMainBookListDb() {
    return bookCacheTable.query.watchToTable;
  }
}
