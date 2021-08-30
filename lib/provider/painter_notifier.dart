import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';
import 'package:hive/hive.dart';
import 'package:useful_tools/useful_tools.dart';

import '../database/database.dart';
import '../event/event.dart';
import '../pages/book_content/widgets/page_view_controller.dart';

import 'constansts.dart';

enum Status { ignore, error, done }

class TextData {
  const TextData(
      {List<ContentMetrics> content = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.rawContent,
      bool? hasContent})
      : _content = content,
        _hasContent = hasContent;
  List<ContentMetrics> get content => _content;
  final List<ContentMetrics> _content;
  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final bool? _hasContent;
  final List<String>? rawContent;
  bool get hasContent => _hasContent ?? false;
  bool get isEmpty =>
      content.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      _hasContent == null;

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TextData &&
            cid == other.cid &&
            pid == other.pid &&
            nid == other.nid &&
            content == other.content &&
            cname == other.cname &&
            hasContent == other.hasContent;
  }

  @override
  int get hashCode => hashValues(cid, pid, nid, content, cname, hasContent);

  @override
  String toString() {
    return 'cid: $cid, pid: $pid, nid: $nid, cname: $cname';
  }
}

class ContentNotifier extends ChangeNotifier {
  ContentNotifier({required this.repository});

  final Repository repository;
  int bookid = -1;
  int currentPage = 1;
  int _innerIndex = 0;
  //状态栏显隐状态
  bool uiOverlayShow = false;

  final config = ValueNotifier<ContentViewConfig>(ContentViewConfig());
  // 同步----
  Future? get enter => initQueue.runner;
  Future? _configF;
  Future? _autoF;
  Future? _willGoF;
  // -------
  Duration? lastStamp;

  late final autoRun = AutoRun(_autoTick, () => lastStamp = null);

  late final autoValue = ValueNotifier<double>(6.0);

  bool showrect = false;

  Size size = Size.zero;

  final safePaddingNotifier = ValueNotifier<bool>(false);

  var _safePadding = EdgeInsets.zero;

  EdgeInsets get safePadding => _safePadding;

  set safePadding(EdgeInsets e) {
    if (_safePadding == e) return;
    _safePadding = e;
    safePaddingNotifier.value = !safePaddingNotifier.value;
  }

  var paddingRect = EdgeInsets.zero;

  ValueNotifier<double> get safeBottom => repository.safeBottom;

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

  ///-------------------------

  // 所有异步任务
  final _futures = <int, Future>{};
  final _disposeFutures = <Future>[];
  // 缓存池
  final _caches = <int, TextData>{};
  final _ids = <int?>[];

  // 记录重新下载的id，并延迟删除，避免频繁访问
  final _reloadIds = <int>{};

  int get tasksLength => _futures.length;
  Future get waitTasks => Future.wait(List.of(_futures.values));

  bool _inBookView = false;
  bool _scheduled = false;

  TextData _tData = TextData();

  TextData get tData => _tData;

  set tData(TextData data) {
    if (data == _tData) return;
    assert(data.contentIsNotEmpty, '不该为 空');
    _tData = data;
    dump();
    updateCaches(data);
    // if (config.value.audio == true) {
    //   _dataQueue.addOneEventTask(() => _tdataRun());
    // }
  }

  // final _dataQueue = EventQueue();
  // Future<void> _tdataRun() async {
  //   final local = _tData;
  //   Log.w('progress: ....');
  //   tts.speak(local.rawContent.join());
  //   // for (final text in local.rawContent) {
  //   //   if (local != _tData || config.value.audio != true || !inBook) {
  //   //     break;
  //   //   }

  //   //   await tts.speak(text);

  //   //   await tts.awaitSpeakCompletion(true);
  //   //   Log.w('progress: speak', onlyDebug: false);
  //   // }
  // }

  /// 当前章节无效，初始加载，设置更改，重新加载
  final initQueue = EventQueue();

  final _taskEvent = EventQueue();
  Future? get taskRunner => _taskEvent.runner;

  ///-------------------------

  // 加载状态
  // 是否直接忽略
  // 显示网络错误信息
  final _loading = ValueNotifier(false);
  final _ignore = ValueNotifier(false);
  final _error = ValueNotifier(NotifyMessage.hide);

  NopPageViewController? controller;
  ValueListenable<bool> get loading => _loading;
  ValueListenable<bool> get notEmptyOrIgnore => _ignore;
  ValueListenable<NotifyMessage> get error => _error;
  Listenable get listenable => Listenable.merge([loading, error]);
  final header = ValueNotifier<String>('');
  final footer = ValueNotifier<String>('');

  late TextStyle style;
  late TextStyle secstyle;
  final showCname = ValueNotifier(false);
  final mic = Duration.microsecondsPerMillisecond * 200.0;

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

  // brightness
  final _brightness = EventQueue();
  final brightness = ValueNotifier(0.0);
  // void updateBrightness() {
  //   Log.w('updateBrightness', onlyDebug: false);
  //   _brightness.addOneEventTask(() => _fo());
  // }
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

  // void awaitReloadBrightness() {
  //   _brightness.addEventTask(() async {
  //     await release(const Duration(milliseconds: 300));
  //     return _fo();
  //   });
  // }

  void reloadBrightness() {
    _brightness.addOneEventTask(() => _fo());
  }

  Future<void> _fo() async {
    if (_brightNess) brightness.value = await ScreenBrightness.current;
  }

  // late FlutterTts tts = FlutterTts()
  //   ..setLanguage('zh-CN')
  //   // ..setSpeechRate(0.8)
  //   ..setProgressHandler(_ttsProgress);

  // void _ttsProgress(String text, int start, int end, String word) {
  //   ttsProgress.value = 'progress: $text: $start - $end, $word';
  //   Log.w(ttsProgress.value, onlyDebug: false);
  // }

  // final ttsQueue = EventQueue();
  // final ttsProgress = ValueNotifier('');

  // void addTextToVoice(String text) {
  //   if (config.value.audio == true) {
  //     ttsQueue.addEventTask(() => tts.awaitSpeakCompletion(true));
  //     ttsQueue.addEventTask(() => tts.speak(text));
  //   }
  // }

  // Future addTextToVoiceAndAwait(String text) async {
  //   if (config.value.audio == true) {
  //     // ttsQueue.addEventTask(() => tts.awaitSpeakCompletion(true));
  //     await tts.speak(text);
  //     return tts.awaitSpeakCompletion(true);
  //   }
  // }

  // void ttsStop() {
  //   if (config.value.audio == true) {
  //     ttsQueue.addEventTask(() => tts.stop());
  //   }
  // }

  // void ttsStopAndStartCurrent() {
  //   ttsStop();
  // }

  final bool _brightNess = Platform.isAndroid || Platform.isIOS;
}

extension ContentStatus on ContentNotifier {
  void out() {
    if (!inBook) return;
    uiOverlayShow = false;
    _inBookView = false;
    _notifyCustom();
    if (_brightNess)
      _brightness.addOneEventTask(() async {
        await ScreenBrightness.resetScreenBrightness();

        return _fo();
      });
  }

  bool get inBook => _inBookView;
  void inbook() {
    if (_inBookView) return;
    _inBookView = true;
    if (!follow.value) {
      final _old = _lastBrightness;
      if (_old != null) {
        setBrightness(_old);
      }
    }
  }

  // _innerIndex == page == 0
  void resetController() {
    controller?.goIdle();
    _innerIndex = 0;
    controller?.correct(0.0);
  }
}

extension DataLoading on ContentNotifier {
  Future<void> reset({bool clearCache = false}) async {
    if (clearCache) {
      if (_caches.isNotEmpty) {
        var _c = List.of(_caches.values);
        _caches.clear();
        for (var t in _c) {
          for (var p in t.content) {
            p.picture.dispose();
          }
        }
      }
      //  _c.forEach((element) {element.content.forEach((element) {element.picture.dispose();})});

      if (_futures.isNotEmpty) {
        final _tasks = List.of(_futures.values);

        _disposeFutures.addAll(_tasks);
        final f = FutureAny()..addAll(_disposeFutures);
        await f.wait;
        // await Future.wait(_disposeFutures);
      }
      if (_caches.isNotEmpty) {
        var _c = List.of(_caches.values);
        _caches.clear();
        for (var t in _c) {
          for (var p in t.content) {
            p.picture.dispose();
          }
        }
      }
    }
    // _tData = TextData(cid: cid ?? tData.cid);
    _getCurrentIds();
  }

  Future<void> dump() async {
    final cid = tData.cid;
    final _bookid = bookid;
    if (cid == null || _bookid == -1) return;
    final _currentPage = currentPage;
    final u = BookCache(
      page: _currentPage,
      isNew: false,
      chapterId: cid,
      sortKey: sortKey,
    );
    await repository.bookEvent.bookCacheEvent.updateBook(_bookid, u);
  }

  void notifyState(
      {bool? loading, bool? notEmptyOrIgnore, NotifyMessage? error}) {
    if (loading != null) _loading.value = loading;
    if (notEmptyOrIgnore != null) _ignore.value = notEmptyOrIgnore;
    if (error != null) _error.value = error;
  }

  /// 文本加载-----------------

  void addCache(TextData _cnpid) {
    assert(_cnpid.contentIsNotEmpty);
    _caches[_cnpid.cid!] = _cnpid;
  }

  TextData? _getTextData(int? key) => _caches[key];

  // 更新队列
  void updateCaches(TextData data) {
    final _keys = _getCurrentIds();

    if (_caches.length > _keys.length + 2) {
      final _dirtys = <TextData>[];
      _caches.removeWhere((key, data) {
        final remove = !_keys.contains(key);
        if (remove) _dirtys.add(data);
        return remove;
      });
      scheduleMicrotask(() {
        for (var mes in _dirtys) {
          for (var p in mes._content) {
            p.picture.dispose();
          }
        }
      });
    }
  }

  Future<void> loadData(int _contentKey, int _bookid) async {
    if (_caches.containsKey(_contentKey)) return;
    await load(_bookid, _contentKey);
  }

  Future<void> load(int _bookid, int contentid, {bool update = false}) async {
    EventQueue.currentTask?.value = contentid;
    if (_ignoreTask(update: update) || _bookid == -1 || contentid == -1) return;

    final lines =
        await repository.bookEvent.getContent(_bookid, contentid, update);
    if (_ignoreTask(update: update)) return;

    if (lines != null && lines.contentIsNotEmpty) {
      final pages = await _asyncLayout(lines.pages, lines.cname!);

      if (pages.isEmpty || _ignoreTask(update: update)) return;
      final _cnpid = TextData(
        content: pages,
        nid: lines.nid,
        pid: lines.pid,
        cid: lines.cid,
        hasContent: lines.hasContent,
        cname: lines.cname,
        rawContent: lines.pages,
      );
      addCache(_cnpid);
    }
  }
}

extension Tasks on ContentNotifier {
  /// 任务逻辑----------------
  /// 首次（重置）加载
  Future<void> _loadFirst() async {
    if (tData.cid == null) return;
    final _bookid = bookid;
    final _key = tData.cid!;
    assert(Log.i('cid: $_key'));
    _loadWithId(_key);

    await _futures.awaitId(_key);

    final _currentText = _getTextData(_key);
    if (_bookid == bookid &&
        _currentText != null &&
        _currentText.contentIsNotEmpty &&
        _key == _currentText.cid) {
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

  void _loadTasks(int _bookid, int? contentid) {
    if (!inBook || _futures.length > 5) return;

    if (_bookid == bookid &&
        _bookid != -1 &&
        contentid != null &&
        contentid != -1 &&
        !_caches.containsKey(contentid) &&
        !_futures.isLoading(contentid)) {
      final _ntask =
          _taskEvent.addEventTask(() => loadData(contentid, _bookid));

      _futures.addTask(contentid, _ntask, solveTask: _onRemove);
    }
  }

  void _onRemove(Future task) {
    if (_disposeFutures.isNotEmpty) _disposeFutures.remove(task);
  }

  void _loadWithId(int? id) => _loadTasks(bookid, id);

  void scheduleTask() {
    if (_scheduled) return;
    scheduleMicrotask(() {
      _scheduled = false;
      _loadResolve();
      _loadAuto();
    });
    _scheduled = true;
  }

  void _loadAuto() {
    if (inBook)
      _getCurrentIds()
          .where((e) => !_caches.containsKey(e))
          .forEach(_loadWithId);
  }

  // 处于最后一章节时，查看是否有更新
  Future<void> _loadResolve() async {
    if (tData.nid == -1 || !tData.hasContent) {
      if (tData.contentIsEmpty) return;

      bool _getdata() {
        if (_caches.containsKey(tData.cid)) {
          if (tData.contentIsNotEmpty &&
              (currentPage == tData.content.length || currentPage == 1)) {
            final _tData = _getTextData(tData.cid!)!;
            if (tData != _tData) {
              tData = _tData;
              if (currentPage > tData.content.length) {
                currentPage = tData.content.length;
                if (config.value.axis == Axis.vertical) {
                  final footv = '$currentPage/${tData.content.length}页';
                  footer.value = footv;
                  header.value = tData.cname!;
                }
              }
              _notify();
              return true;
            }
          }
        }
        return false;
      }

      if (_getdata()) return;

      final cid = tData.cid!;
      if (_reloadIds.contains(cid)) return;
      assert(Log.w('nid = ${tData.nid}, hasContent: ${tData.hasContent}'));

      _reloadIds.add(cid);
      Future.delayed(const Duration(seconds: 10), () => _reloadIds.remove(cid));

      await _taskEvent.addEventTask(() => load(bookid, cid, update: true));
      _getdata();
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
    await _taskEvent.addEventTask(() => load(bookid, tData.cid!, update: true));
    final _data = _getTextData(tData.cid);
    if (_data != null && _data.contentIsNotEmpty) {
      tData = _data;
    }
    if (currentPage > tData.content.length) {
      currentPage = tData.content.length;
    }
    _notify();
  }

  Future<void> updateCurrent() => _reload().then((_) => _notify());

  Future<bool> _getContent(int getid) async {
    var _data = _getTextData(getid);
    if (_data == null || _data.contentIsEmpty) {
      _loadAuto();

      await _futures.awaitId(getid);

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

extension Layout on ContentNotifier {
  // ---------------------------------------

  bool _ignoreTask({bool update = false}) {
    final contentid = EventQueue.currentTask?.value;
    assert(contentid is int);
    if (_disposeFutures.remove(_futures[contentid])) return true;

    if (!inBook) return true;
    if (update) return false;
    final _thatData = _getTextData(contentid);
    if (_thatData != null && _thatData.contentIsNotEmpty) {
      if (_thatData.nid == -1 || !_thatData.hasContent) {
        return false;
      }
      return true;
    }

    return !_idSets.contains(contentid);
  }

  List<int?> get _idSets {
    if (_ids.isEmpty) _getCurrentIds();
    return _ids;
  }

  // 根据当前章节更新存活章节
  // 任务顺序与添加顺序一致
  //
  Iterable<int> _getCurrentIds() {
    _ids.clear();
    _ids.add(tData.cid);

    final current = _getTextData(tData.cid);
    final nid = current?.nid;
    final pid = current?.pid;

    _ids
      ..add(nid)
      ..add(pid);

    final next = _getTextData(nid);
    final nnid = next?.nid;
    _ids.add(nnid);
    // if (nnid != null) {
    //   final thirty = _getTextData(nnid);
    //   _ids
    //     ..add(nnid)
    //     ..add(thirty?.nid);
    // }

    // final pre = _getTextData(pid);
    // final prePid = pre?.pid;

    // if (prePid != null) _ids.add(prePid);

    return _ids.whereType<int>();
  }

  Future<void> get wait => releaseUI;

  Future<List<ContentMetrics>> _asyncLayout(
      List<String> paragraphs, String cname) async {
    var whiteRows = 0;

    final textPages = <ContentMetrics>[];

    final fontSize = style.fontSize!;

    final config = this.config.value.copyWith();

    final words = (size.width - paddingRect.horizontal) ~/ fontSize;

    final _size = paddingRect.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = paddingRect.left + leftExtraPadding;

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

    await wait;
    // 大标题
    final TextPainter _bigTitlePainter = TextPainter(
        text: TextSpan(
            text: cname,
            style: style.copyWith(
                fontSize: 22, height: 1.2, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);

    await wait;
    // 小标题
    final TextPainter smallTitlePainter = TextPainter(
        text: TextSpan(text: cname, style: secstyle),
        textDirection: TextDirection.ltr,
        maxLines: 1)
      ..layout(maxWidth: width);

    whiteRows = 150 ~/ lineHeightAndExtra + 1;

    await wait;
    while (lineHeightAndExtra * whiteRows > 150) {
      whiteRows--;
      if (lineHeightAndExtra * whiteRows < 120) break;
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

        // 确定每一行的字数
        while (true) {
          if (end >= pc.length) break;

          // await wait;

          end++;
          final s = pc.getRange(start, end).toString();
          _t
            ..text = TextSpan(text: s, style: style)
            ..layout(maxWidth: width);

          await wait;

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

        if (end == pc.length &&
            pc
                .getRange(start, end)
                .toString()
                .replaceAll(regexpEmpty, '')
                .isEmpty) break;

        final _s = pc.getRange(start, end);

        await wait;

        final _text = TextPainter(
            text: TextSpan(text: _s.toString(), style: style),
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: width);

        start = end;
        lines.add(_text);
      }
    }

    await wait;
    var topExtraRows = (_bigTitlePainter.height / fontSize).floor();

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

    // 添加页面信息
    for (var r = 0; r < pages.length; r++) {
      await wait;
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);

      final right = width - bottomRight.width - leftExtraPadding * 2;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      await paint(canvas,
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
          windowTopPadding: safePadding.top,
          showrect: showrect,
          topExtraHeight: lineHeightAndExtra * (whiteRows + topExtraRows));

      final picture = recorder.endRecording();

      final met = ContentMetrics(
        picture: PictureRefInfo(picture),
        secstyle: secstyle,
        left: left,
        size: _size,
        bottom: paddingRect.bottom,
      );
      textPages.add(met);
    }

    return textPages;
  }

  Future<void> paint(Canvas canvas,
      {required List<TextPainter> painters,
      required double extraHeight,
      required double fontSize,
      required bool isHorizontal,
      required TextPainter titlePainter,
      required TextPainter bottomRight,
      required TextPainter cBigPainter,
      required double right,
      required double left,
      required int index,
      required Size size,
      required double windowTopPadding,
      required bool showrect,
      required double topExtraHeight}) async {
    final _size = size;
    final _windowTopPadding = isHorizontal ? windowTopPadding : 0.0;

    var h = 0.0;
    canvas.translate(left, _windowTopPadding);
    if (isHorizontal) {
      h += contentTopPad;
      titlePainter.paint(canvas, Offset(0.0, h));
      // h += titlePainter.height;
      h += contentFooterSize;
    }
    if (index == 0) {
      if (!isHorizontal) {
        h -= contentPadding;
      }
      h += topExtraHeight;
      cBigPainter.paint(canvas, Offset(0.0, h - cBigPainter.height));
      if (!isHorizontal) {
        h += contentPadding;
      }
    }
    await wait;

    if (isHorizontal) h += contentPadding;

    final xh = h;
    final _e = extraHeight / 2;
    final _end = _e + fontSize;
    for (var _tep in painters) {
      h += _e;
      _tep.paint(canvas, Offset(0.0, h));
      h += _end;
    }
    if (showrect) {
      canvas.drawRect(Rect.fromLTWH(0.0, xh, _size.width, h - xh),
          Paint()..color = Colors.black.withAlpha(100));
    }
    if (isHorizontal) {
      bottomRight.paint(canvas,
          Offset(right, _size.height - contentFooterSize - contentBotttomPad));
    }
  }
}

extension Event on ContentNotifier {
  Future<void> showdow() async {
    showrect = !showrect;
    if (inBook && tData.cid != null) {
      if (initQueue.runner == null) {
        loadFirstEvent();
      } else {
        initQueue.runner!.whenComplete(loadFirstEvent);
      }
      return initQueue.runner;
    }
  }

  /// 进入阅读页面前，必须调用的方法
  void touchBook(int newBookid, int cid, int page, Object taskKey) {
    if (!inBook) resetController();
    inbook();
    footer.value = '';
    header.value = '';
    setOrientation(config.value.orientation!);

    newBookOrCid(newBookid, cid, page, taskKey: taskKey);
  }

  bool _getStateOrSetBook(int newBookid, int cid, int page,
      {bool only = false}) {
    if (tData.cid != cid || bookid != newBookid) {
      if (!only) {
        assert(Log.i('new: $newBookid $cid'));

        notifyState(notEmptyOrIgnore: true, loading: false);

        _tData = TextData(cid: cid);
        currentPage = page;
        bookid = newBookid;
      }
      return true;
    }
    return false;
  }

  Future<T?> addInitEventTask<T>(EventCallback<T> callback, {Object? taskKey}) {
    return callback.pushOne(initQueue, taskKey: taskKey);
    // return initQueue.addOneEventTask(callback, taskKey: taskKey);
  }

  Future<void> loadFirstEvent({
    bool zero = true,
    Object? taskKey,
    void Function()? onStart,
    void Function()? onResetDone,
    void Function()? onDone,
  }) {
    return () async {
      autoRun.stopSave();
      onStart?.call();
      await reset(clearCache: zero);

      onResetDone?.call();
      await _loadFirst();
      _notify();

      /// 重置边界
      controller?.applyConentDimension(
          minExtent: double.negativeInfinity, maxExtent: double.infinity);
      onDone?.call();

      scheduleMicrotask(autoRun.stopAutoRun);
    }.pushOne(initQueue, taskKey: taskKey);
  }

  Future<void> newBookOrCid(int newBookid, int cid, int page,
      {Object? taskKey}) async {
    if (!inBook) return;

    if (cid == -1) return;
    final _reset = _getStateOrSetBook(newBookid, cid, page, only: true);
    if (tData.contentIsEmpty || _reset) {
      final _t = Timer(
          const Duration(milliseconds: 600), () => notifyState(loading: true));

      await loadFirstEvent(
          zero: false,
          onStart: () => _getStateOrSetBook(newBookid, cid, page),
          onDone: resetController,
          taskKey: taskKey);

      _t.cancel();
    }
  }

  void metricsChange(MediaQueryData data) {
    if (inBook || size.isEmpty) {
      if (size.isEmpty) size = data.size;
      final changed = _modifiedSize(data);
      if (changed) {
        if (tData.cid != null) {
          loadFirstEvent(onStart: () {
            resetController();
            notifyState(notEmptyOrIgnore: true);
          });
        }
      }
    }
  }

  Future<void> reload() async {
    notifyState(loading: true, notEmptyOrIgnore: true);
    loadFirstEvent(zero: false);
    return initQueue.runner;
  }

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
    if (tData.contentIsEmpty || initQueue.runner != null) return;
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

  bool _modifiedSize(MediaQueryData data) {
    var _size = data.size;
    var _p = data.padding;

    safePadding = _p;
    paddingRect = EdgeInsets.only(
      left: safePadding.left + 16,
      top: safePadding.top,
      right: safePadding.right + 16,
      bottom: defaultTargetPlatform == TargetPlatform.iOS ? 10.0 : 4.0,
    );

    if (size != _size) {
      size = _size;
      return true;
    } else {
      return false;
    }
  }
}

extension ContentGetter on ContentNotifier {
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

extension Configs on ContentNotifier {
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

    if (_orientation != orientation) {
      await setOrientation(_orientation);
    }

    config.value = _config;

    // if (config.value.audio == true) {
    //   Log.e('audio: true');
    //   _dataQueue.addOneEventTask(() => _tdataRun());
    // } else if (config.value.audio == false) {
    //   Log.e('audio: false');
    //   // tts.awaitSpeakCompletion(false);
    //   _dataQueue.addEventTask(() => tts.stop());
    // }

    if (flush) {
      final done =
          currentPage == tData.content.length || currentPage == 1 || align
              ? resetController
              : null;
      loadFirstEvent(onResetDone: done);
    }
  }

  Future<void> initConfigs() async {
    final box = await Hive.openBox('settings');
    var _bgcolor = box.get('bgcolor', defaultValue: Color(0xffe3d1a8));
    var _fontColor = box.get('fontColor', defaultValue: Color(0xff4e4e4e));
    var axis = box.get('axis', defaultValue: Axis.horizontal);
    final _fontSize = box.get('fontSize', defaultValue: 18.0);
    final _height = box.get('lineTweenHeight', defaultValue: 1.6);
    final _fontFamily = box.get('fontFamily', defaultValue: '');

    final _portrait = box.get('portrait', defaultValue: true);
    final _autoValue = box.get('autoValue', defaultValue: 6.0);

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
      // version: ^2.2.0
      leadingDistribution: TextLeadingDistribution.even,
      // height: 1.2,
    );
    config.addListener(configListen);
    autoValue.addListener(configListen);
  }

  Future? configListen() async {
    style = _getStyle(config.value);
    secstyle = style.copyWith(
      fontSize: contentFooterSize,
      leadingDistribution: TextLeadingDistribution.even,
      // height: 1.2,
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

extension AutoR on ContentNotifier {
  void auto() {
    if (config.value.axis == Axis.vertical) {
      _auto();
      return;
    }
    setPrefs(config.value.copyWith(axis: Axis.vertical)).then((_) async {
      if (controller != null && controller!.axis == Axis.vertical) {
        _auto();
        return;
      }
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (controller != null && controller!.axis == Axis.vertical) {
          timer.cancel();
          _auto();
        }

        if (timer.tick > 5) timer.cancel();
      });
    });
  }

  void _auto() {
    if (config.value.axis == Axis.horizontal) return;
    autoRun.value = !autoRun.value;
    if (autoRun.value) {
      controller?.setPixels(controller!.pixels + 0.1);
      scheduleTask();
      _autoF ??= EventQueue.scheduler.endOfFrame.then((_) => autoRun.start())
        ..whenComplete(() => _autoF = null);
    } else {
      if (_autoF != null) {
        _autoF!.then((_) => autoRun.stopTicked());
        return;
      }
      autoRun.stopTicked();
    }
  }

  void _autoTick(Duration timeStamp) {
    if (controller == null ||
        controller!.pixels == controller!.maxExtent ||
        !inBook ||
        !autoRun.value ||
        enter != null ||
        config.value.axis == Axis.horizontal) {
      autoRun.stopTicked();
      return;
    }

    final _start = controller!.pixels;

    if (lastStamp == null) {
      lastStamp = timeStamp;

      return;
    }
    final _e = timeStamp - lastStamp!;
    lastStamp = timeStamp;

    final alpha = (_e.inMicroseconds / mic);

    controller!.setPixels(_start + autoValue.value * alpha);
  }
}

class ContentMetrics {
  const ContentMetrics({
    // required this.painters,
    // required this.extraHeightInLines,
    // required this.isHorizontal,
    required this.secstyle,
    // required this.fontSize,
    // required this.cPainter,
    // required this.botRightPainter,
    // required this.cBigPainter,
    // required this.right,
    required this.left,
    // required this.index,
    required this.size,
    // required this.windowTopPadding,
    // required this.showrect,
    // required this.topExtraHeight,
    required this.bottom,
    required this.picture,
  });
  // final List<TextPainter> painters;
  // final double extraHeightInLines;
  final TextStyle secstyle;
  // final double fontSize;
  // final bool isHorizontal;
  // final TextPainter cPainter;
  // final TextPainter botRightPainter;
  // final TextPainter cBigPainter;
  // final double right;
  final double left;
  // final int index;
  final Size size;
  // final double windowTopPadding;
  // final bool showrect;
  // final double topExtraHeight;
  final double bottom;
  final PictureRefInfo picture;
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
  const NotifyMessage(this.error, {this.msg = network});
  static const hide = NotifyMessage(false, msg: '');
  static const netWorkError = NotifyMessage(true, msg: network);
  static const noNextError = NotifyMessage(true, msg: noNext);
  static const network = '网络错误';
  static const noNext = '已经是最后一章了';
  final bool error;
  final String msg;
}

class AutoRun {
  AutoRun(this.onTick, this.reset);
  final VoidCallback reset;
  final void Function(Duration) onTick;

  final isActive = ValueNotifier(false);

  bool get value => isActive.value;
  final _asyncQueue = EventQueue();
  set value(bool v) {
    isActive.value = v;
    _asyncQueue
        .addOneEventTask(() => v ? Wakelock.enable() : Wakelock.disable());
  }

  Ticker? _ticker;
  void start() {
    _ticker?.dispose();
    value = true;
    _ticker = Ticker(onTick, debugLabel: 'autoRun')..start();
  }

  void stopTicked() {
    _ticker?.dispose();
    reset();
    value = false;
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
  void addTask(T id, Future<E> f,
      {void Function()? callback,
      void Function(T)? solve,
      void Function(Future<E>)? solveTask}) {
    Log.i('addTask $id');
    if (containsKey(id)) return;
    this[id] = f;
    f.whenComplete(() {
      Log.i('task complete $id');
      solve?.call(id);
      solveTask?.call(f);
      callback?.call();
      remove(id);
    });
  }

  Future? awaitId(T? id) => this[id];

  bool isLoading(T? id) => containsKey(id);
}
