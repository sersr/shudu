import 'dart:async';
import 'dart:math' as math;

import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../book_index_notifier.dart';
import '../text_data.dart';
import 'content_base.dart';
import 'content_layout.dart';

mixin ContentLoad on ContentDataBase, ContentLayout {
  /// 文本加载-----------------
  final _caches = <int, TextData>{};

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

  int get preLength {
    var length = currentPage - 1;
    final preData = _caches[tData.pid];
    length += preData?.content.length ?? 0;
    return math.max(0, length);
  }

  int get nextLength {
    var length = tData.content.length;
    length -= currentPage;
    final nextData = _caches[tData.nid];
    length += nextData?.content.length ?? 0;
    return math.max(0, length);
  }

  bool _applySuccess = false;
  @override
  void applyConentDimension({bool force = true}) {
    if (!force && _applySuccess) return;
    final pLength = preLength;
    final nLength = nextLength;

    final extent = controller?.viewPortDimension;

    if (extent != null) {
      _applySuccess = true;
      final page = controller!.page.round();
      final p = -pLength + page;
      final n = nLength + page;

      controller?.applyContentDimension(
          minExtent: p * extent, maxExtent: n * extent);
    } else {
      _applySuccess = false;
    }
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
    final _keys = getCurrentIds();

    if (_caches.length > _keys.length + 1) {
      _caches.removeWhere((key, data) {
        final remove = !_keys.contains(key);
        if (remove) data.dispose();
        return remove;
      });
    }
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
  Future<void> load(int _bookid, int contentid, {update = false}) {
    return _run(() => _load(_bookid, contentid, update));
  }

  @pragma('vm:prefer-inline')
  Future<T> _run<T>(EventCallback<T> callback) {
    return EventQueue.runTask(this, callback);
  }

  Future<List<ContentMetrics>> _genTextData(
      int oldBookId, List<String> data, String cname) async {
    final _key = key;
    final pages = await asyncLayout(data, cname);

    if (_key != key || oldBookId != bookid) {
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
  Future<void> _load(int _bookid, int contentid, bool update) async {
    if (_bookid == -1 || contentid == -1) return;
    TextData? _cnpid;
    if (api == ApiType.zhangdu) {
      final current = indexData[contentid];
      if (current == null) {
        Log.e('error...', onlyDebug: false);
        return;
      }
      final _index = rawIndexData.lastIndexOf(current);

      var pid = -1;
      var nid = -1;
      if (_index > 0) {
        final p = rawIndexData.elementAt(_index - 1);
        if (p.id != null) pid = p.id!;
      }
      if (_index < rawIndexData.length - 1) {
        final n = rawIndexData.elementAt(_index + 1);
        if (n.id != null) nid = n.id!;
      }
      final url = current.contentUrl;
      final name = current.name;
      final sort = current.sort;

      assert(Log.i('${current.contentUrl} | ${current.name} | $nid, $pid'));
      if (url != null && name != null && sort != null) {
        final lines = await repository.bookEvent
            .getZhangduContent(_bookid, contentid, url, name, sort, update);
        if (_bookid != bookid) return;

        if (lines != null) {
          final hasContent = lines.isNotEmpty;
          final data = hasContent ? lines : const ['没有章节内容，稍后重试。'];
          final pages = await _genTextData(_bookid, data, name);
          if (pages.isEmpty) return;
          _cnpid = TextData(
            cid: contentid,
            nid: nid,
            pid: pid,
            content: pages,
            hasContent: hasContent,
            cname: name,
          );
        }
      }
    } else {
      final lines =
          await repository.bookEvent.getContent(_bookid, contentid, update);
      if (_bookid != bookid) return;

      if (lines != null && lines.contentIsNotEmpty) {
        final allLines = debugTest ? ['debugTest'] : lines.source;
        final pages = await _genTextData(_bookid, allLines, lines.cname!);

        if (pages.isEmpty) return;
        _cnpid = TextData(
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
    if (_cnpid != null) {
      final old = _caches.remove(_cnpid.cid);
      old?.dispose();
      addText(_cnpid.cid!, _cnpid.clone());
      applyConentDimension();
      _cnpid.dispose();
    }
  }
}
