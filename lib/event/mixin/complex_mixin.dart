import 'dart:async';
import 'dart:isolate';

import 'package:lpinyin/lpinyin.dart';
import 'package:nop_db/extensions/future_or_ext.dart';
import 'package:useful_tools/common.dart';

import '../../api/api.dart';
import '../../data/data.dart';
import '../../database/nop_database.dart';
import '../../pages/book_list/cache_manager.dart';
import '../base/book_event.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';

/// 复合任务
/// 处理复杂任务
mixin ComplexMixin
    on DatabaseMixin, NetworkMixin
    implements
        ComplexEvent /*显示 override */,
        ComplexEventDynamic,
        CustomEventDynamic {
  @override
  Future getContentDynamic(int bookid, int contentid, bool update) {
    return getContent(bookid, contentid, update).then(RawContentLines.encode);
  }

  @override
  Future<dynamic> getImageBytesDynamic(String img) async {
    final data = await getImageBytes(img);
    if (data != null) {
      return TransferableTypedData.fromList([data]);
    }
  }

  @override
  Future<int> updateBookStatus(int id) async {
    await getInfo(id);
    return 0;
  }

  @override
  Future<BookInfoRoot> getInfo(int id) async {
    final _getInfoNet = getInfoNet(id);

    final mainBook = await getBookCacheDb(id);
    final rawData = await _getInfoNet;
    final data = rawData.data;

    if (data != null) {
      BookCache? book;
      mainBook.any((e) {
        final equal = e.bookId == id;
        if (equal) book = e;
        return equal;
      });

      final lastChapter = data.lastChapter;
      final lastTime = data.lastTime;

      final name = data.name;
      final img = data.img ??
          '${PinyinHelper.getPinyinE(name ?? '', separator: '')}.jpg';

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

        final x = updateBook(id, book);
        assert(Log.w('update ${await x}'));
      }
    }
    return rawData;
  }

  @override
  Future<CacheItem> getCacheItem(int id) async {
    // int? cacheItemCounts;
    // = await getCacheContentsCidDb(id) ?? 0;

    var queryList = await getIndexsDbCacheItemBookid(id);

    if (queryList.isNotEmpty) {
      final restr = queryList.last;
      final itemCounts = restr.itemCounts;
      final cacheItemCounts = restr.cacheItemCounts ?? 0;
      if (itemCounts != null) {
        return CacheItem(id, itemCounts, cacheItemCounts);
      }
    }
    return CacheItem(id, 0, 0);
  }

  @override
  Future<List<CacheItem>> getCacheItems() async {
    final list = <CacheItem>[];
    // var allCacheItems = await getIndexsDbCacheItem();
    final stop = Stopwatch()..start();
    var queryList = await getIndexsDbCacheItem();
    var map =
        queryList.asMap().map((key, value) => MapEntry(value.bookId, value));

    var allBookids = await getAllBookId();
    for (var a in allBookids) {
      // Log.w('count: $a', onlyDebug: false);

      final index = map[a];
      // final item = await getCacheItem(bookid);
      // var cacheItemCounts = await getCacheContentsCidDb(a.bookId!);
      // final itemCounts = a.itemCounts ?? cacheItemCounts ?? 0;
      // cacheItemCounts ??= itemCounts;
      // final item = CacheItem(a.bookId!, itemCounts, cacheItemCounts);
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

  // @override
  // Future<Map<int, CacheItem>> getCacheItemAll() async {
  //   var cacheListRaw = await getCacheContentsCidDb(id);

  //   var queryList = (await getIndexsDbAll()).reversed.toList();
  //   final _map = <int, CacheItem>{};

  //   for (var index in queryList) {
  //     final bookId = index.bookId;
  //     final itemCounts = index.itemCounts;
  //     final cacheItemCounts = await cacheListRaw.cacheItemCounts;
  //     if (bookId != null && cacheItemCounts != null && itemCounts != null) {
  //       _map.putIfAbsent(
  //           bookId, () => CacheItem(bookId, itemCounts, cacheItemCounts));
  //     }
  //   }
  //   return _map;
  // }

  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, bool update) async {
    final url = Api.contentUrl(bookid, contentid);
    Log.i('url: $url');

    if (update) {
      return await _getContentNet(bookid, contentid) ??
          await _getContentDb(bookid, contentid) ??
          const RawContentLines();
    } else {
      return await _getContentDb(bookid, contentid) ??
          await _getContentNet(bookid, contentid) ??
          const RawContentLines();
    }
  }

  @override
  Future<NetBookIndex> getIndexs(int bookid, bool update) async {
    if (update) {
      return _getIndexsNet(bookid);
    } else {
      final db = await _getIndexsDb(bookid);
      if (db.list?.isNotEmpty != true) return _getIndexsNet(bookid);
      return db;
    }
  }

  Future<NetBookIndex> _getIndexsNet(int bookid) async {
    final str = await getIndexsNet(bookid);
    insertOrUpdateIndexs(bookid, str);
    return getIndexsDecodeLists(str);
  }

  Future<NetBookIndex> _getIndexsDb(bookid) async {
    final db = await getIndexsDb(bookid);
    if (db.isEmpty || db.last.bIndexs == null) return const NetBookIndex();
    return getIndexsDecodeLists(db.last.bIndexs!);
  }

  Future<RawContentLines?> _getContentNet(int bookid, int contentid) async {
    Api.moveNext();

    final bookContent = await getContentNet(bookid, contentid);

    if (bookContent.content != null) {
      final lines = split(bookContent.content!);

      if (lines.isNotEmpty) {
        insertOrUpdateContent(bookContent);
        return RawContentLines(
          pages: lines,
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

  Future<RawContentLines?> _getContentDb(int bookid, int contentid) async {
    final queryList = await getContentDb(bookid, contentid);
    if (queryList.isNotEmpty) {
      final bookContent = queryList.last;
      if (bookContent.content != null) {
        final lines = split(bookContent.content!);
        if (lines.isNotEmpty) {
          return RawContentLines(
            pages: lines,
            nid: bookContent.nid,
            pid: bookContent.pid,
            cid: bookContent.cid,
            hasContent: bookContent.hasContent,
            cname: bookContent.cname,
          );
        }
      }
    }
    return null;
  }
}
