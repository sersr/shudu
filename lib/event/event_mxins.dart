import 'dart:convert';

import '../api/api.dart';

import '../pages/book_list_view/cacheManager.dart';

import '../data/book_content.dart';
import '../database/database_mixin.dart';
import '../utils/utils.dart';
import 'book_event.dart';
import 'isolate_side.dart';

mixin ComputeEvent {
  Future<List<String>> textLayout(String text) async =>
      LineSplitter.split(text).toList();
}

/// 复合任务
/// 处理复杂任务
mixin ComplexEvent on DatabaseMixin, NetwrokEvent, ComputeEvent {
  @override
  Future<CacheItem> getCacheItem(int id) async {
    var cacheListRaw = await getCacheContentsCidDb(id);
    final cacheItemCounts = cacheListRaw.length;

    int? itemCounts;
    var queryList = await getIndexsDb(id);

    if (queryList.isNotEmpty) {
      final restr = queryList.first['bIndexs'] as String?;

      if (restr != null) {
        final indexs = await getIndexsDecodeLists(restr);
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
    Log.i('db: $url');
    Api.moveNext();
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

  Future<RawContentLines?> _getContentNet(int bookid, int contentid) async {
    assert(Log.i('loading Id: $contentid'));

    final bookContent = await getContentNet(bookid, contentid);

    if (bookContent.content != null) {
      saveContent(bookContent);
      final lines = await textLayout(bookContent.content!);

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
    final queryList = await getContentDb(bookid, contentid);
    if (queryList.isNotEmpty) {
      final map = queryList.first;
      final bookContent = BookContent.fromJson(map);
      if (bookContent.content != null) {
        final lines = await textLayout(bookContent.content!);
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
