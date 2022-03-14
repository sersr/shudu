import 'dart:async';
import 'dart:convert';

import 'package:lpinyin/lpinyin.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:utils/utils.dart';

import '../../../data/data.dart';
import '../../../database/database.dart';
import '../../../database/nop_database.dart';
import '../../base/export.dart';
import 'database_mixin.dart';

/// database: biqu
mixin ComplexOnDatabaseMixin on DatabaseMixin, ServerEvent {
  @override
  FutureOr<int?> insertOrUpdateBook(BookInfo data) async {
    final bookId = data.id;
    if (bookId == null) return 0;
    final bookInfo = await getBookCacheDb(bookId);

    BookCache? book;
    if (bookInfo.isNotEmpty) {
      book = bookInfo.last;
    }

    final lastChapter = data.lastChapter;
    final lastTime = data.lastTime;

    final name = data.name;
    final img =
        data.img ?? '${PinyinHelper.getPinyinE(name ?? '', separator: '')}.jpg';

    final _book = book;

    if (_book == null) {
      insertBook(BookCache(
        name: name,
        img: img,
        updateTime: lastTime,
        lastChapter: data.lastChapter,
        chapterId: data.firstChapterId,
        bookId: data.id,
        sortKey: sortKey,
        isTop: false,
        page: 1,
        isNew: true,
        isShow: false,
      ));
    } else {
      final isNew = _book.isNew == true ||
          lastChapter != _book.lastChapter && lastTime != _book.updateTime;

      final book = BookCache(
          lastChapter: lastChapter,
          updateTime: lastTime,
          name: name,
          img: img,
          isNew: isNew);

      // final x =
      updateBook(bookId, book);
      // assert(Log.w('update ${await x}'));
    }
    return null;
  }

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

  FutureOr<List<BookCache>> getBookCacheDb(int bookid) =>
      bookCache.query.where.bookId.equalTo(bookid).back.whereEnd.goToTable;
}
