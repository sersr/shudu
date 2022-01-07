import 'dart:async';
import 'dart:math' as math;

import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../database/database.dart';
import '../book_index_notifier.dart';
import '../text_data.dart';
import 'content_base.dart';
import 'content_layout.dart';

mixin ContentLoad on ContentDataBase, ContentLayout {
  final _caches = <int, TextData>{};

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
    final ids = <int?>{};
    final cid = tData.cid;

    final current = getTextData(tData.cid);
    final nid = current?.nid;
    final pid = current?.pid;
    ids
      ..add(cid)
      ..add(nid)
      ..add(pid);
    return ids.whereType<int>();
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

  /// {contentId: data}
  Map<int?, ZhangduChapterData> indexData = {};
  ApiType api = ApiType.biquge;

  /// 通过`lastIndexOf`找到index
  List<ZhangduChapterData> rawIndexData = [];
  Future<void> _load(int localBookId, int contentId, bool update) async {
    if (localBookId == -1 || contentId == -1) return;
    final localKey = key;
    TextData? newText;
    if (api == ApiType.zhangdu) {
      newText = await _loadZhangdu(localBookId, contentId, update);
    } else {
      final lines = await repository.getContent(localBookId, contentId, update);
      if (localBookId != bookId || localKey != key || !inBook) return;

      if (lines != null && lines.contentIsNotEmpty) {
        final allLines = debugTest ? ['debugTest'] : lines.source;
        final pages = await _genTextData(localBookId, allLines, lines.cname!);

        if (pages.isEmpty) return;
        newText = TextData(
          content: pages,
          nid: lines.nid,
          pid: lines.pid,
          cid: lines.cid,
          hasContent: debugTest ? false : lines.hasContent,
          cname: lines.cname,
        );
        debugTest = false;
      }
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

  Future<TextData?> _loadZhangdu(
      int localBookId, int contentId, bool update) async {
    assert(localBookId != -1 && contentId != -1);
    final localKey = key;
    TextData? newText;

    final current = indexData[contentId];
    if (current == null) {
      Log.e('error...', onlyDebug: false);
      return newText;
    }
    final index = rawIndexData.lastIndexOf(current);

    var pid = -1;
    var nid = -1;
    if (index > 0) {
      final p = rawIndexData.elementAt(index - 1);
      if (p.id != null) pid = p.id!;
    }
    if (index < rawIndexData.length - 1) {
      final n = rawIndexData.elementAt(index + 1);
      if (n.id != null) nid = n.id!;
    }
    final url = current.contentUrl;
    final name = current.name;
    final sort = current.sort;

    assert(Log.i('${current.contentUrl} | ${current.name} | $nid, $pid'));
    if (url != null && name != null && sort != null) {
      final lines = await repository.getZhangduContent(
          localBookId, contentId, url, name, sort, update);
      if (localBookId != bookId || localKey != key || !inBook) return null;

      if (lines != null) {
        final hasContent = lines.isNotEmpty;
        final data = hasContent ? lines : ['没有章节内容，稍后重试。'];
        final pages = await _genTextData(localBookId, data, name);
        if (pages.isEmpty) return null;
        newText = TextData(
          cid: contentId,
          nid: nid,
          pid: pid,
          content: pages,
          hasContent: hasContent,
          cname: name,
        );
      }
    }
    return newText;
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
    if (api == ApiType.biquge) {
      final book = BookCache(
        isNew: false,
        chapterId: cid,
        sortKey: sortKey,
        page: localCurrentPage,
      );

      await repository.bookCacheEvent.updateBook(localBookId, book);
    } else {
      final book = ZhangduCache(
        isNew: false,
        chapterId: cid,
        sortKey: sortKey,
        page: localCurrentPage,
      );
      await repository.zhangduEvent.updateZhangduBook(localBookId, book);
    }
  }
}
