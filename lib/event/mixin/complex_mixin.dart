import 'dart:convert';
import 'dart:isolate';

import '../../api/api.dart';
import '../../data/data.dart';
import '../../database/nop_database.dart';
import '../../pages/book_list_view/cacheManager.dart';
import '../../utils/utils.dart';
import '../base/book_event.dart';
import 'database_mixin.dart';
import 'network_impl.dart';

/// 复合任务
/// 处理复杂任务
mixin ComplexMixin
    on DatabaseMixin, NetworkMixin
    implements ComplexEventDynamic {
  // 频率过高，会被暂时禁止访问
  @override
  Future<TransferableTypedData?> getContentDynamic(
      int bookid, int contentid, bool update) async {
    return getContent(bookid, contentid, update).then(RawContentLines.encode);
  }

  @override
  Future<int> updateBookStatus(int id) async {
    final rawData = await getInfo(id);
    final data = rawData.data;

    if (data != null) {
      final newCname = data.lastChapter;
      final lastTime = data.lastTime;
      if (newCname != null && lastTime != null) {
        return updateBookStatusImpl(id, newCname, lastTime);
      }
    }
    return 0;
  }

  @override
  Future<BookInfoRoot> getInfo(int id) async {
    final rawData = await getInfoNet(id);
    final data = rawData.data;

    if (data != null) {
      final newCname = data.lastChapter;
      final lastTime = data.lastTime;
      if (newCname != null && lastTime != null) {
        updateBookStatusImpl(id, newCname, lastTime);
      }
    }
    return rawData;
  }

  @override
  CacheItem getCacheItem(int id) {
    var cacheListRaw = getCacheContentsCidDb(id);
    final cacheItemCounts = cacheListRaw.length;

    int? itemCounts;
    var queryList = getIndexsDb(id);

    if (queryList.isNotEmpty) {
      final restr = queryList.last.bIndexs;

      if (restr != null) {
        final indexs = getIndexsDecodeLists(restr);
        if (indexs.isNotEmpty) {
          final _num = indexs.fold<int>(0,
              (previousValue, element) => previousValue + element.length - 1);
          itemCounts = _num;
        }
      }
    }

    itemCounts ??= cacheItemCounts;
    return CacheItem(id, itemCounts, cacheItemCounts);
  }

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
      final a = await _getContentDb(bookid, contentid) ??
          await _getContentNet(bookid, contentid) ??
          const RawContentLines();

      return a;
    }
  }

  @override
  Future<List<List>> getIndexs(int bookid, bool update) async {
    if (update) {
      return _getIndexsNet(bookid);
    } else {
      final db = _getIndexsDb(bookid);
      if (db.isEmpty) return _getIndexsNet(bookid);
      return db;
    }
  }

  Future<List<List>> _getIndexsNet(int bookid) async {
    final str = await getIndexsNet(bookid);
    insertOrUpdateIndexs(bookid, str);
    return getIndexsDecodeLists(str);
  }

  List<List> _getIndexsDb(bookid) {
    final db = getIndexsDb(bookid);
    if (db.isEmpty || db.last.bIndexs == null) return const [];
    return getIndexsDecodeLists(db.last.bIndexs!);
  }

  Future<RawContentLines?> _getContentNet(int bookid, int contentid) async {
    // assert(Log.i('loading Id: $contentid'));
    Api.moveNext();

    final bookContent = await getContentNet(bookid, contentid);

    if (bookContent.content != null) {
      saveContent(bookContent);
      final lines = textLayout(bookContent.content!);

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
    return null;
  }

  Future<RawContentLines?> _getContentDb(int bookid, int contentid) async {
    final queryList = getContentDb(bookid, contentid);
    if (queryList.isNotEmpty) {
      final bookContent = queryList.last;
      if (bookContent.content != null) {
        final lines = textLayout(bookContent.content!);
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

// internal
extension _ComputeEvent on ComplexMixin {
  List<String> textLayout(String text) => LineSplitter.split(text).toList();
}

extension _Database on ComplexMixin {
  void saveContent(BookContentDb bookContent) =>
      insertOrUpdateContent(bookContent);
}
