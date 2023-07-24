import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:nop/nop.dart';

import '../../../../database/nop_database.dart';
import '../../import.dart';
import '../../text_data.dart';
import 'content_base.dart';
import 'content_layout.dart';

mixin ContentLoad on ContentDataBase, ContentLayout {
  final _caches = SplayTreeMap<int, TextData>();

  /// 与 [_caches]直接交互的方法
  bool containsKeyText(Object? key) {
    return _caches.containsKey(key);
  }

  TextData? removeText(Object? key) {
    return _caches.remove(key);
  }

  void addText(int key, TextData data) {
    assert(!_caches.containsKey(key));
    _caches[key] = data;
  }

  @override
  void reset() {
    if (_caches.isNotEmpty) {
      var _c = List.of(_caches.values);
      _caches.clear();
      for (var t in _c) {
        t.dispose();
      }
    }
  }

  TextData? getTextData(int? key) {
    final data = _caches[key];
    assert(data == null || data.contentIsNotEmpty);
    return data;
  }

  @override
  void updateCaches(TextData data) {
    final keys = getCurrentIds();

    if (_caches.length > keys.length + 1) {
      _caches.removeWhere((key, data) {
        final remove = !keys.contains(key);
        if (remove) data.dispose();
        return remove;
      });
    }
  }
  // ----------------

  int get preLength {
    var length = currentPage - 1;
    final preData = getTextData(tData.pid);
    length += preData?.content.length ?? 0;
    return math.max(0, length);
  }

  int get nextLength {
    var length = tData.content.length;
    length -= currentPage;
    final nextData = getTextData(tData.nid);
    length += nextData?.content.length ?? 0;
    return math.max(0, length);
  }

  bool _needUpdate = false;

  bool get needUpdate {
    return _needUpdate || controller?.atEdge == true;
  }

  void updated() {
    _needUpdate = false;
  }

  @override
  void needUpdateContentDimension() {
    if (_needUpdate) return;
    _needUpdate = true;
  }

  // 根据当前章节更新存活章节
  // 任务顺序与添加顺序一致
  Iterable<int> getCurrentIds() {
    final cid = tData.cid;

    final current = getTextData(tData.cid);
    final nid = current?.nid;
    final pid = current?.pid;
    return [cid, nid, pid].whereType<int>();
  }

  @pragma('vm:prefer-inline')
  Future<void> load(int localBookId, int contentId, {update = false}) async {
    if (!canReload(contentId) && !update) return;
    return _run(() => _load(localBookId, contentId, update));
  }

  @pragma('vm:prefer-inline')
  Future<T> _run<T>(EventCallback<T> callback) {
    return EventQueue.run(this, callback);
  }

  Future<List<ContentMetrics>> _genTextData(
      int oldBookId, List<String> data, String cname) async {
    final _key = key;
    final pages = await asyncLayout(data, cname);

    if (_key != key || oldBookId != bookId) {
      for (final p in pages) {
        // 释放picture资源
        p.dispose();
      }
      assert(Log.w('当前章节被抛弃'));
      return const [];
    }
    return pages;
  }

  Future<void> _load(int localBookId, int contentId, bool update) async {
    if (localBookId == -1 || contentId == -1) return;
    final localKey = key;
    TextData? newText;

    final lines = await repository.getContent(localBookId, contentId, update);
    if (localBookId != bookId || localKey != key || !inBook) return;

    if (lines != null && lines.contentIsNotEmpty) {
      final allLines = lines.source;
      final pages = await _genTextData(localBookId, allLines, lines.cname!);

      if (pages.isEmpty) return;
      newText = TextData(
        content: pages,
        nid: lines.nid,
        pid: lines.pid,
        cid: lines.cid,
        hasContent: lines.hasContent,
        cname: lines.cname,
      );
    }
    if (newText != null) {
      final old = removeText(newText.cid);
      old?.dispose();
      addText(newText.cid!, newText.clone());
      needUpdateContentDimension();
      newText.dispose();
    } else {
      autoAddReloadIds(contentId);
    }
  }

  bool canReload(int id);
  bool autoAddReloadIds(int contentId);

  @override
  void dump() {
    final api = this.api;
    final cid = tData.cid;
    final localBookId = bookId;
    final localCurrentPage = currentPage;
    EventQueue.pushOne(
        _dump, () => _dump(localBookId, cid, localCurrentPage, api));
  }

  Future<void> awaitDump() {
    return EventQueue.getQueueRunner(_dump);
  }

  Future<void> dumpIgnore() {
    final api = this.api;
    final cid = tData.cid;
    final localBookId = bookId;
    final localCurrentPage = currentPage;
    return _dump(localBookId, cid, localCurrentPage, api);
  }

  Future<void> _dump(
      int localBookId, int? cid, int localCurrentPage, ApiType api) async {
    if (cid == null || localBookId == -1) return;

    final book = BookCache(
      isNew: false,
      chapterId: cid,
      sortKey: sortKey,
      page: localCurrentPage,
    );

    await repository.bookCacheEvent.updateBook(localBookId, book);
  }
}
