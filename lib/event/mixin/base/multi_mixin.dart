import 'dart:async';
import 'dart:convert';

import 'package:lpinyin/lpinyin.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:utils/future_or_ext.dart';

import '../../../data/data.dart';
import '../../../database/database.dart';
import '../../../database/nop_database.dart';
import '../../base/book_event.dart';
import 'database_mixin.dart';
import 'zhangdu_mixin.dart';

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

/// database: zhangdu
mixin ZhangduComplexOnDatabaseMixin
    on DatabaseMixin, ZhangduDatabaseMixin
    implements ServerEvent {
  @override
  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData detailData) async {
    final data = ZhangduCache(
      name: detailData.name,
      picture: detailData.picture,
      pinyin: detailData.pinyin,
      chapterUpdateTime: detailData.chapterUpdateTime,
      chapterName: detailData.chapterName,
      chapterId: firstChapterId,
      bookId: detailData.id,
      sortKey: sortKey,
      page: 1,
      isTop: false,
      isNew: true,
      isShow: false,
    );

    final exists = (await insertZhangduBook(data)) == -1;

    if (exists) {
      await updateZhangduBook(
          detailData.id ?? bookId,
          ZhangduCache(
            chapterName: detailData.chapterName,
            chapterUpdateTime: detailData.chapterUpdateTime,
            name: detailData.name,
            // pinyin: detailData.pinyin,
            picture: detailData.picture,
          ));
    }
  }

  @override
  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    final query = zhangduIndex.query
      ..data
      ..where.bookId.equalTo(bookId);

    return query.goToTable.then((go) {
      if (go.isNotEmpty) {
        final data = go.last.data;
        if (data != null) {
          List<ZhangduChapterData>? chapterData;
          try {
            chapterData = ZhangduChapter.fromJson(jsonDecode(data)).data;
          } catch (e) {
            Log.e(e);
          }
          return chapterData;
        }
      }
    });
  }

  @override
  FutureOr<int> insertOrUpdateZhangduContent(ZhangduContent content) async {
    assert(content.bookId != null && content.contentId != null);
    var count = 0;
    final query = zhangduContent.query
      ..select.count.all.push
      ..where.bookId.equalTo(content.bookId!).and
      ..where.contentId.equalTo(content.contentId!);
    count = await query.go.first.values.first as int? ?? 0;
    if (count > 0) {
      final update = zhangduContent.update
        ..data.set(content.data)
        ..name.set(content.name)
        ..sort.set(content.sort)
        ..where.bookId.equalTo(content.bookId!).and
        ..where.contentId.equalTo(content.contentId!);
      final go = update.go;
      return go;
    } else {
      final insert = zhangduContent.insert.insertTable(content);
      final go = insert.go;
      updateZhangduIndexCacheLength(content.bookId!);
      return go;
    }
  }

  Future<void> updateZhangduIndexCacheLength(int bookId) async {
    final cacheLength = await getZhangduContentCid(bookId) ?? 0;
    final update = zhangduIndex.update.cacheItemCounts.set(cacheLength)
      ..where.bookId.equalTo(bookId);
    await update.go;
  }

  @override
  FutureOr<int?> getZhangduContentCid(int bookid) {
    final q = zhangduContent.query
      ..select.count.all.push
      ..where.bookId.equalTo(bookid);
    return q.go.first.values.first.then((value) => value as int?);
  }

  @override
  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    final query = zhangduContent.query.data
      ..where.bookId.equalTo(bookId).and.contentId.equalTo(contentId);

    return query.goToTable.then((all) {
      List<String>? data;
      if (all.isNotEmpty) {
        assert(
            all.length <= 1 || Log.e('content $bookId count: ${all.length}'));
        final raw = all.last.data;
        if (raw != null) {
          final _raw = ZhangduComplexMixin.replaceAll(raw);
          data = ZhangduComplexMixin.splitSource(_raw);
        }
      }
      return data;
    });
  }

  @override
  FutureOr<int> insertOrUpdateZhangduIndex(int bookId, String data) {
    final query = zhangduIndex.query
      ..select.count.all.push
      ..where.bookId.equalTo(bookId);
    return query.go.first.values.first.then((value) {
      final count = value as int? ?? 0;
      final itemCounts = _computeZdIndexLength(data);
      if (count > 0) {
        final update = zhangduIndex.update
          ..data.set(data).itemCounts.set(itemCounts)
          ..where.bookId.equalTo(bookId);
        return update.go;
      } else {
        final insert = zhangduIndex.insert.insertTable(
            ZhangduIndex(bookId: bookId, data: data, itemCounts: itemCounts));
        return insert.go;
      }
    });
  }

  int _computeZdIndexLength(String data) {
    var itemCounts = 0;
    try {
      final indexs = ZhangduChapter.fromJson(jsonDecode(data));
      final list = indexs.data;
      itemCounts = list?.length ?? 0;
    } catch (e) {
      Log.e(e);
    }
    return itemCounts;
  }
}
