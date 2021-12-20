import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:wakelock/wakelock.dart';

import '../data/zhangdu/zhangdu_chapter.dart';
import '../database/database.dart';
import '../event/event.dart';
import '../pages/book_content/widgets/page_view_controller.dart';
import 'book_index_notifier.dart';
import 'constansts.dart';
import 'text_data.dart';

enum Status { ignore, error, done }

mixin ContentDataBase on ChangeNotifier {
  Repository get repository;
  int bookid = -1;

  // _innerIndex == page == 0
  void resetController() {
    controller?.goIdle();
    _innerIndex = 0;
    controller?.correct(0.0);
  }

  int currentPage = 1;
  int _innerIndex = 0;

  TextData _tData = TextData();
  TextData get tData => _tData;

  set tData(TextData data) {
    if (data == _tData) return;
    assert(data.contentIsNotEmpty, '不该为 空');

    _tData.dispose();
    _tData = data.clone(); // 复制
    dump();
    updateCaches(data);
  }

  Future<void> dump();

  void reset();
  Future<void> startFirstEvent({
    bool clear = true,
    bool only = true,
    FutureOr<void> Function()? onStart,
    void Function()? onDone,
  });

  var key = Object();
  void didChangeKey() => key = Object();

  @visibleForTesting
  void clear() {
    reset();
    _tData.dispose();
    _tData = TextData();
  }

  ///-------------------------

  // 缓存池

  // 记录重新下载的id，并延迟删除，避免频繁访问
  final _reloadIds = <int>{};

  /// 当前章节无效，初始加载，设置更改，重新加载
  final initQueue = EventQueue();

  NopPageViewController? controller;

  final showCname = ValueNotifier(false);
  final mic = Duration.microsecondsPerMillisecond * 200.0;

  bool get inBook;
  void notifyState(
      {bool? loading, bool? notEmptyOrIgnore, NotifyMessage? error});

  /// ---------------
  void _notifyCustom() {
    notifyState(
        //                        notEmpty        ||  ignore
        notEmptyOrIgnore: tData.contentIsNotEmpty || !inBook,
        loading: false);
  }

  void _notify() {
    _notifyCustom();
    notifyListeners();
  }

  /// 更新[tData]测试变量
  ///
  ///
  bool debugTest = false;

  // 更新队列
  void updateCaches(TextData data);

  // 根据当前章节更新存活章节
  // 任务顺序与添加顺序一致
  Iterable<int> _getCurrentIds();
}

class ContentNotifier extends ChangeNotifier
    with
        ContentDataBase,
        ContentBrightness,
        ContentStatus,
        Configs,
        ContentLayout,
        ContentLoad,
        ContentTasks,
        ContentAuto,
        ContentGetter,
        ContentEvent {
  ContentNotifier({required this.repository});

  @override
  final Repository repository;
}

mixin ContentLayout on ContentDataBase, Configs {
  bool showrect = false;

  /// 文本布局信息
  Size size = Size.zero;
  EdgeInsets get contentLayoutPadding => _contentLayoutPadding;

  var _contentLayoutPadding = EdgeInsets.zero;

  Future<List<ContentMetrics>> _asyncLayout(
      List<String> paragraphs, String cname) async {
    var whiteRows = 0;

    final textPages = <ContentMetrics>[];

    final fontSize = style.fontSize!;

    final config = this.config.value.copyWith();

    final words = (size.width - _contentLayoutPadding.horizontal) ~/ fontSize;

    final _size = _contentLayoutPadding.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = _contentLayoutPadding.left + leftExtraPadding;

    // 文本占用高度
    final contentHeight = _size.height - contentWhiteHeight;

    // 配置行高
    final lineHeight = config.lineTweenHeight! * fontSize;

    final _allExtraHeight = contentHeight % lineHeight;

    // lineCounts
    final rows = contentHeight ~/ lineHeight;

    if (rows <= 0) return textPages;

    final hl = _allExtraHeight / rows;
    // 实际行高
    final lineHeightAndExtra = hl + lineHeight;
    final _key = key;

    await releaseUI;
    // 大标题
    final TextPainter _bigTitlePainter = TextPainter(
        text: TextSpan(
            text: cname,
            style: style.copyWith(
                fontSize: 22, height: 1.2, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);

    await releaseUI;
    // 小标题
    final TextPainter smallTitlePainter = TextPainter(
        text: TextSpan(text: cname, style: secstyle),
        ellipsis: '...',
        textDirection: TextDirection.ltr,
        maxLines: 1)
      ..layout(maxWidth: width);

    whiteRows = 150 ~/ lineHeightAndExtra + 1;

    while (lineHeightAndExtra * whiteRows > 140) {
      whiteRows--;
      if (lineHeightAndExtra * whiteRows < 130) break;
      await releaseUI;
    }

    final _oneHalf = fontSize * 1.6;

    final lines = <TextPainter>[];

    final _t = TextPainter(textDirection: TextDirection.ltr);
    // 只需要最小的位移，会自动计算位置
    final _offset = Offset(width, 0.1);
    // 分行布局
    for (var i = 0; i < paragraphs.length; i++) {
      if (_key != key) return const [];

      // character 版本
      final pc = paragraphs[i].characters;
      var start = 0;
      while (start < pc.length) {
        var end = math.min(start + words, pc.length);
        await releaseUI;

        // 确定每一行的字数
        while (true) {
          if (end >= pc.length) break;

          end++;
          final s = pc.getRange(start, end).toString();
          _t
            ..text = TextSpan(text: s, style: style)
            ..layout(maxWidth: width);

          await releaseUI;

          if (_t.height > _oneHalf) {
            final endOffset = _t.getPositionForOffset(_offset).offset;
            final _s = s.substring(0, endOffset).characters;
            assert(() {
              if (endOffset != _s.length) {
                // Unicode 字符占用的字节数不相等
                // 避免多字节字符导致 [subString] 出错
                Log.i('no: $_s |$start, ${pc.length}');
              }
              return true;
            }());
            end = start + _s.length;
            break;
          }
        }

        await releaseUI;
        final _s = pc.getRange(start, end).toString();
        if (end == pc.length && _s.replaceAll(regexpEmpty, '').isEmpty) break;

        final _text = TextPainter(
            text: TextSpan(text: _s, style: style),
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: width);

        start = end;
        lines.add(_text);
      }
    }

    await releaseUI;
    var topExtraRows = (_bigTitlePainter.height / fontSize).floor();
    if (topExtraRows > 2) {
      if (whiteRows > 2) {
        whiteRows--;
      }
    }
    final pages = <List<TextPainter>>[];
    // 首页留白和标题
    final firstPages = math.max(0, rows - whiteRows - topExtraRows);
    pages.add(lines.sublist(0, math.min(firstPages, lines.length)));

    // 分页
    if (firstPages < lines.length - 1)
      for (var i = firstPages; i < lines.length;) {
        pages.add(lines.sublist(i, (i + rows).clamp(i, lines.length)));
        i += rows;
      }

    var extraHeight = lineHeightAndExtra - fontSize;
    final isHorizontal = config.axis == Axis.horizontal;
    await releaseUI;
    if (_key != key) {
      return const [];
    }
    bool error = false;
    // 添加页面信息
    for (var r = 0; r < pages.length; r++) {
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);

      final right = width - bottomRight.width - leftExtraPadding * 2;
      if (_key != key) {
        error = true;
        break;
      }
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      await releaseUI;

      paintText(canvas,
          painters: pages[r],
          extraHeight: extraHeight,
          isHorizontal: isHorizontal,
          fontSize: fontSize,
          titlePainter: smallTitlePainter,
          bottomRight: bottomRight,
          cBigPainter: _bigTitlePainter,
          right: right,
          left: left,
          index: r,
          size: _size,
          paddingRect: _contentLayoutPadding,
          showrect: showrect,
          topExtraHeight: lineHeightAndExtra * (whiteRows + topExtraRows));
      await releaseUI;

      final picture = recorder.endRecording();
      await releaseUI;

      final met = ContentMetrics(
        picture: PictureRefInfo(picture),
        secstyle: secstyle,
        left: left,
        size: _size,
      );
      textPages.add(met);
    }
    if (error) {
      for (var text in textPages) {
        text.dispose();
      }
      return const [];
    }
    return textPages;
  }

  // test
  // ignore: unused_element
  Future<List<ContentMetricsText>> _asyncLayoutText(
      List<String> paragraphs, String cname) async {
    var whiteRows = 0;

    final textPages = <ContentMetricsText>[];
    final style = this.style;

    final fontSize = style.fontSize!;

    final config = this.config.value.copyWith();

    final words = (size.width - _contentLayoutPadding.horizontal) ~/ fontSize;

    final _size = _contentLayoutPadding.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = _contentLayoutPadding.left + leftExtraPadding;

    // 文本占用高度
    final contentHeight = _size.height - contentWhiteHeight;

    // 配置行高
    final lineHeight = config.lineTweenHeight! * fontSize;

    final _allExtraHeight = contentHeight % lineHeight;

    // lineCounts
    final rows = contentHeight ~/ lineHeight;

    if (rows <= 0 || words <= 0) return textPages;

    final hl = _allExtraHeight / rows;
    // 实际行高
    final lineHeightAndExtra = hl + lineHeight;
    final _key = key;
    // 小标题
    final TextPainter smallTitlePainter = TextPainter(
        text: TextSpan(text: cname, style: secstyle),
        textDirection: TextDirection.ltr,
        maxLines: 1)
      ..layout(maxWidth: width);
    await releaseUI;
    // 大标题
    final TextPainter _bigTitlePainter = TextPainter(
        text: TextSpan(
            text: cname,
            style: style.copyWith(
                fontSize: 22, height: 1.2, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);

    await releaseUI;

    whiteRows = 150 ~/ lineHeightAndExtra + 1;

    while (lineHeightAndExtra * whiteRows > 150) {
      whiteRows--;
      if (lineHeightAndExtra * whiteRows < 120) break;
      await releaseUI;
    }

    final _oneHalf = fontSize * 1.6;

    final lines = <TextPainter>[];

    final _t = TextPainter(textDirection: TextDirection.ltr);
    // 只需要最小的位移，会自动计算位置
    final _offset = Offset(width, 0.1);
    // 分行布局
    for (var i = 0; i < paragraphs.length; i++) {
      // character 版本
      final pc = paragraphs[i].characters;
      var start = 0;

      while (start < pc.length) {
        var end = math.min(start + words, pc.length);
        await releaseUI;

        // 确定每一行的字数
        while (true) {
          if (end >= pc.length) break;

          end++;
          final s = pc.getRange(start, end).toString();
          _t
            ..text = TextSpan(text: s, style: style)
            ..layout(maxWidth: width);

          await releaseUI;

          if (_t.height > _oneHalf) {
            final endOffset = _t.getPositionForOffset(_offset).offset;

            // 获得字符真正长度
            final _s = s.substring(0, endOffset).characters;

            assert(Log.i(
                'no: $_s ${endOffset != _s.length} |$start, ${pc.length}'));
            end = start + _s.length;
            break;
          }
        }

        await releaseUI;
        final line = pc.getRange(start, end).toString();
        if (end == pc.length && line.replaceAll(regexpEmpty, '').isEmpty) break;

        final _text = TextPainter(
            text: TextSpan(text: line, style: style),
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: width);

        start = end;
        lines.add(_text);
      }
    }

    await releaseUI;
    var topExtraRows = (_bigTitlePainter.height / fontSize).floor();

    final pages = <List<TextPainter>>[];
    // 首页留白和标题
    final firstPages = math.max(0, rows - whiteRows - topExtraRows);
    pages.add(lines.sublist(0, math.min(firstPages, lines.length)));

    // 分页
    final length = lines.length;
    if (firstPages < length - 1)
      for (var i = firstPages; i < length;) {
        final end = math.min(i + rows, length);
        pages.add(lines.sublist(i, end));
        i += rows;
      }

    var extraHeight = lineHeightAndExtra - fontSize;

    await releaseUI;
    if (_key != key) {
      return const [];
    }
    bool error = false;
    // 添加页面信息
    for (var r = 0; r < pages.length; r++) {
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);

      final right = width - bottomRight.width - leftExtraPadding * 2;
      if (_key != key) {
        error = true;
        break;
      }

      await releaseUI;

      final met = ContentMetricsText(
        lines: pages[r],
        extraHeight: extraHeight,
        fontSize: fontSize,
        titleCname: smallTitlePainter,
        bottomRight: bottomRight,
        cBigPainter: _bigTitlePainter,
        right: right,
        left: left,
        index: r,
        size: _size,
        paddingRect: _contentLayoutPadding,
        topExtraHeight: lineHeightAndExtra * (whiteRows + topExtraRows),
        secStyle: secstyle,
      );
      await releaseUI;

      textPages.add(met);
    }
    if (error) {
      return const [];
    }
    return textPages;
  }
}

mixin ContentBrightness {
  /// --------- brightness
  final _brightness = EventQueue();
  final brightness = ValueNotifier(0.0);

  double? _lastBrightness;

  void setBrightness(double v) {
    final _clamp = v.clamp(0.0, 1.0);
    _brightness.addOneEventTask(() async {
      brightness.value = _clamp;
      _lastBrightness = _clamp;
      follow.value = false;
      if (_brightNess) return ScreenBrightness.setScreenBrightness(_clamp);
    });
  }

  final follow = ValueNotifier(true);
  void setFollow(bool? v) {
    if (follow.value == v || v == null) return;
    follow.value = v;
    _brightness.addOneEventTask(() async {
      if (v) {
        if (_brightNess) await ScreenBrightness.resetScreenBrightness();
      } else {
        final _old = _lastBrightness;
        if (_old != null) {
          final _v = _old.clamp(0.0, 1.0);
          brightness.value = _v;
          if (_brightNess) await ScreenBrightness.setScreenBrightness(_v);
        }
      }
    });
  }

  void reloadBrightness() {
    _brightness.addOneEventTask(() => _fo());
  }

  Future<void> _fo() async {
    if (_brightNess) brightness.value = await ScreenBrightness.current;
  }

  final bool _brightNess = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

mixin ContentStatus on ContentDataBase, ContentBrightness {
  bool _inBookView = false;
  @override
  bool get inBook => _inBookView;

  //状态栏显隐状态
  bool uiOverlayShow = false;
  void out() {
    if (!inBook) return;
    uiOverlayShow = false;
    _inBookView = false;
    assert((debugTest = false) || true);
    _notifyCustom();
    if (_brightNess)
      _brightness.addOneEventTask(() async {
        await ScreenBrightness.resetScreenBrightness();

        return _fo();
      });
  }

  void inbook() {
    if (_inBookView) return;
    _inBookView = true;
    assert(debugTest = true);

    if (!follow.value) {
      final _old = _lastBrightness;
      if (_old != null) {
        setBrightness(_old);
      }
    }
  }
}

mixin ContentLoad on ContentDataBase, ContentLayout {
  /// 文本加载-----------------
  final _caches = <int, TextData>{};

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

  @override
  @visibleForTesting
  void clear() {
    reset();
    _tData.dispose();
    _tData = TextData();
  }

  TextData? _getTextData(int? key) {
    final data = _caches[key];
    assert(data == null || data.contentIsNotEmpty);
    return data;
  }

  @override
  void updateCaches(TextData data) {
    final _keys = _getCurrentIds();

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
  @override
  Iterable<int> _getCurrentIds() {
    final ids = <int?>{};
    final cid = tData.cid;

    final current = _getTextData(tData.cid);
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
    return EventQueue.runTaskOnQueue(runtimeType, callback);
  }

  Future<List<ContentMetrics>> _genTextData(
      int oldBookId, List<String> data, String cname) async {
    final _key = key;
    final pages = await _asyncLayout(data, cname);

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
        final allLines = debugTest ? ['debugTest'] : split(lines.source);
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
      _caches[_cnpid.cid!] = _cnpid.clone();
      _cnpid.dispose();
    }
  }
}

mixin ContentTasks on ContentDataBase, ContentLoad {
  // 所有异步任务
  final _futures = <int, Future>{};

  void _loadTasks(int _bookid, int? contentid) {
    if (!inBook) return;

    if (_bookid == bookid &&
        _bookid != -1 &&
        contentid != null &&
        contentid != -1 &&
        !_caches.containsKey(contentid) &&
        !_futures.isLoading(contentid)) {
      _futures.addTask(contentid, load(_bookid, contentid));
    }
  }

  Future<void>? taskRunner() {
    return EventQueue.getQueueRunner([runtimeType, key]);
  }

  bool _scheduled = false;

  void scheduleTask() {
    if (_scheduled || !inBook) return;
    Timer(const Duration(milliseconds: 100), () {
      _scheduled = false;
      _loadResolve();
      _loadAuto();
    });
    _scheduled = true;
  }

  void _loadAuto() {
    _getCurrentIds().where((e) => !_caches.containsKey(e)).forEach(_loadWithId);
  }

  void _loadWithId(int? id) => _loadTasks(bookid, id);
  bool canReload(int id) => !_reloadIds.contains(id);
  bool _autoAddReloadIds(int contentId) {
    if (_reloadIds.contains(contentId)) return true;
    assert(Log.w('nid = ${tData.nid}, hasContent: ${tData.hasContent}'));

    _reloadIds.add(contentId);

    Future.delayed(
        const Duration(seconds: 10), () => _reloadIds.remove(contentId));
    return false;
  }

  // 处于最后一章节时，查看是否有更新
  Future<void> _loadResolve() async {
    final updateCid = tData.cid;
    if (updateCid == null || initQueue.actived || !canReload(updateCid)) return;
    final updateNid = tData.nid == -1;
    final updateContent = !tData.hasContent;
    if (updateNid || updateContent) {
      Log.w('resolve $updateCid', onlyDebug: false);
      bool _getdata() {
        if (_caches.containsKey(updateCid) && tData.cid == updateCid) {
          if (tData.contentIsNotEmpty &&
              (currentPage == tData.content.length || currentPage == 1)) {
            final _tData = _getTextData(updateCid)!;
            if ((updateNid && _tData.nid != -1) ||
                (updateContent && _tData.hasContent)) {
              startFirstEvent(only: false, clear: false);
              return true;
            }
          }
        }
        return false;
      }

      await releaseUI;
      if (_getdata()) return;

      if (_autoAddReloadIds(updateCid)) return;
      if ((currentPage == tData.content.length || currentPage == 1)) {
        await load(bookid, updateCid, update: true);
        _getdata();
      }
    }
  }

  // 立即
  Future<void> _resolveId() async {
    if (tData.contentIsEmpty) return;
    var _data = _getTextData(tData.cid);
    if (_data != null && (!_data.hasContent || _data.nid == -1)) {
      await _reload();
    }
  }

  Future<void> _reload() async {
    await load(bookid, tData.cid!, update: true);
    final _data = _getTextData(tData.cid);
    if (_data != null && _data.contentIsNotEmpty) {
      tData = _data;
    }
    if (currentPage > tData.content.length) {
      currentPage = tData.content.length;
    }
    _notify();
  }

  final header = ValueNotifier<String>('');
  final footer = ValueNotifier<String>('');
  Future<bool> _getContent(int getid) async {
    var _data = _getTextData(getid);
    if (_data == null || _data.contentIsEmpty) {
      _loadAuto();

      await _futures.awaitKey(getid);

      _data = _getTextData(getid);
      if (_data == null || _data.contentIsEmpty) return false;
    }

    tData = _data;
    currentPage = 1;

    if (config.value.axis == Axis.vertical) {
      final footv = '$currentPage/${tData.content.length}页';
      scheduleMicrotask(() {
        if (config.value.axis != Axis.vertical) return;
        footer.value = footv;
        header.value = tData.cname!;
      });
    }

    resetController();
    _notify();
    return true;
  }
}

mixin ContentEvent
    on ContentDataBase, ContentStatus, Configs, ContentAuto, ContentGetter {
  // 加载状态
  // 是否直接忽略
  // 显示网络错误信息
  final _loading = ValueNotifier(false);
  final _ignore = ValueNotifier(false);
  final _error = ValueNotifier(NotifyMessage.hide);
  ValueListenable<bool> get loading => _loading;
  ValueListenable<bool> get notEmptyOrIgnore => _ignore;
  ValueListenable<NotifyMessage> get error => _error;
  Listenable get listenable => Listenable.merge([loading, error]);

  @override
  void notifyState(
      {bool? loading, bool? notEmptyOrIgnore, NotifyMessage? error}) {
    if (loading != null) _loading.value = loading;
    if (notEmptyOrIgnore != null) _ignore.value = notEmptyOrIgnore;
    if (error != null) _error.value = error;
  }

  Future<void> shadow() async {
    showrect = !showrect;
    if (inBook && tData.cid != null) {
      /// 缓存数据过时
      initQueue.addEventTask(reset);
      return startFirstEvent();
    }
  }

  Future<void> updateCurrent() => _reload().then((_) => _notify());

  /// 进入阅读页面前，必须调用的方法
  Future<void> touchBook(int newBookid, int cid, int page,
      {ApiType api = ApiType.biquge}) async {
    if (!inBook) resetController();

    if (!config.value.orientation!) {
      uiOverlay();
      uiStyle(dark: true);
    }
    await setOrientation(config.value.orientation!);

    inbook();
    newBookOrCid(newBookid, cid, page, api: api);
  }

  bool _shouldUpdate(int newBookid, int cid, int page, ApiType api) {
    return tData.cid != cid || bookid != newBookid || this.api != api;
  }

  Future<void> _getStateOrSetBook(int newBookid, int cid, int page,
      {ApiType api = ApiType.biquge}) async {
    if (_shouldUpdate(newBookid, cid, page, api)) {
      _notify();
      notifyState(notEmptyOrIgnore: true, loading: false);
      final update = bookid != newBookid;
      _tData.dispose();
      _tData = TextData(cid: cid, api: api);
      this.api = api;
      currentPage = page;
      bookid = newBookid;
      // indexData.clear();
      if ((rawIndexData.isEmpty || update) && api == ApiType.zhangdu) {
        rawIndexData = await repository.bookEvent.zhangduEvent
                .getZhangduIndex(bookid, false) ??
            [];
        final d =
            rawIndexData.asMap().map((key, value) => MapEntry(value.id, value));
        indexData.clear();
        indexData.addAll(d);
      }
    }
  }

  Future<T?> addInitEventTask<T>(EventCallback<T> callback, {Object? taskKey}) {
    return callback.pushOneAwait(initQueue, taskKey: taskKey);
  }

  /// 当前章节
  ///
  /// 加载、重载、设置更改等操作需要更新[tData]要调用的函数
  /// 每一次调用对会添加一次到队列中
  ///
  /// [only]：本次任务是否可被抛弃
  @override
  Future<void> startFirstEvent({
    bool clear = true,
    bool only = true,
    FutureOr<void> Function()? onStart,
    void Function()? onDone,
  }) {
    didChangeKey();

    void event() async {
      autoRun.stopSave();
      if (clear) reset();

      await onStart?.call();
      final _key = key;

      final _bookid = bookid;
      final _cid = tData.cid;
      if (_cid != null) {
        _loadTasks(_bookid, _cid);

        await _futures.awaitKey(_cid);
        if (debugTest) await release(const Duration(milliseconds: 500));

        final _currentText = _getTextData(_cid);
        if (_bookid == bookid &&
            _currentText != null &&
            _currentText.contentIsNotEmpty &&
            _cid == _currentText.cid) {
          tData = _currentText;

          if (currentPage > tData.content.length)
            currentPage = tData.content.length;
          if (config.value.axis == Axis.vertical) {
            final footv = '$currentPage/${tData.content.length}页';
            footer.value = footv;
            header.value = tData.cname!;
          }
        }
      }
      onDone?.call();

      if (_key == key) _currentTextWasChanged();

      scheduleMicrotask(autoRun.stopAutoRun);
      Timer.run(scheduleTask);
    }

    return only ? event.pushOneAwait(initQueue) : event.pushAwait(initQueue);
  }

  void _currentTextWasChanged() {
    controller?.applyConentDimension(
        minExtent: hasPre() ? double.negativeInfinity : null,
        maxExtent: hasNext() ? double.infinity : null);
    _notify();
  }

  /// 由滚动状态调用
  /// 只有在渲染后才能更改[_innerIndex][controller.pixels]
  void reduceController() {
    if (_innerIndex.abs() > 1000) {
      EventQueue.runOneTaskOnQueue(_reduce, () {
        return SchedulerBinding.instance!.addPostFrameCallback((_) {
          _reduce();
        });
      });
    }
  }

  void _reduce() {
    final extent = controller?.viewPortDimension;
    if (controller?.isScrolling == false && extent != null) {
      final pages = controller!.page.truncate();
      Log.w('lenght: $pages ${extent * pages} | ${controller?.pixels}',
          onlyDebug: false);
      controller?.correctBy(-pages * extent);
      _innerIndex = controller?.page.round() ?? 0;
      _notify();
    }
  }

  Future<void> newBookOrCid(int newBookid, int cid, int page,
      {ApiType api = ApiType.biquge}) async {
    if (!inBook) return;

    if (cid == -1) return;
    final clear = bookid != newBookid;
    if (clear) {
      footer.value = '';
      header.value = '';
    }
    final _reset = _shouldUpdate(newBookid, cid, page, api);
    // assert(_reset || _tData.contentIsNotEmpty);
    if (_reset || _tData.contentIsEmpty) {
      final _t = Timer(
          const Duration(milliseconds: 600), () => notifyState(loading: true));

      await startFirstEvent(
          only: false,
          clear: clear,
          onStart: () => _getStateOrSetBook(newBookid, cid, page, api: api),
          onDone: resetController);

      _t.cancel();
    }
  }

  Future<void> reload() {
    notifyState(loading: true, notEmptyOrIgnore: true);
    return startFirstEvent(clear: false);
  }
  // 同步----

  Future? _willGoF;

  Future goNext() {
    return _willGoF ??= _willGoPreOrNext(isPid: false)
      ..whenComplete(() => _willGoF = null);
  }

  Future goPre() {
    return _willGoF ??= _willGoPreOrNext(isPid: true)
      ..whenComplete(() => _willGoF = null);
  }

  Future<void> _willGoPreOrNext({bool isPid = false}) async {
    /// 当前章节可能会发生变化
    if (tData.contentIsEmpty || initQueue.actived) return;
    notifyState(error: NotifyMessage.hide);

    autoRun.stopSave();
    final timer = Timer(const Duration(milliseconds: 500), () {
      notifyState(loading: true);
    });

    var getid = -1;

    if (isPid) {
      getid = tData.pid!;
    } else {
      await _resolveId();
      getid = tData.nid!;
      if (getid == -1)
        notifyState(loading: false, error: NotifyMessage.noNextError);
    }

    if (getid != -1) {
      final success = await _getContent(getid);
      if (!success) notifyState(error: NotifyMessage.netWorkError);
    }
    timer.cancel();
    notifyState(loading: false);
    scheduleMicrotask(autoRun.stopAutoRun);
  }

  Timer? _sizeChangedTimer;
  void metricsChange(MediaQueryData data) {
    if (inBook || size.isEmpty) {
      if (size.isEmpty) size = data.size;
      final changed = _modifiedSize(data);
      if (changed && inBook) {
        _sizeChangedTimer?.cancel();
        _sizeChangedTimer = Timer(const Duration(milliseconds: 50), () {
          startFirstEvent(onStart: () {
            resetController();
            notifyState(notEmptyOrIgnore: true);
          });
          _sizeChangedTimer = null;
        });
      }
    }
  }

  double _safeTop = 0;
  var _pannelPadding = EdgeInsets.zero;
  final pannelPaddingNotifier = ValueNotifier<bool>(false);

  /// 为[Pannel]提供padding
  EdgeInsets get pannelPadding => _pannelPadding;
  set pannelPadding(EdgeInsets e) {
    if (_pannelPadding == e) return;
    _pannelPadding = e;
    pannelPaddingNotifier.value = !pannelPaddingNotifier.value;
  }

  bool _modifiedSize(MediaQueryData data) {
    var _size = data.size;
    var _p = data.padding;

    /// 状态栏遮挡高度，由`statusHeight`值决定是否可占用状态栏
    final statusHeight = repository.statusHeight;
    // 从上下文中取得固定的状态栏高度
    if (_safeTop == 0 && _p.top != 0) {
      _safeTop = _p.top;
    }
    var _pannelPadding = _p;
    var contentLayoutPadding = _p;

    /// 竖屏模式下，需要处理 顶部UI面板、状态栏、挖空遮挡之间的关系
    if (_size.height >= _size.width) {
      // 顶部UI面板相关，面板的高度显/隐一致，不管有没有遮挡
      _pannelPadding = _p.copyWith(top: _safeTop);
      // 文本布局关系密切
      contentLayoutPadding = EdgeInsets.only(
        left: _p.left + 16,
        top: statusHeight, // top: 取决于遮挡的高度(挖孔、刘海、水滴等)
        right: _p.right + 16,
      );
    } else {
      contentLayoutPadding = EdgeInsets.only(
        left: _p.left + 16,
        right: _p.right + 16,
      );
    }

    pannelPadding = _pannelPadding;

    if (size != _size || contentLayoutPadding != _contentLayoutPadding) {
      size = _size;
      _contentLayoutPadding = contentLayoutPadding;
      Log.w(
          'size: $_size | $_pannelPadding | $statusHeight | $_safeTop | ${_p.top}',
          onlyDebug: false);
      return true;
    } else {
      return false;
    }
  }
}

mixin ContentGetter on ContentDataBase, ContentTasks {
  @override
  Future<void> dump() async {
    final cid = tData.cid;
    final _bookid = bookid;
    final api = this.api;
    if (cid == null || _bookid == -1) return;
    final _currentPage = currentPage;
    if (api == ApiType.biquge) {
      final u = BookCache(
        page: _currentPage,
        isNew: false,
        chapterId: cid,
        sortKey: sortKey,
      );

      await repository.bookEvent.bookCacheEvent.updateBook(_bookid, u);
    } else {
      final book = ZhangduCache(
          page: _currentPage, isNew: false, chapterId: cid, sortKey: sortKey);
      await repository.bookEvent.zhangduEvent.updateZhangduBook(_bookid, book);
    }
  }

  int hasContent() {
    var _r = 0;
    if (tData.contentIsNotEmpty) {
      final hasRight = hasNext();
      final hasLeft = hasPre();

      if (hasRight) _r |= ContentBoundary.addRight;
      if (hasLeft) _r |= ContentBoundary.addLeft;
    } else {
      return ContentBoundary.empty;
    }

    scheduleTask();

    return _r;
  }

  bool hasPre() {
    return currentPage > 1 || _caches.containsKey(tData.pid);
  }

  bool hasNext() {
    return currentPage < tData.content.length || _caches.containsKey(tData.nid);
  }

  // 首先确定当前章节首页位置
  // 再根据当前页面实际位置判断位于哪一个章节，和此章节的哪一页
  ContentMetrics? getContentMes(int page, {bool changeState = false}) {
    if (changeState && page == _innerIndex) return null;
    var currentContentFirstIndex = _innerIndex - currentPage + 1;
    var text = tData;
    ContentMetrics? child;

    while (text.contentIsNotEmpty) {
      // 当前章节页
      final contentIndex = page - currentContentFirstIndex;

      final length = text.content.length;

      if (contentIndex >= 0 && contentIndex <= length - 1) {
        final _currentPage = contentIndex + 1;

        // 滑动过半才会进行判定 [currentPage]
        if (changeState) {
          assert(controller == null || controller!.page.round() == page);

          _innerIndex = page;
          currentPage = _currentPage;
          tData = text;
          dump();
          scheduleTask();
          if (config.value.axis == Axis.vertical) {
            final footv = '$currentPage/${text.content.length}页';
            scheduleMicrotask(() {
              if (config.value.axis != Axis.vertical) return;
              footer.value = footv;
              header.value = text.cname!;
            });
          }
          return null;
        } else {
          child = text.content[_currentPage - 1];
        }
        break;
      } else if (contentIndex < 0) {
        if (_caches.containsKey(text.pid)) {
          text = _getTextData(text.pid!)!;
          currentContentFirstIndex -= text.content.length;
        } else {
          break;
        }
      } else if (contentIndex >= length) {
        if (_caches.containsKey(text.nid)) {
          currentContentFirstIndex += length;
          text = _getTextData(text.nid!)!;
        } else {
          break;
        }
      }
    }

    return child;
  }
}

mixin Configs on ContentDataBase, ContentStatus {
  final config = ValueNotifier<ContentViewConfig>(ContentViewConfig());
  // -------
  Duration lastStamp = Duration.zero;

  late final autoValue = ValueNotifier<double>(1.12);

  Future<void> setPrefs(ContentViewConfig _config) async {
    var flush = false;
    final _fontSize = _config.fontSize!;
    final _height = _config.lineTweenHeight!;
    final _fontColor = _config.fontColor!;
    final _fontFamily = _config.fontFamily!;
    final _axis = _config.axis!;
    final _orientation = _config.orientation!;

    var align = _axis != config.value.axis;

    if (_fontSize != config.value.fontSize ||
        _fontFamily != config.value.fontFamily ||
        _fontColor != config.value.fontColor ||
        _height != config.value.lineTweenHeight ||
        align) {
      flush = true;
    }
    final orientation = config.value.orientation;

    config.value = _config;

    if (flush) {
      final done =
          currentPage == tData.content.length || currentPage == 1 || align
              ? resetController
              : null;
      startFirstEvent(onStart: done);
    }
    if (orientation != _orientation) {
      await uiOverlay(hide: !_orientation);
      setOrientation(_orientation);
    }
  }

  late TextStyle style;
  late TextStyle secstyle;
  Future<void> initConfigs() async {
    final box = await Hive.openBox('settings');
    var _bgcolor = box.get('bgcolor', defaultValue: Color(0xffe3d1a8));
    var _fontColor = box.get('fontColor', defaultValue: Color(0xff4e4e4e));
    var axis = box.get('axis', defaultValue: Axis.horizontal);
    final _fontSize = box.get('fontSize', defaultValue: 18.0);
    final _height = box.get('lineTweenHeight', defaultValue: 1.6);
    final _fontFamily = box.get('fontFamily', defaultValue: '');

    final _portrait = box.get('portrait', defaultValue: true);
    final _autoValue = box.get('autoValue', defaultValue: 1.12);

    // 适配
    if (_bgcolor is int) {
      await box.delete('bgcolor');
      _bgcolor = box.get('bgcolor', defaultValue: Color(0xffe3d1a8));
    }
    if (axis is int) {
      await box.delete('axis');
      axis = box.get('axis', defaultValue: Axis.horizontal);
    }
    if (_fontColor is int) {
      await box.delete('fontColor');
      _fontColor = box.get('fontColor', defaultValue: Color(0xff4e4e4e));
    }

    await box.close();
    config.value.fontSize = _fontSize;
    config.value.lineTweenHeight = _height;
    config.value.bgcolor = _bgcolor;
    config.value.fontFamily = _fontFamily;
    config.value.fontColor = _fontColor;
    config.value.axis = axis;
    config.value.orientation = _portrait;

    autoValue.value = _autoValue;

    style = _getStyle(config.value);
    secstyle = style.copyWith(
      fontSize: contentFooterSize,
      leadingDistribution: TextLeadingDistribution.even,
    );
    config.addListener(configListen);
    autoValue.addListener(configListen);
  }

  TextStyle _getStyle(ContentViewConfig config) {
    return TextStyle(
      locale: const Locale('zh', 'CN'),
      fontSize: config.fontSize,
      color: config.fontColor!,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      // fontFamily: 'NotoSansSC', // SourceHanSansSC
      // fontFamilyFallback: ['RobotoMono', 'NotoSansSC'],
    );
  }

  Future? _configF;
  void configListen() async {
    style = _getStyle(config.value);
    secstyle = style.copyWith(
      fontSize: contentFooterSize,
      leadingDistribution: TextLeadingDistribution.even,
    );

    await _configF;

    _configF ??= () async {
      final _config = config.value;
      final box = await Hive.openLazyBox('settings');
      var _bgcolor = await box.get('bgcolor');
      var _fontColor = await box.get('fontColor');
      var axis = await box.get('axis');
      final _fontSize = await box.get('fontSize');
      final _height = await box.get('lineTweenHeight');
      final _fontFamily = await box.get('fontFamily');
      final _portrait = await box.get('portrait');
      final _autoValue = await box.get('autoValue');

      if (_bgcolor != _config.bgcolor)
        await box.put('bgcolor', _config.bgcolor);
      if (_fontColor != _config.fontColor)
        await box.put('fontColor', _config.fontColor);
      if (axis != _config.axis) await box.put('axis', _config.axis);

      if (_portrait != _config.orientation)
        await box.put('portrait', _config.orientation);
      if (_fontSize != _config.fontSize && _config.fontSize! > 0)
        await box.put('fontSize', _config.fontSize);

      if (_height != _config.lineTweenHeight && _config.lineTweenHeight! >= 1.0)
        await box.put('lineTweenHeight', _config.lineTweenHeight);

      if (_fontFamily != _config.fontFamily && _config.fontFamily!.isNotEmpty)
        await box.put('fontFamily', _config.fontFamily);

      if (_autoValue != autoValue.value)
        await box.put('autoValue', autoValue.value);

      await box.close();
    }()
      ..whenComplete(() => _configF = null);
    return _configF;
  }
}

mixin ContentAuto on ContentDataBase, Configs, ContentTasks {
  late final autoRun = AutoRun(_autoTick, () => lastStamp = Duration.zero);

  void auto() {
    if (config.value.axis == Axis.vertical) {
      _auto();
      return;
    }
    setPrefs(config.value.copyWith(axis: Axis.vertical));
    if (controller != null && controller!.axis == Axis.vertical) {
      _auto();
      return;
    }
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (controller != null && controller!.axis == Axis.vertical) {
        timer.cancel();
        _auto();
      }
      if (initQueue.actived) return;

      if (timer.tick > 5) timer.cancel();
    });
  }

  void _auto() {
    if (config.value.axis == Axis.horizontal) return;
    autoRun.value = !autoRun.value;
    if (autoRun.value) {
      controller?.setPixels(controller!.pixels + 0.1);
      scheduleTask();
      EventQueue.runOneTaskOnQueue(_auto, autoRun.start);
    } else {
      EventQueue.runOneTaskOnQueue(_auto, autoRun.stopTicked);
    }
  }

  void _autoTick(Duration timeStamp) {
    if (controller == null ||
        controller!.pixels == controller!.maxExtent ||
        !inBook ||
        !autoRun.value ||
        initQueue.actived ||
        config.value.axis == Axis.horizontal) {
      autoRun.stopTicked();
      return;
    }

    final _start = controller!.pixels;

    final _e = timeStamp - lastStamp;
    lastStamp = timeStamp;

    final alpha = (_e.inMicroseconds / mic);

    controller!.setPixels(_start + autoValue.value * alpha);

    if (timeStamp > const Duration(minutes: 1) && !autoRun._wait) {
      final wait = autoRun.wait();
      if (wait) {
        Timer(const Duration(milliseconds: 100), autoRun.waitRun);
      }
    }
  }
}

class ContentBoundary {
  static int addLeft = 1;
  static const int addRight = 2;
  static const int empty = 3;
  static bool hasLeft(int i) => i & addLeft != 0;
  static bool hasRight(int i) => i & addRight != 0;
}

class ContentViewConfig {
  ContentViewConfig({
    this.fontSize,
    this.lineTweenHeight,
    this.bgcolor,
    this.fontFamily,
    this.fontColor,
    this.locale,
    this.axis,
    this.orientation,
    this.audio,
  });
  double? fontSize;
  double? lineTweenHeight;
  Color? bgcolor;
  String? fontFamily;
  Color? fontColor;
  Locale? locale;
  Axis? axis;
  bool? orientation;
  bool? audio;

  ContentViewConfig copyWith({
    double? fontSize,
    double? lineTweenHeight,
    Color? bgcolor,
    int? fontFamily,
    Color? fontColor,
    Locale? locale,
    Axis? axis,
    bool? orientation,
    bool? audio,
  }) {
    return ContentViewConfig(
        fontColor: fontColor ?? this.fontColor,
        fontFamily: fontFamily as String? ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        lineTweenHeight: lineTweenHeight ?? this.lineTweenHeight,
        bgcolor: bgcolor ?? this.bgcolor,
        locale: locale ?? this.locale,
        axis: axis ?? this.axis,
        audio: audio ?? this.audio,
        orientation: orientation ?? this.orientation);
  }

  bool get isEmpty {
    return bgcolor == null ||
        fontSize == null ||
        fontColor == null ||
        axis == null ||
        lineTweenHeight == null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ContentViewConfig &&
            fontColor == other.fontColor &&
            fontFamily == other.fontFamily &&
            fontSize == other.fontSize &&
            lineTweenHeight == other.lineTweenHeight &&
            bgcolor == other.bgcolor &&
            locale == other.locale &&
            axis == other.axis &&
            audio == other.audio &&
            orientation == other.orientation;
  }

  @override
  String toString() {
    return '$runtimeType: fontSize: $fontSize, bgcolor: $bgcolor, fontColor:'
        ' $fontColor, lineTweenHeight: $lineTweenHeight,'
        ' fontFamily: $fontFamily,  local: $locale, axis: $axis';
  }

  @override
  int get hashCode => hashValues(fontColor, fontFamily, fontSize,
      lineTweenHeight, bgcolor, locale, axis, audio, orientation);
}

class NotifyMessage {
  const NotifyMessage._(this.error, {this.msg = ''});
  static const hide = NotifyMessage._(false, msg: '');
  static const netWorkError = NotifyMessage._(true, msg: '网络错误');
  static const noNextError = NotifyMessage._(true, msg: '已经是最后一章了');
  final bool error;
  final String msg;
}

class AutoRun {
  AutoRun(this.onTick, this.reset);
  final VoidCallback reset;
  final void Function(Duration) onTick;

  final isActive = ValueNotifier(false);

  bool get value => isActive.value;
  set value(bool v) {
    isActive.value = v;
    EventQueue.runTaskOnQueue('autoRun_wake', () => Wakelock.toggle(enable: v));
  }

  Ticker? _ticker;
  bool _ignore = false;
  void start() {
    assert(_ticker == null || !_ticker!.isActive);
    stopTicked();
    value = true;
    _ticker = Ticker((timeStamp) {
      if (_ignore) {
        _ignore = false;
        return;
      }
      _ignore = true;
      onTick(timeStamp);
    }, debugLabel: 'autoRun')
      ..start();
  }

  void stopTicked() {
    _ticker?.dispose();
    _ticker = null;
    reset();
    _wait = false;
    value = false;
  }

  bool get _running => _ticker?.isActive == true;
  bool get _stop => _ticker?.isActive == false;

  bool _wait = false;
  bool wait() {
    if (_running) {
      _ticker?.stop();
      reset();
      _wait = true;
      return true;
    }
    return false;
  }

  void waitRun() {
    if (value && _wait && _stop) {
      _ticker?.start();
      _wait = false;
    }
  }

  bool _lastActive = false;
  void stopSave() {
    if (isActive.value) {
      _lastActive = true;
      stopTicked();
    }
  }

  void stopAutoRun() {
    if (_lastActive) {
      start();
      _lastActive = false;
    }
  }
}

extension FutureTasksMap<T, E> on Map<T, Future<E>> {
  // 将一个异步任务添加到任务列表中，并在完成之后自动删除
  void addTask(
    T key,
    Future<E> f, {
    void Function()? callback,
    void Function(T)? solve,
    void Function(Future<E>)? solveTask,
  }) {
    assert(Log.i('addTask: $key'));
    if (containsKey(key)) {
      return;
    }
    this[key] = f;

    f.whenComplete(() {
      assert(Log.i('task $key: completed'));
      solve?.call(key);
      solveTask?.call(f);
      callback?.call();
      remove(key);
    });
  }

  Future<E>? awaitKey(T? key) => this[key];

  bool isLoading(T? key) => containsKey(key);
}
