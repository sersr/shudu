import 'dart:async';
import 'dart:convert';

import 'package:file/local.dart';
import 'package:nop_db/nop_db.dart';
import 'package:path/path.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:utils/future_or_ext.dart';

import '../../data/data.dart';
import '../../data/zhangdu/zhangdu_search.dart';
import '../../data/zhangdu/zhangdu_same_users_books.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../database/database.dart';
import '../../pages/book_list/cache_manager.dart';
import '../base/book_event.dart';
import '../base/complex_event.dart';
import '../base/zhangdu_event.dart';

// 数据库接口实现
mixin DatabaseMixin implements DatabaseEvent, ComplexOnDatabaseEvent {
  String get appPath;
  String get name => 'nop_book_database.nopdb';

  bool get useSqflite3 => false;

  late final bookCache = db.bookCache;
  late final bookContentDb = db.bookContentDb;
  late final bookIndex = db.bookIndex;

  String get _url => name.isEmpty || name == NopDatabase.memory
      ? NopDatabase.memory
      : join(appPath, name);

  FutureOr<void> initDb() {
    if (_url != NopDatabase.memory) {
      const fs = LocalFileSystem();
      final dir = fs.currentDirectory.childDirectory(appPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
    return db.initDb();
  }

  FutureOr<void> closeDb() {
    return db.dispose();
  }

  late final db = BookDatabase(_url, useSqflite3);

  @override
  FutureOr<int> updateBook(int id, BookCache book) {
    final update = bookCache.update..where.bookId.equalTo(id);
    bookCache.updateBookCache(update, book);
    return update.go;
  }

  @override
  FutureOr<int> deleteCache(int bookId) {
    final delete = bookContentDb.delete..where.bookId.equalTo(bookId);
    final d = delete.go;
    Log.i('delete: $d');
    return d;
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
  FutureOr<List<BookCache>> getMainList() => bookCache.query.goToTable;

  @override
  Stream<List<BookCache>> watchMainList() {
    return bookCache.query.all.watchToTable;
  }

  /// [ComplexMixin]
  @override
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
      assert(Log.i('update: ${await x}, ${update.updateItems}'));
      return x;
    } else {
      final insert = bookContentDb.insert.insertTable(contentDb);
      final x = insert.go;
      assert(Log.i('insert: ${await x}, ${contentDb.bookId}'));

      /// update Index cacheItemCounts
      updateIndexCacheLength(contentDb.bookId!);

      return x;
    }
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
    assert(Log.i('count: .... $count'));
    return count;
  }

  @override
  FutureOr<List<BookContentDb>> getContentDb(int bookid, int contentid) {
    final query = bookContentDb.query..index.by(db.index);

    query.where.cid.equalTo(contentid).and.bookId.equalTo(bookid);
    return query.goToTable;
  }

  @override
  FutureOr<Set<int>> getAllBookId() {
    final query = bookCache.query.bookId;
    return query.goToTable
        .then((value) => value.map((e) => e.bookId).whereType<int>().toSet());
  }

  @override
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

  @override
  FutureOr<List<BookIndex>> getIndexsDb(int bookid) {
    final q = bookIndex.query.bIndexs..where.bookId.equalTo(bookid);
    return q.goToTable;
  }

  @override
  FutureOr<List<BookIndex>> getIndexsDbCacheItem() {
    final q = bookIndex.query.itemCounts.cacheItemCounts.bookId;
    return q.goToTable;
  }

  @override
  FutureOr<List<BookCache>> getBookCacheDb(int bookid) =>
      bookCache.query.where.bookId.equalTo(bookid).back.whereEnd.goToTable;
}

class DataBaseUnImpl implements ZhangduEvent {
  @override
  FutureOr<int?> deleteZhangduBook(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<CacheItem>?> getZhangduCacheItems() {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    throw UnimplementedError();
  }

  @override
  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) {
    throw UnimplementedError();
  }

  @override
  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    throw UnimplementedError();
  }
}
