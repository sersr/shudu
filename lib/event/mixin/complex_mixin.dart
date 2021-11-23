import 'dart:async';

import 'package:useful_tools/useful_tools.dart';

import '../../api/api.dart';
import '../../data/data.dart';
import '../../database/nop_database.dart';
import '../../pages/book_list/cache_manager.dart';
import '../base/book_event.dart';
import '../base/complex_event.dart';
import 'network_mixin.dart';

/// 复合任务
/// 处理复杂任务

mixin ComplexMixin on NetworkMixin
    implements
        ComplexOnDatabaseEvent,
        ComplexEvent /* override 提示 */,
        CustomEventDynamic {
  @override
  Future<Uint8ListType> getImageBytesDynamic(String img) async {
    final data = await getImageBytes(img);
    return Uint8ListType(data);
  }

  @override
  Future<int> updateBookStatus(int id) async {
    await getInfo(id);
    return 0;
  }

  @override
  Future<BookInfoRoot> getInfo(int id) async {
    final rootData = await getInfoNet(id);
    final data = rootData.data;
    if (data != null) insertOrUpdateBook(data);

    return rootData;
  }

  @override
  Future<List<CacheItem>> getCacheItems() async {
    final list = <CacheItem>[];
    final stop = Stopwatch()..start();
    var queryList = await getIndexsDbCacheItem();
    var map =
        queryList?.asMap().map((key, value) => MapEntry(value.bookId, value)) ??
            const <int?, BookIndex>{};

    var allBookids = await getAllBookId() ?? <int>{};

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

  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, bool update) async {
    final url = Api.contentUrl(bookid, contentid);
    assert(Log.i('url: $url'));

    if (update) {
      return await _getContentNet(bookid, contentid) ??
          await _getContentDb(bookid, contentid) ??
          RawContentLines.none;
    } else {
      return await _getContentDb(bookid, contentid) ??
          await _getContentNet(bookid, contentid) ??
          RawContentLines.none;
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
    final db = await getIndexsDb(bookid) ?? const [];
    if (db.isEmpty || db.last.bIndexs == null) return const NetBookIndex();
    return getIndexsDecodeLists(db.last.bIndexs!);
  }

  Future<RawContentLines?> _getContentNet(int bookid, int contentid) async {
    Api.moveNext();

    final bookContent = await getContentNet(bookid, contentid);

    if (bookContent.content != null) {
      // final lines = split(bookContent.content!);

      // if (lines.isNotEmpty) {
      insertOrUpdateContent(bookContent);
      return RawContentLines(
        source: bookContent.content!,
        nid: bookContent.nid,
        pid: bookContent.pid,
        cid: bookContent.cid,
        hasContent: bookContent.hasContent,
        cname: bookContent.cname,
      );
      // }
    }
    return null;
  }

  Future<RawContentLines?> _getContentDb(int bookid, int contentid) async {
    final queryList = await getContentDb(bookid, contentid);
    if (queryList?.isNotEmpty == true) {
      final bookContent = queryList!.last;
      if (bookContent.content != null) {
        // final lines = split(bookContent.content!);
        // if (lines.isNotEmpty) {
        return RawContentLines(
          source: bookContent.content!,
          nid: bookContent.nid,
          pid: bookContent.pid,
          cid: bookContent.cid,
          hasContent: bookContent.hasContent,
          cname: bookContent.cname,
        );
        // }
      }
    }
    return null;
  }
}
