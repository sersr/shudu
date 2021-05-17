import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../pages/book_content_view/widgets/battery_view.dart';
import '../pages/book_content_view/widgets/content_view.dart';
import '../pages/book_content_view/widgets/page_view_controller.dart';
import '../utils/utils.dart';
import 'bloc.dart';

typedef WidgetCallback = Widget? Function(int page, {bool changeState});
typedef SetPageNotifier = void Function(double, void Function(int page));
typedef FutureCallback<T> = FutureOr<T> Function();

class PainterState {
  PainterState();
}

enum Status { ignore, error, done }

class TextData {
  TextData({List<ContentMetrics> content = const [], this.cid, this.pid, this.nid, this.cname, this.hasContent})
      : _content = content;
  List<ContentMetrics> get content => _content;
  final List<ContentMetrics> _content;
  int? cid;
  int? pid;
  int? nid;
  String? cname;
  int? hasContent;
  bool get isEmpty =>
      content.isEmpty || cid == null || pid == null || nid == null || cname == null || hasContent == null;

  bool get isNotEmpty => !isEmpty;
  void clear() {
    content.clear();
    pid = nid = cname = null;
  }

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
  int get hashCode => hashValues(this, cid, pid, nid, content, cname, hasContent);

  @override
  String toString() {
    return 'cid: $cid, pid: $pid, nid: $nid, cname: $cname';
  }
}

class ContentNotifier extends ChangeNotifier {
  ContentNotifier({required this.repository});

  final Repository repository;

  int? bookid;

  int currentPage = 1;

  final config = ValueNotifier<ContentViewConfig>(ContentViewConfig());

  Future<void> reload() async {
    notifyState(loading: true, ignore: true);

    await _nf;
    await _loadFirst();

    painter();
  }

  Future<void> metricsChange() async {
    // 实时
    final changed = await _modifiedSize();
    if (changed) {
      if (_inBookView && tData.cid != null && bookid != null) {
        await _nf;
        if (_inBookView) painter();

        notifyState(ignore: true);
        await reset(clearCache: true);
        await _loadFirst();

        if (_inBookView) painter();
      }
    }
  }

  Future goNext() => _willGoProOrNext(isPid: false);
  Future goPre() => _willGoProOrNext(isPid: true);

  void auto() {
    if (config.value.axis == Axis.vertical) {
      _auto();
      return;
    }
    setPrefs(config.value.copyWith(axis: Axis.vertical)).then((value) async {
      await EventLooper.instance.scheduler.endOfFrame;
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
    isActive.value = !isActive.value;
    if (isActive.value) {
      _autoRun();
    } else {
      stopAuto();
    }
  }

  final isActive = ValueNotifier(false);

  Duration? lastStamp;
  double? _start;

  late final autoValue = ValueNotifier<double>(6.0)..addListener(configListen);

  void _autoTick(Duration timeStamp) {
    if (controller == null ||
        controller!.pixels == controller!.maxExtent ||
        !_inBookView ||
        !isActive.value ||
        enter != null ||
        config.value.axis == Axis.horizontal) {
      stopAuto();
      return;
    }

    lastStamp ??= timeStamp;
    _start ??= controller!.pixels;
    final _e = timeStamp - lastStamp!;

    var millisecond = _e.inMicroseconds / Duration.microsecondsPerMillisecond;

    controller!.setPixels(_start! + millisecond / ((11 - autoValue.value) * 15).clamp(15, 150));
    _autoRun();
  }

  void resetAuto() {
    lastStamp = null;
    _start = null;
  }

  void _autoRun() {
    EventLooper.instance.scheduler.scheduleFrameCallback((a) {
      _autoTick(a);
    });
  }

  void stopAuto() {
    isActive.value = false;
    lastStamp = null;
    _start = null;
  }

  bool showrect = false;
  Future<void> showdow() async {
    showrect = !showrect;

    await reset(clearCache: true);

    await _nf;
    await _loadFirst();
    painter();
  }

  Future<void> setPrefs(ContentViewConfig _config) async {
    var flush = false;
    final _fontSize = _config.fontSize!;
    final _height = _config.lineTweenHeight!;
    final _fontColor = _config.fontColor!;
    final _fontFamily = _config.fontFamily!;
    final _axis = _config.axis!;
    final _portrait = _config.portrait!;

    if (_fontSize != config.value.fontSize ||
        _fontFamily != config.value.fontFamily ||
        _fontColor != config.value.fontColor ||
        _height != config.value.lineTweenHeight ||
        _axis != config.value.axis) {
      flush = true;
    }

    final resetTozero = _axis != config.value.axis;
    if (_portrait != config.value.portrait) await orientation(_portrait);
    config.value = _config;

    if (flush) {
      await reset(clearCache: true);
      if (resetTozero) resetController();
      await _nf;
      await _loadFirst();
    }
    painter();
  }

  Future<void> initConfigs() async {
    final box = await Hive.openBox('settings');
    var _bgcolor = box.get('bgcolor', defaultValue: Color(0xffe3d1a8));
    var _fontColor = box.get('fontColor', defaultValue: Color(0xff4e4e4e));
    var axis = box.get('axis', defaultValue: Axis.horizontal);
    final _fontSize = box.get('fontSize', defaultValue: 18.0);
    final _height = box.get('lineTweenHeight', defaultValue: 1.6);
    final _fontFamily = box.get('fontFamily', defaultValue: '');
    final _p = box.get('patternList', defaultValue: <String, String>{});
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
    config.value.patternList = _p;
    config.value.axis = axis;
    config.value.portrait = _portrait;

    autoValue.value = _autoValue;

    style = _getStyle(config.value);
    secstyle = style.copyWith(fontSize: pagefooterSize);
    config.addListener(configListen);
  }

  Future? _configF;
  Future? configListen() async {
    style = _getStyle(config.value);
    secstyle = style.copyWith(fontSize: pagefooterSize);

    _configF ??= () async {
      final _config = config.value;
      final box = await Hive.openBox('settings');
      var _bgcolor = box.get('bgcolor');
      var _fontColor = box.get('fontColor');
      var axis = box.get('axis');
      final _fontSize = box.get('fontSize');
      final _height = box.get('lineTweenHeight');
      final _fontFamily = box.get('fontFamily');
      final _p = box.get('patternList');
      final _portrait = box.get('portrait');
      final _autoValue = box.get('autoValue');

      if (_bgcolor != _config.bgcolor) await box.put('bgcolor', _config.bgcolor);
      if (_fontColor != _config.fontColor) await box.put('fontColor', _config.fontColor);
      if (axis != _config.axis) await box.put('axis', _config.axis);
      if (_p != _config.patternList) await box.put('patternList', _config.patternList);
      if (_portrait != _config.portrait) await box.put('portrait', _config.portrait);
      if (_fontSize != _config.fontSize && _config.fontSize! > 0) await box.put('fontSize', _config.fontSize);

      if (_height != _config.lineTweenHeight && _config.lineTweenHeight! >= 1.0)
        await box.put('lineTweenHeight', _config.lineTweenHeight);

      if (_fontFamily != _config.fontFamily && _config.fontFamily!.isNotEmpty)
        await box.put('fontFamily', _config.fontFamily);

      if (_autoValue != autoValue.value) box.put('autoValue', autoValue.value);

      await box.close();
    }()
      ..whenComplete(() => _configF = null);
    return _configF;
  }

  void uiOverlayState() {}

  Future? _nf;
  Future? get enter => _nf;

  Future<void> newBookOrCid(int newBookid, int cid, int page, {bool inBook = false}) async {
    _nf ??= _newBookOrCid(newBookid, cid, page, inBook)..whenComplete(() => _nf = null);
  }

  Future<bool> setNewBookOrCid(int newBookid, int cid, int page) async {
    if (tData.cid != cid || tData.contentIsEmpty || bookid != newBookid) {
      assert(Log.i('new: $newBookid $cid', stage: this, name: 'newBook'));

      final diffBook = bookid != newBookid;
      notifyState(ignore: diffBook || inBook || tData.contentIsEmpty, loading: false);

      out();

      await reset(clearCache: diffBook, cid: cid);
      currentPage = page;
      bookid = newBookid;

      await dump();
      return true;
    }
    return false;
  }

  Future<void> _newBookOrCid(int newBookid, int cid, int page, bool inBook) async {
    if (cid == -1) return;

    if (!_inBookView) _innerIndex = 0;
    // if (_innerIndex != 0 && (controller == null || controller!.page.round() == 0)) _innerIndex = 0;

    stopAuto();
    // final _lastInBookView = _inBookView;

    assert(_canLoad == null || _canLoad!.isCompleted);
    // if (!inBook) _canLoad = Completer<void>();

    orientation(config.value.portrait!);
    if (await setNewBookOrCid(newBookid, cid, page)) {
      await _modifiedSize();

      _getCurrentIds();

      final _t = Timer(const Duration(milliseconds: 500), () => notifyState(loading: true));

      inbook();
      await _loadFirst();

      _t.cancel();

      painter();
      resetController();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    inbook();
    // 异步
    // 如果没有加载完成，就要退出应该忽略
    notifyState(ignore: !_inBookView, loading: false);
    statusColor();
  }

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
  var safeBottom = 6.0;

  Future<bool> _modifiedSize() async {
    final w = ui.window;
    var _size = w.physicalSize / w.devicePixelRatio;
    var _p = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final _sizeOut = (await repository.getViewInsets()).size;

        if (_sizeOut != _size) {
          safeBottom = repository.bottomHeight.toDouble() + 6.0;
        }

        _p = repository.viewInsets.padding;
        _size = _sizeOut;
        break;

      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;

      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        if ((_p.top == 0.0 && safePadding.top != _p.top) || size.height < _size.height || size.width != _size.width) {
          size = _size;
          safePadding = _p;
          paddingRect = safePadding.copyWith(bottom: _p.bottom != 0.0 ? 10.0 : 0.0, left: 16.0, right: 16.0);

          return true;
        } else {
          return false;
        }
    }
    if (size != _size || safePadding != _p) {
      size = _size;
      safePadding = _p;

      paddingRect = EdgeInsets.only(
        left: safePadding.left + 16,
        top: safePadding.top,
        right: safePadding.right + 16,
        bottom: safePadding.bottom,
      );
      return true;
    } else {
      return false;
    }
  }

  /// 首次（重置）加载
  Future<void> _loadFirst() async {
    if (tData.cid == null || bookid == null) return;
    final _bookid = bookid!;
    final _key = tData.cid!;
    assert(Log.i('cid: $_key', stage: this, name: 'loadFirst'));
    _loadId(_key);

    await _futures.awaitId(_key);

    final _currentText = _getTextData(_key);
    if (_bookid == bookid && _currentText != null && _currentText.contentIsNotEmpty && _key == _currentText.cid) {
      tData = _currentText;

      if (config.value.axis == Axis.vertical) {
        final footv = '$currentPage/${tData.content.length}页';
        footer.value = footv;
        header.value = tData.cname!;
      }

      if (currentPage > tData.content.length) {
        currentPage = tData.content.length;
      }
    }

    unDelayedLoad();
  }

  int hasContent(int index) {
    var _r = 0;
    if (tData.contentIsNotEmpty) {
      final exPage = index - _innerIndex;

      final hasRight = currentPage + exPage < tData.content.length || _caches.containsKey(tData.nid);
      final hasLeft = currentPage + exPage > 1 || _caches.containsKey(tData.pid);

      if (hasRight) _r |= ContentBounds.addRight;
      if (hasLeft) _r |= ContentBounds.addLeft;
    } else {
      return ContentBounds.notLeftAndRight;
    }

    _delayedLoad();

    return _r;
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
          assert(Log.i('update', stage: this, name: 'getWidget'));
          assert(controller == null || controller!.page.round() == page);

          _innerIndex = page;
          currentPage = _currentPage;
          tData = text;
          dump();
          if (config.value.axis == Axis.vertical) {
            final footv = '$currentPage/${text.content.length}页';
            SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
              if (config.value.axis != Axis.vertical) return;
              footer.value = footv;
              header.value = text.cname!;
            });
          }
          return null;
        } else {
          child = text.content[_currentPage - 1];
          // ContentView(
          //   contentMetrics: text.content[_currentPage - 1],
          //   battery: FutureBuilder<int>(
          //     future: repository.getBatteryLevel(),
          //     builder: (context, snaps) {
          //       if (snaps.hasData) {
          //         return BatteryView(
          //           progress: (snaps.data! / 100).clamp(0.0, 1.0),
          //           color: config.value.fontColor!,
          //         );
          //       }
          //       return BatteryView(
          //         progress: (repository.level / 100).clamp(0.0, 1.0),
          //         color: config.value.fontColor!,
          //       );
          //     },
          //   ),
          // );
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

  TextStyle _getStyle(ContentViewConfig config) {
    return TextStyle(
      locale: const Locale('zh', 'CN'),
      fontSize: config.fontSize,
      color: config.fontColor!,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFamily: 'NotoSansSC', // SourceHanSansSC
      // fontFamilyFallback: ['RobotoMono', 'NotoSansSC'],
    );
  }

  static const pagefooterSize = 13.0;
  static const topPad = 8.0;
  static const contentPadding = 10.0;
  static const botPad = 8.0;
  static const otherHeight = contentPadding * 2 + topPad + botPad + pagefooterSize * 2;
  final _regexpEmpty = RegExp('( |\u3000)+');

  Future<bool> _getInnerCallbackLooper(
    ResultTimeCallback callback, {
    bool eventOnly = false,
    double frameThreshold = 1.5,
    String debugLabel = '',
  }) async {
    if (_cancel()) return false;
    return EventLooper.instance
        .scheduleEventTask(callback, eventOnly: eventOnly, frameThreshold: frameThreshold, debugLabel: debugLabel);
  }

  // ---------------------------------------
  Future? _getid;

  bool _ignoreTask(int contentid) {
    if ((contentid == tData.cid) && loading.value) {
      notifyState(loading: false);
    }

    final _thatData = _getTextData(contentid);
    if (_thatData != null && _thatData.contentIsNotEmpty) {
      if (_thatData.nid == -1 || _thatData.hasContent != 1) {
        return false;
      }
      return true;
    }

    if (_cancel() || !_inBookView) return true;

    if (_idSets.isEmpty) {
      _getCurrentIds();
    } else {
      _getid ??= Future<void>(_getCurrentIds).then((_) async {
        await Future<void>.delayed(const Duration(seconds: 3));
        _getid = null;
      });
    }
    return !_idSets.contains(contentid);
  }

  final _ids = <int?>[];

  List<int?> get _idSets {
    if (_ids.isEmpty) _getCurrentIds();
    return _ids;
  }

  // 根据当前章节更新存活章节
  List<int?> _getCurrentIds() {
    _ids.clear();
    _ids.add(tData.cid);

    final current = _getTextData(tData.cid);
    final nid = current?.nid;
    final pid = current?.pid;
    _ids..add(pid)..add(nid);

    final next = _getTextData(nid);
    final nnid = next?.nid;
    final thirty = _getTextData(nnid);
    _ids..add(nnid)..add(thirty?.nid);
    final pre = _getTextData(pid);
    _ids.add(pre?.pid);
    return _ids;
  }

  Future<List<ContentMetrics>> _asyncLayout(List<String> paragraphs, String cname, int contentid, int words) async {
    assert(Log.i('working   >>>'));
    var ignore = false;
    var whiteRows = 0;

    final pages = <List<TextPainter>>[];
    final textPages = <ContentMetrics>[];

    final fontSize = style.fontSize!;
    final ident = shortHash(pages);
    final config = this.config.value.copyWith();

    final _size = paddingRect.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = paddingRect.left + leftExtraPadding;

    // 文本占用高度
    final contentHeight = _size.height - otherHeight;

    // 配置行高
    final lineHeight = config.lineTweenHeight! * fontSize;

    final _allExtraHeight = contentHeight % lineHeight;

    // lineCounts
    final rows = contentHeight ~/ lineHeight;

    final hl = _allExtraHeight / rows;
    // 实际行高
    final lineHeightAndExtra = hl + lineHeight;

    // 大标题
    late final TextPainter _bigTitlePainter;
    // 小标题
    late final TextPainter smallTitlePainter;

    void _t01() {
      _bigTitlePainter = TextPainter(
          text: TextSpan(text: cname, style: style.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);
    }

    void _t02() {
      smallTitlePainter =
          TextPainter(text: TextSpan(text: cname, style: secstyle), textDirection: TextDirection.ltr, maxLines: 1)
            ..layout(maxWidth: width);
    }

    var incSize = 10;

    // 任务开始
    var _done = await _getInnerCallbackLooper((wait, _) async {
      var done = false;
      while (true) {
        for (var i = 1; i < 10; i++) {
          final s = (lineHeightAndExtra * i - 110);
          await wait();

          if (incSize > 10) {
            if (s >= 0 && s < incSize) {
              whiteRows = i;
              done = true;
              break;
            }
          } else if (s.abs() < incSize) {
            whiteRows = i;
            done = true;
            break;
          }
        }

        if (done) break;

        incSize += 10;
      }

      if (lineHeightAndExtra * whiteRows > 200) whiteRows--;

      final _half = fontSize / 2;

      await wait();

      ignore = _ignoreTask(contentid);

      if (ignore) return EventStatus.ignoreAndRemove;

      // ignore = _ignoreTask(contentid);

      // if (ignore) return EventStatus.ignoreAndRemove;
      _t01();
      await wait();
      _t02();
      await wait();

      Log.i('white. end');

      final lines = <TextPainter>[];

      final _t = TextPainter(textDirection: TextDirection.ltr);

      // 分行布局
      for (var i = 0; i < paragraphs.length; i++) {
        await wait();

        final pl = paragraphs[i];
        var start = 0;
        ignore = _ignoreTask(contentid);

        if (ignore) return EventStatus.ignoreAndRemove;

        while (start < pl.length) {
          var end = math.min(start + words, pl.length);

          if (end == pl.length && pl.substring(start, end).replaceAll(_regexpEmpty, '').isEmpty) break;
          await wait();

          // 确定每一行的字数
          while (true) {
            if (end >= pl.length) break;

            // ignore = _ignoreTask(contentid);

            // if (ignore) return EventStatus.ignoreAndRemove;

            await wait();

            end++;

            // final n = Stopwatch()..start();
            // final np = n.elapsedMicroseconds;
            _t
              ..text = TextSpan(text: pl.substring(start, end), style: style)
              ..layout(maxWidth: width);

            // Log.i('stop: use: ${(n.elapsedMicroseconds - np) / 1000}ms');

            await wait();

            if (_t.height > fontSize) {
              final endOffset = _t.getPositionForOffset(Offset(width, _half)).offset;
              end = start + endOffset;
              break;
            }
          }

          // ignore = _ignoreTask(contentid);

          // if (ignore) return EventStatus.ignoreAndRemove;

          await wait();

          final _text = TextPainter(
              text: TextSpan(text: pl.substring(start, end), style: style), textDirection: TextDirection.ltr)
            ..layout(maxWidth: width);

          start = end;
          lines.add(_text);
        }
      }

      await wait();
      var topExtraRows = (_bigTitlePainter.height / fontSize).floor();

      // 首页留白和标题
      final firstPages = math.max(0, rows - whiteRows - topExtraRows);
      pages.add(lines.sublist(0, math.min(firstPages, lines.length)));

      // 分页
      for (var i = firstPages; i < lines.length;) {
        pages.add(lines.sublist(i, (i + rows).clamp(i, lines.length)));
        i += rows;
      }

      var extraHeight = lineHeightAndExtra - fontSize;
      final isHorizontal = config.axis == Axis.horizontal;

      // 添加页面信息
      for (var r = 0; r < pages.length; r++) {
        await wait();

        final bottomRight = TextPainter(
            text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle), textDirection: TextDirection.ltr)
          ..layout(maxWidth: width);

        await wait();

        ignore = _ignoreTask(contentid);

        if (ignore) return EventStatus.ignoreAndRemove;
        await wait();

        final right = width - bottomRight.width - leftExtraPadding * 2;

        final met = ContentMetrics(
            painters: pages[r],
            extraHeightInLines: extraHeight,
            isHorizontal: isHorizontal,
            secstyle: secstyle,
            fontSize: fontSize,
            cPainter: smallTitlePainter,
            botRightPainter: bottomRight,
            cBigPainter: _bigTitlePainter,
            right: right,
            left: left,
            index: r,
            size: _size,
            windowTopPadding: safePadding.top,
            showrect: showrect,
            topExtraHeight: lineHeightAndExtra * (whiteRows + topExtraRows));

        textPages.add(met);
      }
    }, debugLabel: 'pages #<$ident>'.toString().padRight(16));

    if (!_done || ignore || _ignoreTask(contentid)) return const [];

    assert(Log.i('work done <<<'));
    return textPages;
  }

  /// 任务逻辑----------------
  void _loadTasks(int _bookid, int? contentid) {
    // 超过5个任务，由用户触发调用
    if (!_inBookView || _futures.length > 5) return;

    if (_bookid == bookid &&
        contentid != null &&
        contentid != -1 &&
        !_caches.containsKey(contentid) &&
        !_futures.isLoading(contentid)) {
      final _ntask = loadData(contentid, _bookid);

      _getCurrentIds();
      _futures.addTask(contentid, _ntask);
    }
  }

  void _loadId(int? id) => _loadTasks(bookid!, id);

  void unDelayedLoad() => _loadCallback();

  void _loadAuto() => _getCurrentIds().forEach(_loadId);

  void _loadCallback() {
    _loadResolve();
    _loadAuto();
  }

  // 处于最后一章节时，查看是否有更新
  Future<void> _loadResolve() async {
    if (tData.nid == -1 || tData.hasContent != 1) {
      if (tData.contentIsEmpty) return;

      void _getdata() {
        if (_caches.containsKey(tData.cid)) {
          if (tData.contentIsNotEmpty && (currentPage == tData.content.length || currentPage == 1)) {
            tData = _getTextData(tData.cid!)!;
            if (currentPage > tData.content.length) {
              currentPage = tData.content.length;
            }
            painter();
          }
        }
      }

      final cid = tData.cid!;
      final _data = _caches[cid];

      if (_data != null && _data.contentIsNotEmpty && tData.nid != -1 && tData.hasContent == 1) {
        // 已经重新加载到 caches 了
        _getdata();
        return;
      }

      if (_reloadIds.contains(cid)) return;

      assert(Log.i('nid = ${tData.nid}, hasContent: ${tData.hasContent}', stage: this, name: 'loadResolve'));

      _reloadIds.add(cid);
      Future.delayed(const Duration(seconds: 10), () => _reloadIds.remove(cid));
      await load(bookid!, cid, update: true);
      _getdata();
    }
  }

  // 立即
  Future<void> _resolveId() async {
    if (tData.contentIsEmpty) return;
    var _data = _getTextData(tData.cid);
    if (_data != null && (_data.hasContent != 1 || _data.nid == -1)) {
      await load(bookid!, tData.cid!, update: true);
      _data = _getTextData(tData.cid);
      if (_data != null && _data.contentIsNotEmpty) {
        tData = _data;
      }
      if (currentPage > tData.content.length) {
        currentPage = tData.content.length;
      }
    }
  }

  Future? _loadFuture;
  Future _delayedLoad() async {
    if (_inBookView)
      _loadFuture ??= Future.delayed(const Duration(seconds: 1), _loadCallback)..whenComplete(() => _loadFuture = null);
  }

  Future<void> updateCurrent() => _resolveId().then((_) => painter());

  Future<void> _willGoProOrNext({bool isPid = false}) async {
    if (_inPreOrNext || tData.contentIsEmpty) return;
    _inPreOrNext = true;

    stopAuto();
    notifyState(loading: true);

    var getid = -1;

    if (isPid) {
      getid = tData.pid!;
    } else {
      await _resolveId();
      getid = tData.nid!;
      if (getid == -1) {
        notifyState(loading: false, error: const NotifyMessage(true, msg: NotifyMessage.notNext));
      }
    }

    if (getid != -1) {
      final success = await _getContent(getid);
      if (!success) {
        notifyState(error: const NotifyMessage(true, msg: NotifyMessage.network));
      }
    }

    notifyState(loading: false);
    _inPreOrNext = false;
  }

  Future<bool> _getContent(int getid) async {
    var _data = _getTextData(getid);
    if (_data == null || _data.contentIsEmpty) {
      _loadAuto();
      _getCurrentIds();

      final _x = _futures.awaitId(getid);

      // 如果渲染管道在运行中，布局时间会大大加长
      if (_x != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        notifyState(loading: false);
        await _x;
      }

      _data = _getTextData(getid);
      if (_data == null || _data.contentIsEmpty) return false;
    }

    tData = _data;
    currentPage = 1;
    resetController();
    painter();
    return true;
  }

  ///-------------------------

  // 所有异步任务
  final _futures = <int, Future>{};

  // 缓存池
  final _caches = <int, TextData>{};

  // 记录重新下载的id，并延迟删除，避免频繁访问
  final _reloadIds = <int>{};

  int get tasksLength => _futures.length;
  Future get waitTasks => Future.wait(List.of(_futures.values));

  // 异步任务时防止用户滚动
  Completer<void>? _canLoad;
  bool _inBookView = false;
  bool _inPreOrNext = false;

  TextData _tData = TextData();

  TextData get tData => _tData;

  set tData(TextData data) {
    if (data == _tData) return;
    assert(data.contentIsNotEmpty, '不该为 空');
    updateCaches(data);
    _tData = data;
  }

  ///-------------------------

  // 加载状态
  // 是否直接忽略
  // 显示网络错误信息
  final _loading = ValueNotifier(false);
  final _ignore = ValueNotifier(true);
  final _error = ValueNotifier(const NotifyMessage(false));

  NopPageViewController? controller;
  ValueListenable<bool> get loading => _loading;
  ValueListenable<bool> get ignore => _ignore;
  ValueListenable<NotifyMessage> get error => _error;

  final header = ValueNotifier<String>('');
  final footer = ValueNotifier<String>('');

  int _innerIndex = 0;

  late TextStyle style;
  late TextStyle secstyle;
  final showCname = ValueNotifier(false);

  void painter() {
    notifyState(ignore: !_inBookView || tData.contentIsEmpty, loading: false);
    notifyListeners();
  }

  Future<void> reset({bool clearCache = false, int? cid}) async {
    adpotCache = false;

    if (clearCache) {
      if (_futures.isNotEmpty) {
        final tasks = Map.of(_futures);
        // 还有任务在
        await Future.wait(tasks.values);
      }
      _caches.clear();
    }
    adpotCache = true;
    _tData = TextData()..cid = cid ?? tData.cid;
  }

  void completerCanLoad() {
    if (_canLoad != null && !_canLoad!.isCompleted) {
      print('................c');
      _canLoad!.complete();
    }
  }

  void out() {
    _inBookView = false;
    adpotCache = false;
  }

  bool get inBook => _inBookView;
  void inbook() {
    adpotCache = true;
    _inBookView = true;
  }

  // _innerIndex == page == 0
  void resetController() {
    controller?.goIdle();
    controller?.setPixelsWithoutNtf(0.0);
    _innerIndex = 0;
  }

  Future<void> dump() async {
    if (bookid == null || tData.cid == null) return;
    final cid = tData.cid!;
    final _bookid = bookid!;
    final _currentPage = currentPage;
    return repository.bookEvent.updateMainInfo(_bookid, cid, _currentPage);
  }

  void notifyState({bool? loading, bool? ignore, NotifyMessage? error}) {
    if (loading != null) _loading.value = loading;
    if (ignore != null) _ignore.value = ignore;
    if (error != null) _error.value = error;
  }

  void statusColor() {
    uiStyle(dark: false);
  }

  /// 文本加载-----------------

  void addCache(TextData _cnpid) {
    assert(_cnpid.contentIsNotEmpty);
    _caches[_cnpid.cid!] = _cnpid;
  }

  TextData? _getTextData(int? key) => _caches[key];

  // 更新队列
  void updateCaches(TextData data) {
    _getCurrentIds();
    if (_caches.length > _idSets.length) {
      Timeline.timeSync('updateCaches', () {
        _caches.removeWhere((key, _) => !_idSets.contains(key));
      });
    }
  }

  Future<void> loadData(int _contentKey, int _bookid) async {
    if (_caches.containsKey(_contentKey)) return;
    await load(_bookid, _contentKey);
  }

  Future<void> load(int _bookid, int contentid, {bool update = false}) async {
    final words = (size.width - paddingRect.horizontal) ~/ config.value.fontSize!;
    final lines = await repository.bookEvent.load(_bookid, contentid, words, update: update);
    if (lines.contentIsNotEmpty) {
      final pages = await _asyncLayout(lines.pages, lines.cname!, contentid, words);

      if (pages.isEmpty) return;
      final _cnpid = TextData(
        content: pages,
        nid: lines.nid,
        pid: lines.pid,
        cid: lines.cid,
        hasContent: lines.hasContent,
        cname: lines.cname,
      );
      if (!_ignoreTask(contentid)) addCache(_cnpid);
    }
  }

  // 取消后续操作
  bool _cancel() => !adpotCache;

  bool adpotCache = true;

  ///-----------------
  Future<void> deleteCache(int bookId) async {
    return repository.bookEvent.deleteCache(bookId);
  }
}

class ContentMetrics {
  const ContentMetrics({
    required this.painters,
    required this.extraHeightInLines,
    required this.isHorizontal,
    required this.secstyle,
    required this.fontSize,
    required this.cPainter,
    required this.botRightPainter,
    required this.cBigPainter,
    required this.right,
    required this.left,
    required this.index,
    required this.size,
    required this.windowTopPadding,
    required this.showrect,
    required this.topExtraHeight,
  });
  final List<TextPainter> painters;
  final double extraHeightInLines;
  final TextStyle secstyle;
  final double fontSize;
  final bool isHorizontal;
  final TextPainter cPainter;
  final TextPainter botRightPainter;
  final TextPainter cBigPainter;
  final double right;
  final double left;
  final int index;
  final Size size;
  final double windowTopPadding;
  final bool showrect;
  final double topExtraHeight;
}

class ContentBounds {
  static int addLeft = 1;
  static const int addRight = 2;
  static const int notLeftAndRight = 3;
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
    this.patternList,
    this.portrait,
  });
  double? fontSize;
  double? lineTweenHeight;
  Color? bgcolor;
  String? fontFamily;
  Color? fontColor;
  Locale? locale;
  Axis? axis;
  Map? patternList;
  bool? portrait;
  ContentViewConfig copyWith({
    double? fontSize,
    double? lineTweenHeight,
    Color? bgcolor,
    int? fontFamily,
    Color? fontColor,
    Locale? locale,
    Axis? axis,
    Map? patternList,
    bool? portrait,
  }) {
    return ContentViewConfig(
        fontColor: fontColor ?? this.fontColor,
        fontFamily: fontFamily as String? ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        lineTweenHeight: lineTweenHeight ?? this.lineTweenHeight,
        bgcolor: bgcolor ?? this.bgcolor,
        locale: locale ?? this.locale,
        axis: axis ?? this.axis,
        patternList: patternList ?? this.patternList,
        portrait: portrait ?? this.portrait);
  }

  bool get isEmpty {
    return bgcolor == null || fontSize == null || fontColor == null || axis == null || lineTweenHeight == null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) &&
        other is ContentViewConfig &&
        fontColor == other.fontColor &&
        fontFamily == other.fontFamily &&
        fontSize == other.fontSize &&
        lineTweenHeight == other.lineTweenHeight &&
        bgcolor == other.bgcolor &&
        locale == other.locale &&
        axis == other.axis &&
        portrait == other.portrait &&
        patternList == other.patternList;
  }

  @override
  String toString() {
    return '$runtimeType: fontSize: $fontSize, bgcolor: $bgcolor, fontColor: $fontColor, lineTweenHeight: $lineTweenHeight,'
        ' fontFamily: $fontFamily,  local: $locale, axis: $axis';
  }
}

class NotifyMessage {
  const NotifyMessage(this.error, {this.msg = network});

  static const network = '网络错误';
  static const notNext = '已经是最后一章了';
  final bool error;
  final String msg;
}

// typedef FrameLooperCallback = bool Function();

// class FutureTasks<T> {
//   FutureTasks({FrameLooperCallback? onFrameLooper}) : _onFrameLooper = onFrameLooper;
//   final FrameLooperCallback? _onFrameLooper;

//   final _tasks = <Future<T> Function()>[];
//   int get length => _tasks.length;

//   Completer<void>? _completer;
//   int _threhsold = 4;

//   Future<void> awaitComplete({int threshold = 4}) async {
//     _threhsold = math.max(1, threshold);
//     while (_tasks.length >= _threhsold && (_onFrameLooper == null || !_onFrameLooper!())) {
//       _completer ??= Completer<void>();
//       await _completer!.future;
//     }
//   }

//   final _tasksFutures = <Future<T>>[];

//   Future<List<T>> get wait => Future.wait(_tasksFutures);

//   void completed() {
//     if (_tasks.length <= _threhsold + 1 && _completer != null && !_completer!.isCompleted) {
//       _completer!.complete();
//       _completer = null;
//     }
//   }

//   Future<void> addTask(Future<T> Function() func, {void Function()? callback}) async {
//     await awaitComplete(threshold: _threhsold);
//     if (_tasks.contains(func)) return;
//     final f = func();
//     _tasks.add(func);
//     _tasksFutures.add(f);
//     f.whenComplete(() {
//       _tasks.remove(func);
//       _tasksFutures.remove(f);
//       callback?.call();
//       completed();
//     });
//   }
// }

extension FutureTasksMap<T, E> on Map<T, Future<E>> {
  void addTask(T id, Future<E> f, {void Function()? callback, void Function(T)? solve}) {
    Log.i('addTask $id');
    if (containsKey(id)) return;
    this[id] = f;
    f.whenComplete(() {
      Log.i('task complete $id');
      remove(id);
      solve?.call(id);
      callback?.call();
    });
  }

  Future? awaitId(T? id) => this[id];

  bool isLoading(T? id) => containsKey(id);
}
