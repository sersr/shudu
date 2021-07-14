import 'dart:convert';

import 'package:lpinyin/lpinyin.dart';

import '../../api/api.dart';
import '../../data/data.dart';
import '../../database/nop_database.dart';
import '../../pages/book_list_view/cacheManager.dart';
import '../../utils/utils.dart';
import '../base/book_event.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';

/// 复合任务
/// 处理复杂任务
mixin ComplexMixin
    on DatabaseMixin, NetworkMixin
    implements ComplexEventDynamic {
  @override
  Future getContentDynamic(int bookid, int contentid, bool update) {
    return getContent(bookid, contentid, update);
    // .then(RawContentLines.encode);
  }

  @override
  Future<int> updateBookStatus(int id) async {
    await getInfo(id);
    return 0;
  }

  @override
  Future<BookInfoRoot> getInfo(int id) async {
    final rawData = await getInfoNet(id);

    final data = rawData.data;
    final mainBook = getBookCacheDb(id);

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
      final img =
          data.img ?? '${PinyinHelper.getPinyinE('$name', separator: '')}.jpg';
      Log.e(img);
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
        final isNew =
            lastChapter != _book.lastChapter && lastTime != _book.updateTime;

        final book = BookCache(
            lastChapter: lastChapter,
            updateTime: lastTime,
            name: name,
            img: img,
            isNew: isNew);

        final x = updateBook(id, book);
        Log.w('update $x');
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
        final list = indexs.list;
        var count = 0;
        if (list != null && list.isNotEmpty) {
          for (var item in list) count += item.list?.length ?? 0;

          // final _num = list.fold<int>(
          //     0, (previousValue, element) => previousValue + element.list - 1);
          itemCounts = count;
        }
      }
    }

    itemCounts ??= cacheItemCounts;
    return CacheItem(id, itemCounts, cacheItemCounts);
  }

  @override
  Map<int, CacheItem> getCacheItemAll() {
    var cacheListRaw = getCacheContentsCidDbALl();

    var queryList = getIndexsDbAll().reversed.toList();
    final _map = <int, CacheItem>{};

    queryList.forEach((index) {
      final bookId = index.bookId;
      final bIndexs = index.bIndexs;
      if (bookId != null && bIndexs != null) {
        final cacheItemCounts =
            cacheListRaw.where((element) => element.bookId == bookId).length;
        var itemCounts = cacheItemCounts;

        final indexs = getIndexsDecodeLists(bIndexs);
        final list = indexs.list;
        var count = 0;
        if (list != null && list.isNotEmpty) {
          for (var item in list) count += item.list?.length ?? 0;

          // final _num = list.fold<int>(
          //     0, (previousValue, element) => previousValue + element.list - 1);
          itemCounts = count;
        }
        _map.putIfAbsent(
            bookId, () => CacheItem(bookId, itemCounts, cacheItemCounts));
      }
    });
    return _map;
  }

  List<BookContentDb> getCacheContentsCidDbALl() {
    late List<BookContentDb> l;

    bookContentDb.query.bookId..let((s) => l = s.goToTable);

    return l;
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
  Future<NetBookIndex> getIndexs(int bookid, bool update) async {
    if (update) {
      return _getIndexsNet(bookid);
    } else {
      final db = _getIndexsDb(bookid);
      if (db.list?.isNotEmpty != true) return _getIndexsNet(bookid);
      return db;
    }
  }

  Future<NetBookIndex> _getIndexsNet(int bookid) async {
    final str = await getIndexsNet(bookid);
    insertOrUpdateIndexs(bookid, str);
    return getIndexsDecodeLists(str);
  }

  NetBookIndex _getIndexsDb(bookid) {
    final db = getIndexsDb(bookid);
    if (db.isEmpty || db.last.bIndexs == null) return const NetBookIndex();
    return getIndexsDecodeLists(db.last.bIndexs!);
  }

  Future<RawContentLines?> _getContentNet(int bookid, int contentid) async {
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
