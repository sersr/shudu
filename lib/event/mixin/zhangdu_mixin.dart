import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:utils/future_or_ext.dart';

import '../../api/api.dart';
import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../data/zhangdu/zhangdu_same_users_books.dart';
import '../../data/zhangdu/zhangdu_search.dart';
import '../../database/nop_database.dart';
import '../../pages/book_list/cache_manager.dart';
import '../../provider/book_index_notifier.dart';
import '../base/complex_event.dart';
import '../base/zhangdu_event.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';

mixin ZhangduComplexMixin on HiveDioMixin
    implements ComplexOnDatabaseEvent, ZhangduComplexEvent {
  @override
  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) async {
    if (update) {
      return await _getContentNet(bookId, contentId, name, sort, contentUrl) ??
          await getZhangduContentDb(bookId, contentId);
    } else {
      return await getZhangduContentDb(bookId, contentId) ??
          await _getContentNet(bookId, contentId, name, sort, contentUrl);
    }
  }

  @override
  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    return getZhangduDetail(bookId).then((_) => 0);
  }

  static String _replaceAll(String source) {
    return source
        .replaceAll(RegExp(r'<br\s*/>'), '\n')
        .replaceAll(RegExp('&nbsp;|<.*>'), '')
        .replaceAll(RegExp('(&ldquo;)|(&rdquo;)'), '"');
  }

  static List<String> _split(String source) {
    return split(source).map((e) {
      if (!e.startsWith('\u3000\u3000')) {
        return '\u3000\u3000$e';
      }
      return e;
    }).toList();
  }

  Future<List<String>?> _getContentNet(int bookId, int contentId, String name,
      int sort, String contentUrl) async {
    List<String>? data;
    try {
      final response = await dio.get<String>(contentUrl);
      final result = response.data;
      if (result != null) {
        final _raw = _replaceAll(result);
        data = _split(_raw);
        insertOrUpdateZhangduContent(ZhangduContent(
          bookId: bookId,
          contentId: contentId,
          name: name,
          data: result,
          sort: sort,
        ));
      }
    } catch (e) {
      if (e is DioError) {
        Log.e(e);
        if (e.type == DioErrorType.response &&
            e.response?.statusCode == HttpStatus.notFound) {
          return const [];
        }
      } else {
        Log.i(e);
      }
    }
    return data;
  }

  final _caches = <int, _ZhangduDetailChapterCache>{};
  static const int updateInterval = 1000 * 30;

  _ZhangduDetailChapterCache addArchive(int bookId,
      ZhangduDetailData detailData, List<ZhangduChapterData> chapterData) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = _ZhangduDetailChapterCache(detailData, chapterData, now);
    autoClear();
    _caches[bookId] = data;
    return data;
  }

  _ZhangduDetailChapterCache? getData(int bookId) {
    return _caches[bookId];
  }

  Timer? _autoClear;
  void autoClear() {
    _autoClear ??=
        Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      removeExpired();
      if (_caches.isEmpty) {
        timer.cancel();
        _autoClear = null;
      }
    });
  }

  void removeExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _caches.removeWhere((_, value) => value.timePoint + updateInterval <= now);
  }

  /// 相同的[bookId]在一个队列中
  Future<_ZhangduDetailChapterCache?> autoUpdate(int bookId) {
    return EventQueue.runTaskOnQueue(
        [_autoUpdate, bookId], () => _autoUpdate(bookId));
  }

  Future<_ZhangduDetailChapterCache?> _autoUpdate(int bookId) async {
    final data = getData(bookId);
    if (data != null) return data;

    final url = ZhangduApi.getBookIndexDetail(bookId);
    try {
      final result = await dio.get<List<int>>(url,
          options: Options(responseType: ResponseType.bytes));
      final data = result.data;
      if (data != null) {
        final z = ZipDecoder().decodeBytes(data);
        ZhangduDetailData? detailData;
        List<ZhangduChapterData>? chapterData;
        String? indexData;
        int errorCount = 0;
        for (var file in z) {
          if (file.isFile) {
            final bytes = file.content as List<int>;
            final dataString = utf8.decode(bytes);
            final data = jsonDecode(dataString);
            if (detailData == null) {
              try {
                detailData = ZhangduDetail.fromJson(data).data;
                if (detailData != null) continue;
              } catch (e) {
                errorCount++;
                if (errorCount > 1) Log.w(e);
              }
            }
            if (chapterData == null) {
              try {
                Log.i(' a ...${file.name}');

                chapterData = ZhangduChapter.fromJson(data).data;
                if (chapterData != null) {
                  indexData = dataString;
                }
              } catch (e) {
                errorCount++;
                if (errorCount > 1) Log.w('errorCount: $errorCount\n$e');
              }
            }
          }
        }
        if (detailData != null && chapterData != null) {
          final chapterId =
              chapterData.isNotEmpty ? chapterData.first.id ?? -1 : -1;

          await insertOrUpdateZhangduBook(bookId, chapterId, detailData);
          await insertOrUpdateZhangduIndex(detailData.id ?? bookId, indexData!);

          return addArchive(bookId, detailData, chapterData);
        }
      }
    } catch (e) {
      Log.w('error: $e');
    }
  }

  @override
  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) async {
    final data = await autoUpdate(bookId);
    if (data != null) {
      return data.detailData;
    }
    return const ZhangduDetailData();
  }

  @override
  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(
      int bookId, bool update) async {
    if (update) {
      return await _getZhangduIndex(bookId) ??
          _getZhangduIndexDb(bookId) ??
          const [];
    }
    return await _getZhangduIndexDb(bookId) ??
        await _getZhangduIndex(bookId) ??
        const [];
  }

  FutureOr<List<ZhangduChapterData>?> _getZhangduIndex(int bookId) async {
    final data = await autoUpdate(bookId);
    if (data != null) {
      return data.chapterData;
    }
  }

  FutureOr<List<ZhangduChapterData>?> _getZhangduIndexDb(int bookId) {
    final data = getData(bookId);
    if (data != null) return data.chapterData;
    return getZhangduIndexDb(bookId);
  }
}

class _ZhangduDetailChapterCache {
  _ZhangduDetailChapterCache(this.detailData, this.chapterData, this.timePoint);
  ZhangduDetailData detailData;
  List<ZhangduChapterData> chapterData;
  final int timePoint;
}

mixin ZhangduDatabaseMixin on DatabaseMixin implements ZhangduDatabaseEvent {
  late final zhangduCache = db.zhangduCache;
  late final zhangduContent = db.zhangduContent;
  late final zhangduIndex = db.zhangduIndex;

  @override
  FutureOr<int?> deleteZhangduBook(int bookId) {
    return zhangduCache.delete.where.bookId.equalTo(bookId).back.whereEnd.go;
  }

  @override
  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    return zhangduContent.delete.where.bookId.equalTo(bookId).back.whereEnd.go;
  }

  @override
  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    final query = zhangduCache.query;
    assert(book.bookId != null);
    query
      ..select.count.all.push
      ..where.bookId.equalTo(book.bookId!);
    return query.go.then((go) {
      FutureOr<int> count = go.first.values.first as int? ?? 0;
      if (count == 0) return zhangduCache.insert.insertTable(book).go;
      return -1;
    });
  }

  FutureOr<List<ZhangduCache>?> getZhangduCacheBookId(int bookId) {
    return zhangduCache.query.all.where.bookId
        .equalTo(bookId)
        .back
        .whereEnd
        .goToTable;
  }

  @override
  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    return getZhangduCacheBookId(bookId).then((list) {
      var isNew = false;
      if (list?.isNotEmpty == true) {
        final cache = list!.last;
        final bChapterName = book.chapterName;
        isNew = cache.isNew == true || cache.chapterName != bChapterName;

        // Log.i('$isNew  ${cache.toJson()} | ${book.toJson()}', onlyDebug: false);
      }
      book.isNew ??= isNew;
      final update = zhangduCache.update..where.bookId.equalTo(bookId);
      zhangduCache.updateZhangduCache(update, book);
      return update.go;
    });
  }

  @override
  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    final query = zhangduContent.query..contentId.where.bookId.equalTo(bookId);
    return query.watchToTable.map(
        (event) => event.map((e) => e.contentId).whereType<int>().toList());
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    final query = zhangduCache.query
      ..chapterId.bookId.where.bookId.equalTo(bookId);
    return query.watchToTable;
  }

  @override
  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    return zhangduCache.query.goToTable;
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return zhangduCache.query.all.watchToTable;
  }

  FutureOr<Set<int>> getZdAllBookId() async {
    final query = zhangduCache.query.bookId;
    return query.goToTable
        .then((value) => value.map((e) => e.bookId).whereType<int>().toSet());
  }

  FutureOr<List<ZhangduIndex>> getZdIndexsDbCacheItem() {
    final q = zhangduIndex.query.itemCounts.cacheItemCounts.bookId;
    return q.goToTable;
  }

  @override
  FutureOr<List<CacheItem>?> getZhangduCacheItems() async {
    final list = <CacheItem>[];
    final queryData = await getZdIndexsDbCacheItem();
    var map =
        queryData.asMap().map((key, value) => MapEntry(value.bookId, value));
    final allBookIds = await getZdAllBookId();
    for (var id in allBookIds) {
      final index = map[id];
      final itemCounts = index?.itemCounts;
      if (itemCounts != null) {
        final item = CacheItem(id, itemCounts, index?.cacheItemCounts ?? 0,
            api: ApiType.zhangdu);
        list.add(item);
      } else {
        list.add(CacheItem(id, 0, 0, api: ApiType.zhangdu));
      }
    }
    return list;
  }
}

mixin ZhangduNetMixin on HiveDioMixin implements ZhangduNetEvent {
  @override
  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) async {
    try {
      final url = ZhangduApi.sameUsersBooks(author);
      final response = await dio.get<String>(url);
      return ZhangduSameUsersBooks.fromJson(jsonDecode(response.data!)).data ??
          const [];
    } catch (e) {
      Log.w(e);
    }
    return const [];
  }

  @override
  Future<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) async {
    final url = ZhangduApi.searchUrl(query, pageIndex, pageSize);
    try {
      final response = await dio.get<String>(url);
      return ZhangduSearch.fromJson(jsonDecode(response.data!)).data ??
          const ZhangduSearchData();
    } catch (e) {
      Log.e(e);
    }
  }
}

mixin ZhangduComplexOnDatabaseMixin
    on DatabaseMixin, ZhangduDatabaseMixin
    implements ComplexOnDatabaseEvent {
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
          final _raw = ZhangduComplexMixin._replaceAll(raw);
          data = ZhangduComplexMixin._split(_raw);
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
      final itemCounts = _computeIndexLength(data);
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

  int _computeIndexLength(String data) {
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
