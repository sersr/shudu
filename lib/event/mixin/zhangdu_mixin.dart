import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:nop_db/extensions/future_or_ext.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../api/api.dart';
import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../data/zhangdu/zhangdu_same_users_books.dart';
import '../../data/zhangdu/zhangdu_search.dart';
import '../../database/nop_database.dart';
import '../base/zhangdu_event.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';

mixin ZhangduEventMixin on DatabaseMixin, NetworkMixin implements ZhangduEvent {
  late final zhangduCache = db.zhangduCache;
  late final zhangduContent = db.zhangduContent;
  late final zhangduIndex = db.zhangduIndex;

  @override
  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) async {
    if (update) {
      return await _getContentNet(bookId, contentId, name, sort, contentUrl) ??
          await _getContentDb(bookId, contentId);
    } else {
      return await _getContentDb(bookId, contentId) ??
          await _getContentNet(bookId, contentId, name, sort, contentUrl);
    }
  }

  Future<List<String>?> _getContentNet(int bookId, int contentId, String name,
      int sort, String contentUrl) async {
    List<String>? data;
    try {
      final response = await dio.get<String>(contentUrl);
      final result = response.data;
      if (result != null) {
        final _raw = result
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'<br\s*/>'), '\n');
        data = split(_raw);
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
        ..where.bookId.equalTo(content.bookId!)
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

  FutureOr<int?> getZhangduContentCid(int bookid) {
    final q = zhangduContent.query
      ..select.count.all.push
      ..where.bookId.equalTo(bookid);
    return q.go.first.values.first.then((value) => value as int?);
  }

  FutureOr<List<String>?> _getContentDb(int bookId, int contentId) {
    final query = zhangduContent.query.data
      ..where.bookId.equalTo(bookId).and.contentId.equalTo(contentId);

    return query.goToTable.then((all) {
      List<String>? data;
      if (all.isNotEmpty) {
        assert(all.length > 1 || Log.e('content $bookId count: ${all.length}'));
        final raw = all.last.data;
        if (raw != null) {
          final _raw = raw
              .replaceAll('&nbsp;', ' ')
              .replaceAll(RegExp(r'<br\s*/>'), '\n');
          data = split(_raw);
        }
      }
      return data;
    });
  }

  final _caches = <int, _ZhangduDetailChapterCache>{};
  final _cachesTime = <int, int>{};
  static const int updateInterval = 1000 * 60 * 3;

  void addArchive(int bookId, _ZhangduDetailChapterCache archive) {
    _caches[bookId] = archive;
    _cachesTime[bookId] = DateTime.now().millisecondsSinceEpoch;
  }

  _ZhangduDetailChapterCache? getData(int bookId) {
    return _caches[bookId];
  }

  bool shouldUpate(int bookId) {
    removeExpired();
    return _caches.containsKey(bookId);
  }

  Timer? _autoClear;
  void autoClear() {
    _autoClear ??=
        Timer.periodic(Duration(milliseconds: updateInterval), (timer) {
      removeExpired();
      assert(_caches.length == _cachesTime.length);
      if (_caches.isEmpty) {
        timer.cancel();
        _autoClear = null;
      }
    });
  }

  void removeExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _cachesTime.removeWhere((key, value) {
      final remove = value + updateInterval <= now;
      if (remove) _caches.remove(key);
      return remove;
    });
  }

  /// 相同的[bookId]在一个队列中
  Future<_ZhangduDetailChapterCache?> autoUpdate(int bookId) {
    return EventQueue.runTaskOnQueue(
        [_autoUpdate, bookId], () => _autoUpdate(bookId));
  }

  Future<_ZhangduDetailChapterCache?> _autoUpdate(int bookId) async {
    if (!shouldUpate(bookId)) {
      final data = getData(bookId);
      if (data != null) return data;
    }
    final url = ZhangduApi.getBookIndexDetail(bookId);
    try {
      final result = await dio.get<List<int>>(url,
          options: Options(responseType: ResponseType.bytes));
      final data = result.data;
      if (data != null) {
        final z = ZipDecoder().decodeBytes(data);
        ZhangduDetailData? detailData;
        List<ZhangduChapterData>? chapterData;
        int errorCount = 0;
        for (var file in z) {
          if (file.isFile) {
            final bytes = file.content as List<int>;
            final data = jsonDecode(utf8.decode(bytes));
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
                chapterData = ZhangduChapter.fromJson(data).data;
              } catch (e) {
                errorCount++;
                if (errorCount > 1) Log.w(e);
              }
            }
          }
        }
        if (detailData != null && chapterData != null) {
          final _cache = _ZhangduDetailChapterCache(detailData, chapterData);
          addArchive(bookId, _cache);
          final chapterId = chapterData.isNotEmpty ? chapterData.first.id : -1;
          final noExists = (await insertZhangduBook(ZhangduCache(
                  name: detailData.name,
                  picture: detailData.picture,
                  chapterUpdateTime: detailData.chapterUpdateTime,
                  chapterName: detailData.chapterName,
                  chapterId: chapterId,
                  bookId: detailData.id,
                  sortKey: sortKey,
                  page: 1,
                  isTop: false,
                  isNew: true,
                  isShow: false))) ==
              -1;
          if (noExists) {
            await _updateZhangduBook(
                bookId,
                ZhangduCache(
                  chapterName: detailData.chapterName,
                  chapterUpdateTime: detailData.chapterUpdateTime,
                  name: detailData.name,
                  chapterId: detailData.chapterId,
                  picture: detailData.picture,
                ));
          }
          return _cache;
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
    // return const ZhangduDetailData();
  }

  @override
  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(
      int bookId, bool update) async {
    if (update) {
      return await _getZhangduIndex(bookId) ??
          getZhangduIndexDb(bookId) ??
          const [];
    }
    return await getZhangduIndexDb(bookId) ??
        await _getZhangduIndex(bookId) ??
        const [];
  }

  FutureOr<List<ZhangduChapterData>?> _getZhangduIndex(int bookId) async {
    final data = await autoUpdate(bookId);
    if (data != null) {
      return data.chapterData;
    }
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    if (!shouldUpate(bookId)) {
      final data = getData(bookId);
      if (data != null) return data.chapterData;
    }
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
  FutureOr<ZhangduSearchData?> getZhangduSearchData(
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

  FutureOr<int?> _updateZhangduBook(int bookId, ZhangduCache book) {
    return getZhangduCacheBookId(bookId).then((list) {
      var isNew = false;
      if (list?.isNotEmpty == true) {
        final cache = list!.last;
        final bChapterId = book.chapterId;
        final bChapterName = book.chapterName;
        isNew = cache.isNew == true ||
            cache.chapterName != bChapterName ||
            cache.chapterId != bChapterId;

        Log.i('$isNew  ${cache.chapterName} | ${book.chapterName}',
            onlyDebug: false);
      }
      book.isNew ??= isNew;
      final update = zhangduCache.update..where.bookId.equalTo(bookId);
      zhangduCache.updateZhangduCache(update, book);
      return update.go;
    });
  }

  @override
  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    final update = zhangduCache.update..where.bookId.equalTo(bookId);
    zhangduCache.updateZhangduCache(update, book);
    return update.go;
  }

  @override
  FutureOr<int?> updateZhangduMainStatus(int bookId) async {
    await getZhangduDetail(bookId);
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

  FutureOr<List<ZhangduCache>?> getZhangduCacheBookId(int bookId) {
    return zhangduCache.query.all.where.bookId
        .equalTo(bookId)
        .back
        .whereEnd
        .goToTable;
  }

  @override
  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    return zhangduCache.query.goToTable;
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return zhangduCache.query.all.watchToTable;
  }

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

class _ZhangduDetailChapterCache {
  _ZhangduDetailChapterCache(this.detailData, this.chapterData);
  ZhangduDetailData detailData;
  List<ZhangduChapterData> chapterData;
}
