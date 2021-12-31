import 'dart:async';
import 'dart:convert';

import 'package:useful_tools/useful_tools.dart';

import '../../../api/api.dart';
import '../../../data/data.dart';
import '../../base/book_event.dart';

/// 可以处理跨隔离任务
mixin ComplexMixin implements ComplexEvent, ServerEvent, ServerNetEvent {
  @override
  FutureOr<BookInfoRoot?> getInfo(int id) async {
    final rootData = await getInfoNet(id);
    final data = rootData?.data;
    if (data != null) insertOrUpdateBook(data);

    return rootData;
  }

  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, bool update) async {
    final url = Api.contentUrl(bookid, contentid);
    assert(Log.i('url: $url'));

    if (update) {
      return await _getContentNet(bookid, contentid) ??
          await getContentDb(bookid, contentid) ??
          RawContentLines.none;
    } else {
      return await getContentDb(bookid, contentid) ??
          await _getContentNet(bookid, contentid) ??
          RawContentLines.none;
    }
  }

  @override
  Future<NetBookIndex?> getIndexs(int bookid, bool update) async {
    if (update) {
      return _getIndexsNet(bookid);
    } else {
      final db = await _getIndexsDb(bookid);
      if (db.list?.isNotEmpty != true) return _getIndexsNet(bookid);
      return db;
    }
  }

  NetBookIndex getIndexsDecodeLists(args) {
    try {
      return BookIndexRoot.fromJson(jsonDecode(args)).data ??
          const NetBookIndex();
    } catch (e) {
      Log.e('url:$args, $e');
      rethrow;
    }
  }

  Future<NetBookIndex?> _getIndexsNet(int bookid) async {
    final str = await getIndexsNet(bookid);
    if (str != null) {
      insertOrUpdateIndexs(bookid, str);
      return getIndexsDecodeLists(str);
    }
    return null;
  }

  Future<NetBookIndex> _getIndexsDb(bookid) async {
    final db = await getIndexsDb(bookid) ?? const [];
    if (db.isEmpty || db.last.bIndexs == null) return const NetBookIndex();
    return getIndexsDecodeLists(db.last.bIndexs!);
  }

  Future<RawContentLines?> _getContentNet(int bookid, int contentid) async {
    Api.moveNext();

    final bookContent = await getContentNet(bookid, contentid);

    if (bookContent?.content != null) {
      final lines = LineSplitter.split(bookContent!.content!).toList();

      insertOrUpdateContent(bookContent);
      return RawContentLines(
        source: lines,
        nid: bookContent.nid,
        pid: bookContent.pid,
        cid: bookContent.cid,
        hasContent: bookContent.hasContent,
        cname: bookContent.cname,
      );
    }
    return null;
  }

  // zhangdu
  // @override
  // FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
  //     String contentUrl, String name, int sort, bool update) async {
  //   if (update) {
  //     return await _getZhangduContentNet(
  //             bookId, contentId, name, sort, contentUrl) ??
  //         await getZhangduContentDb(bookId, contentId);
  //   } else {
  //     return await getZhangduContentDb(bookId, contentId) ??
  //         await _getZhangduContentNet(
  //             bookId, contentId, name, sort, contentUrl);
  //   }
  // }

  // Future<List<String>?> _getZhangduContentNet(int bookId, int contentId,
  //     String name, int sort, String contentUrl) async {
  //   final result = await getZhangduContentNet(contentUrl);
  //   if (result != null) {
  //     final _raw = ZhangduComplexMixin.replaceAll(result);
  //     insertOrUpdateZhangduContent(ZhangduContent(
  //       bookId: bookId,
  //       contentId: contentId,
  //       name: name,
  //       data: result,
  //       sort: sort,
  //     ));
  //     return split(_raw);
  //   }
  // }
}
