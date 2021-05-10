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
  PainterState({this.empty});
  final bool? empty;
  bool get isNull => empty == null;
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

class PainterBloc extends Bloc<PainterEvent, PainterState> {
  PainterBloc({required this.repository, required this.bookCacheBloc}) : super(PainterState(empty: true));

  final Repository repository;
  // final BookIndexBloc bookIndexBloc;
  final BookCacheBloc bookCacheBloc;

  int? bookid;

  int currentPage = 1;

  ContentViewConfig config = ContentViewConfig();

  @override
  Stream<PainterState> mapEventToState(PainterEvent event) async* {
    if (event is PainterMetricsChangeEvent) {
      await metricsChange();
    } else if (event is PainterShowShadowEvent) {
      await showdow();
    } else if (event is _InnerEvent) {
      if (_inBookView) {
        yield PainterState(empty: tData.isNotEmpty);
      }

    } else if (event is PainterLoadEvent) {
      // 空白内容，加载状态
      notifyState(loading: true, ignore: true);
      await loadFirst();
      await Future.delayed(Duration(milliseconds: 300));
      painter();
    }
  }

  Future<void> metricsChange() async {
    // 实时
    final changed = await modifiedSize();
    if (changed) {
      if (_inBookView && tData.cid != null && bookid != null) {
        adpotCache = false;
        notifyState(ignore: true);
        // completercanCompute();
        await reset(clearCache: true);
        adpotCache = true;
        // resetController();
        await loadFirst();
        // 所有变量都变了，[controller.pixels] [_innerIndex] [currentPage] 可能不同步
        // [currentPage] 被重新约束了
        if (_inBookView) {
          painter();
        }
      }
    }
  }

  Future goNext() => willGoProOrNext(isPid: false);
  Future goPre() => willGoProOrNext(isPid: true);

  bool showrect = false;
  Future<void> showdow() async {
    showrect = !showrect;

    adpotCache = false;

    await reset(clearCache: true);
    adpotCache = true;

    await loadFirst();

    painter();

    adpotCache = true;
  }

  Future<void> setPrefs(ContentViewConfig _config) async {
    var flush = false;
    final _fontSize = _config.fontSize!;
    final _height = _config.lineBwHeight!;
    final _bgcolor = _config.bgcolor!;
    final _fontColor = _config.fontColor!;
    final _fontFamily = _config.fontFamily!;
    final _axis = _config.axis!;
    final _p = _config.patternList!;
    final _portrait = _config.portrait!;
    if (_fontSize != config.fontSize ||
        _fontFamily != config.fontFamily ||
        _fontColor != config.fontColor ||
        _height != config.lineBwHeight ||
        _axis != config.axis) {
      flush = true;
    }
    final resetTozero = _axis != config.axis;
    // 横屏切换由 sizeChange 处理
    if (_portrait != config.portrait) await orientation(_portrait);
    await getPrefs((box) async {
      await box.put('bgcolor', _bgcolor);
      await box.put('fontColor', _fontColor);
      await box.put('axis', _axis);
      await box.put('patternList', _p);
      await box.put('portrait', _portrait);
      if (_fontSize > 0) await box.put('fontSize', _fontSize);
      if (_height >= 1.0) await box.put('lineBwHeight', _height);
      if (_fontFamily.isNotEmpty) await box.put('fontFamily', _fontFamily);
    });

    if (flush) {
      adpotCache = false;

      // await inCompute(() async {
      await reset(clearCache: true);
      if (resetTozero) resetController();
      adpotCache = true;
      await loadFirst();
      // });
    }

    painter();
  }

  Future<void> getPrefs([Future<void> Function(Box)? callback]) async {
    final box = await Hive.openBox('settings');
    if (callback != null) {
      await callback(box);
    }
    var _bgcolor = box.get('bgcolor', defaultValue: Color(0xffe3d1a8));
    var _fontColor = box.get('fontColor', defaultValue: Color(0xff4e4e4e));
    var axis = box.get('axis', defaultValue: Axis.horizontal);
    final _fontSize = box.get('fontSize', defaultValue: 18.0);
    final _height = box.get('lineBwHeight', defaultValue: 1.6);
    final _fontFamily = box.get('fontFamily', defaultValue: '');
    final _p = box.get('patternList', defaultValue: <String, String>{});
    final _portrait = box.get('portrait', defaultValue: true);
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
    config.fontSize = _fontSize;
    config.lineBwHeight = _height;
    config.bgcolor = _bgcolor;
    config.fontFamily = _fontFamily;
    config.fontColor = _fontColor;
    config.patternList = _p;
    config.axis = axis;
    config.portrait = _portrait;

    style = getStyle(config);
    secstyle = getStyle(config.copyWith(fontSize: pageNumSize));
  }

  Future? _nf;
  Future? get enter => _nf;

  Future<void> newBookOrCid(int newBookid, int cid, int page, {bool inBook = false}) async {
    await _nf;
    _nf ??= _newBookOrCid(newBookid, cid, page, inBook: inBook)..whenComplete(() => _nf = null);
  }

  Future<void> _newBookOrCid(int newBookid, int cid, int page, {bool inBook = false}) async {
    if (cid == -1) return;

    assert(canLoad == null || canLoad!.isCompleted);
    if (!inBook) canLoad = Completer<void>();
    controller?.goBallisticResolveWithLastActivity();

    orientation(config.portrait!);
    final _lastInBookView = _inBookView;

    adpotCache = false;
    if (tData.cid == null || tData.cid != cid || tData.contentIsEmpty) {
      assert(Log.i('page: $page', stage: this, name: 'newBook'));
      final diffBook = bookid != newBookid;
      notifyState(ignore: diffBook || tData.contentIsEmpty, loading: false);

      await canLoad?.future;
      out();

      if (!_lastInBookView) uiOverlay().whenComplete(modifiedSize);

      currentPage = page;

      await reset(clearCache: diffBook, cid: cid);
      bookid = newBookid;

      // 重置状态
      // completercanCompute();

      inbook();
      final dump = undelayedDump();
      final timer = Timer(const Duration(milliseconds: 300), () {
        notifyState(loading: true);
      });

      adpotCache = true;
      getCurrentIds();

      await loadFirst();

      await dump;
      timer.cancel();
      painter();
      resetController();
    } else {
      inbook();
      if (!_lastInBookView || !config.portrait!) {
        // await canLoad?.future;
        uiOverlay();
      }
    }
    adpotCache = true;
    notifyState(ignore: false, loading: false);
    statusColor();
  }

  Size size = Size.zero;

  // 开启帧回调

  var safePadding = EdgeInsets.zero;
  var paddingRect = EdgeInsets.zero;
  var safeBottom = 6.0;

  /// 返回值是实时的
  ///
  /// 如果两次调用之间设置不变， 则返回值为 `false`
  /// 即使 [_fast] 为 `true`
  Future<bool> modifiedSize() async {
    final w = ui.window;
    var _size = w.physicalSize / w.devicePixelRatio;
    var _p = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await repository.getViewInsets();
        var _sizeOut = Size.zero;
        _sizeOut = repository.viewInsets.size;
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
          paddingRect = _p.copyWith(bottom: _p.bottom != 0.0 ? 10.0 : 0.0, left: 16.0, right: 16.0);

          return true;
        } else {
          return false;
        }
    }
    if (size != _size || safePadding != _p) {
      size = _size;
      safePadding = _p;

      // 从安全边界获取
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
  Future<void> loadFirst() async {
    final _bookid = bookid!;
    final _key = tData.cid!;
    assert(Log.i('cid: $_key', stage: this, name: 'loadFirst'));
    loadId(_key);

    await EventLooper.instance.onListen(() async => _futures.awaitId(_key));

    final _currentText = _getTextData(_key);
    if (_bookid == bookid && _currentText != null && _currentText.contentIsNotEmpty && _key == _currentText.cid) {
      tData = _currentText;

      if (config.axis == Axis.vertical) {
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

  bool _delayedDone = true;
  bool hasContent(ContentBounds key, int index) {
    var result = true;
    if (tData.contentIsNotEmpty) {
      final exPage = index - _innerIndex;
      if (key == ContentBounds.getRight) {
        result = currentPage + exPage < tData.content.length || caches.containsKey(tData.nid);
      } else {
        result = currentPage + exPage > 1 || caches.containsKey(tData.pid);
      }
    } else {
      result = false;
    }
    if (_delayedDone) {
      _delayedDone = false;
      _delayedLoad().then((_) {
        Future.delayed(const Duration(seconds: 3), () => _delayedDone = true);
      });
    }
    return result;
  }

  Widget? getWidget(int page, {bool changeState = false}) {
    if (changeState && page == _innerIndex) return null;
    var currentContentFirstIndex = _innerIndex - currentPage + 1;
    var text = tData;
    Widget? child;
    while (text.contentIsNotEmpty) {
      // 当前章节页
      final contentIndex = page - currentContentFirstIndex;
      final length = text.content.length;

      if (contentIndex >= 0 && contentIndex <= length - 1) {
        final _currentPage = contentIndex + 1;

        // 只有滑动结束或过半才会进行判定 [currentPage]
        if (changeState) {
          assert(Log.i('update', stage: this, name: 'getWidget'));
          assert(controller == null || controller!.page.round() == page);

          _innerIndex = page;
          currentPage = _currentPage;
          tData = text;
          undelayedDump();
          if (config.axis == Axis.vertical) {
            final footv = '$currentPage/${text.content.length}页';
            SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
              if (config.axis != Axis.vertical) return;
              footer.value = footv;
              header.value = text.cname!;
            });
          }
          return null;
        } else {
          child = ContentView(
            contentMetrics: text.content[_currentPage - 1],
            battery: FutureBuilder<int>(
              future: repository.getBatteryLevel(),
              builder: (context, snaps) {
                if (snaps.hasData) {
                  return BatteryView(
                    progress: (snaps.data! / 100).clamp(0.0, 1.0),
                    color: config.fontColor!,
                  );
                }
                return BatteryView(
                  progress: (repository.level / 100).clamp(0.0, 1.0),
                  color: config.fontColor!,
                );
              },
            ),
          );
        }
        break;
      } else if (contentIndex < 0) {
        if (caches.containsKey(text.pid)) {
          text = _getTextData(text.pid!)!;
          currentContentFirstIndex -= text.content.length;
        } else {
          break;
        }
      } else if (contentIndex >= length) {
        if (caches.containsKey(text.nid)) {
          currentContentFirstIndex += length;
          text = _getTextData(text.nid!)!;
        } else {
          break;
        }
      }
    }

    // 如果发生意外，重新加载
    // if (child == null) {
    //   if (!shouldUpdate) {
    //     shouldUpdate = true;
    //     Future.delayed(Duration(milliseconds: 400), () async {
    //       // 重置状态
    //       resetController();
    //       await loadFirst();
    //       painter();
    //       shouldUpdate = false;
    //     });
    //   }
    // }

    return child;
  }

  TextStyle getStyle(ContentViewConfig config) {
    return TextStyle(
      locale: const Locale('cn', 'ZH'),
      fontSize: config.fontSize,
      color: config.fontColor!,
      height: 1.0,
      fontFamily: 'NotoSansSC', // SourceHanSansSC
      // fontFamilyFallback: ['RobotoMono', 'NotoSansSC'],
    );
  }

  static const pageNumSize = 13.0;
  static const topPad = 8.0;
  static const ePadding = 10.0;
  static const botPad = 8.0;
  static const otherHeight = ePadding * 2 + topPad + botPad + pageNumSize * 2;
  final regexpEmpty = RegExp('( |\u3000)+');

  // 取消后续操作
  bool _cancel() => !adpotCache;

  // // 耗时函数回调
  // Future<bool> _innerCallback(VoidCallback callback, {String debugLabel = ''}) async {
  //   if (!_fast) {
  //     return EventLooper.instance
  //         .frameCallbackLooper(callback, frameThreshold: 2, cancel: _cancel, debugLabel: debugLabel);
  //   } else {
  //     callback();
  //   }
  //   return true;
  // }

  Future<bool> _getInnerCallbackLooper(
    int contentid,
    ResultTimeCallback callback, {
    double frameThreshold = 2,
    String debugLabel = '',
  }) async {
    if (_cancel()) return false;
    // if (contentid == tData.cid) {
    //   callback(() => false);
    //   return true;
    // }
    return EventLooper.instance.scheduleEventTask(callback, frameThreshold: frameThreshold, debugLabel: debugLabel);
  }

  // ---------------------------------------
  Future? _getid;

  bool ignoreTask(int contentid) {
    final _thatData = _getTextData(contentid);
    if (_thatData != null && _thatData.contentIsNotEmpty) {
      if (_thatData.nid == -1 || _thatData.hasContent != 1) {
        return false;
      }
      return true;
    }
    if (_cancel() || !_inBookView) return true;
    if (_idSets.isEmpty) {
      getCurrentIds();
    } else {
      _getid ??= Future<void>.delayed(Duration(seconds: 3), getCurrentIds)..then((_) => _getid = null);
    }
    return !_idSets.contains(contentid);
  }

  final _ids = <int?>[];

  List<int?> get _idSets {
    if (_ids.isEmpty) getCurrentIds();
    return _ids;
  }

  List<int?> getCurrentIds() {
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

  Future<List<ContentMetrics>> divText(List<String> paragraphs, String cname, int contentid, int words) async {
    assert(Log.i('working   >>>'));
    var ignore = false;
    final pages = <List<TextPainter>>[];
    final textPages = <ContentMetrics>[];
    final fontSize = style.fontSize!;
    final ident = shortHash(pages);
    final config = this.config.copyWith();

    final _size = paddingRect.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = paddingRect.left + leftExtraPadding;

    // 文本占用高度
    final contentHeight = _size.height - otherHeight;

    // 配置行高
    final lineHeight = config.lineBwHeight! * fontSize;

    // 实际行高
    final lineHeightAndExtra = (contentHeight % lineHeight) / (contentHeight ~/ lineHeight) + lineHeight;

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

    var whiteCounts = 0;

    void _f01() {
      var leaf = 10;
      var done = false;
      while (true) {
        for (var i = 1; i < 10; i++) {
          final s = (lineHeightAndExtra * i - 110);

          if (leaf > 10) {
            if (s >= 0 && s < leaf) {
              whiteCounts = i;
              done = true;
              break;
            }
          } else if (s.abs() < leaf) {
            whiteCounts = i;
            done = true;
            break;
          }
        }

        if (done) break;

        leaf += 10;
      }
      if (lineHeightAndExtra * whiteCounts > 200) {
        whiteCounts--;
      }
    }

    final _listf = [_t01, _t02, _f01];

    var index = 0;

    var _done = await _getInnerCallbackLooper(contentid, (timeOut) {
      for (var _i = index; _i < _listf.length; _i++) {
        if (timeOut()) {
          index = _i;
          Log.w('timeOut.... | title $contentid');

          return EventStatus.timeout;
        }

        ignore = ignoreTask(contentid);
        if (ignore) {
          Log.w('ignore.... | title $contentid');
          return EventStatus.ignore;
        }

        _listf[_i]();
      }
    }, debugLabel: 'title #<$ident>'.toString().padRight(16));

    bool innerCancel() => !_done || ignore || ignoreTask(contentid);

    if (innerCancel()) return const [];

    final lines = <TextPainter>[];

    index = 0;
    var _start = 0;
    int? _end;
    final _t = TextPainter(textDirection: TextDirection.ltr);

    _done = await _getInnerCallbackLooper(contentid, (timeOut) {
      for (var i = index; i < paragraphs.length; i++) {
        index = i;

        final p = paragraphs[i];
        final pc = p.characters;
        var start = _start;
        while (start < pc.length) {
          var end = _end ?? math.min(start + words, pc.length);

          if (pc.getRange(start, end).toString().replaceAll(regexpEmpty, '').isEmpty) break;
          if (_end == null) {
            while (true) {
              if (end >= pc.length) break;

              if (timeOut()) return EventStatus.timeout;

              ignore = ignoreTask(contentid);

              if (ignore) return EventStatus.ignore;

              end++;
              _t
                ..text = TextSpan(text: pc.getRange(start, end).toString(), style: style)
                ..layout(maxWidth: width);

              if (_t.height > fontSize) {
                final endOffset = _t.getPositionForOffset(Offset(width, fontSize / 2)).offset;
                _end = end = start + endOffset;
                break;
              }
            }
          }
          if (timeOut()) return EventStatus.timeout;

          ignore = ignoreTask(contentid);

          if (ignore) return EventStatus.ignore;

          final _text = TextPainter(
              text: TextSpan(text: pc.getRange(start, end).toString(), style: style), textDirection: TextDirection.ltr)
            ..layout(maxWidth: width);

          lines.add(_text);
          _start = start = end;
          _end = null;
        }

        _start = 0;
      }
    }, frameThreshold: 0.825, debugLabel: 'para #<$ident>'.toString().padRight(16));

    if (innerCancel()) return const [];

    var topHeight = (_bigTitlePainter.height / fontSize).floor();
    var whiteHeight = whiteCounts * lineHeightAndExtra;

    void _f02() {
      // 每个页面能达到的最大行数
      final spl = (contentHeight / lineHeightAndExtra).floor();
      // 首页留白和标题
      final firstPages = math.max(0, spl - whiteCounts - topHeight);
      pages.add(lines.sublist(0, math.min(firstPages, lines.length)));

      for (var i = firstPages; i < lines.length;) {
        pages.add(lines.sublist(i, (i + spl).clamp(i, lines.length)));
        i += spl;
      }
    }

    _done = await _getInnerCallbackLooper(contentid, (timeOut) {
      if (timeOut()) return EventStatus.timeout;

      _f02();
    }, debugLabel: '_f02 #<$ident>'.toString().padRight(16));

    if (innerCancel()) return const [];

    var exh = lineHeightAndExtra - config.fontSize!;
    final isHorizontal = config.axis == Axis.horizontal;

    var _r = 0;
    TextPainter? bottomRight;
    List<TextPainter>? _teps;

    _done = await _getInnerCallbackLooper(contentid, (timeOut) {
      for (var r = _r; r < pages.length; r++) {
        bottomRight ??= TextPainter(
            text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle), textDirection: TextDirection.ltr)
          ..layout(maxWidth: width);

        Log.w('timeOut.... | pages $contentid');
        if (timeOut()) {
          _r = r;
          return EventStatus.timeout;
        }
        ignore = ignoreTask(contentid);
        if (ignore) {
          Log.w('ignore.... | pages $contentid');
          return EventStatus.ignore;
        }

        final right = width - bottomRight!.width - leftExtraPadding * 2;
        _teps ??= <TextPainter>[];
        final p = pages[r];

        for (var i = 0; i < p.length; i++) {
          _teps!.add(p[i]);
        }

        final met = ContentMetrics(
            painters: _teps!,
            extraHeightInLines: exh,
            isHorizontal: isHorizontal,
            secstyle: secstyle,
            fontSize: fontSize,
            cPainter: smallTitlePainter,
            botRightPainter: bottomRight!,
            cBigPainter: _bigTitlePainter,
            right: right,
            left: left,
            index: r,
            topHeight: topHeight,
            size: _size,
            windowTopPadding: paddingRect.top,
            showrect: showrect,
            whiteHeight: whiteHeight);
        textPages.add(met);

        _teps = null;
        bottomRight = null;
      }
    }, debugLabel: 'pages #<$ident>'.toString().padRight(16));

    if (innerCancel()) return const [];

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
        !caches.containsKey(contentid) &&
        !_futures.isLoading(contentid)) {
      final _ntask = loadData(contentid, _bookid);
      // 任务添加的开始
      // 更新要保留的 contentid
      getCurrentIds();
      _futures.addTask(contentid, _ntask);
    }
  }

  void loadId(int? id) => _loadTasks(bookid!, id);

  void unDelayedLoad() => _loadCallback();

  void loadAuto() {
    loadId(tData.cid);

    final next = _getTextData(tData.nid);
    if (next != null) {
      final thirty = _getTextData(next.nid);
      if (thirty != null) {
        loadId(thirty.nid);
      } else {
        loadId(next.nid);
      }
    } else {
      loadId(tData.nid);
    }

    loadPre();
  }

  void loadPre() {
    final pre = _getTextData(tData.pid);
    if (pre != null) {
      loadId(pre.pid);
    } else {
      loadId(tData.pid);
    }
  }

  void _loadCallback() {
    loadResolve();
    loadAuto();
  }

  // 处于最后一章节时，查看是否有更新
  Future<void> loadResolve() async {
    if (tData.nid == -1 || tData.hasContent != 1) {
      if (tData.contentIsEmpty) return;

      void _getdata() {
        if (caches.containsKey(tData.cid)) {
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
      final _data = caches[cid];

      if (_data != null && _data.contentIsNotEmpty && tData.nid != -1 && tData.hasContent == 1) {
        // 已经重新加载到 caches 了
        _getdata();
        return;
      }

      if (reloadIds.contains(cid)) return;

      assert(Log.i('nid = ${tData.nid}, hasContent: ${tData.hasContent}', stage: this, name: 'loadResolve'));

      reloadIds.add(cid);
      Future.delayed(const Duration(seconds: 10), () => reloadIds.remove(cid));
      await load(bookid!, cid, update: true);
      _getdata();
    }
  }

  // 立即
  Future<void> resolveId() async {
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

  Future<bool>? _loadFuture;
  Future _delayedLoad() async {
    if (_inBookView)
      _loadFuture ??= _getInnerCallbackLooper(-1, (_) {
        _loadCallback();
      }, debugLabel: '_delayedLoad'.padRight(16))
        ..whenComplete(() => _loadFuture = null);
  }

  // Future inCompute(FutureCallback callback) async {
  //   // if (canCompute != null && !canCompute!.isCompleted) {
  //   //   Log.i('awaiting >> ', stage: this, name: 'awaitCompute');
  //   //   await canCompute!.future;
  //   // }
  //   // computeCount++;
  //   await callback();
  //   // computeCount--;
  // }

  Future<void> updateCurrent() => resolveId().then((value) => painter());

  Future<void> willGoProOrNext({bool isPid = false}) async {
    if (_inPreOrNext || tData.contentIsEmpty) return;
    notifyState(loading: true);
    _inPreOrNext = true;
    var getid = -1;

    if (isPid) {
      getid = tData.pid!;
    } else {
      await resolveId();
      getid = tData.nid!;
      if (getid == -1) {
        notifyState(loading: false, error: const NotifyMessage(true, msg: NotifyMessage.notNext));
      }
    }

    if (getid != -1) {
      final success = await getContent(getid);
      if (!success && !isPid) {
        notifyState(error: const NotifyMessage(true, msg: NotifyMessage.notNext));
      }
    }

    notifyState(loading: false);
    _inPreOrNext = false;
  }

  Future<bool> getContent(int getid) async {
    var _data = _getTextData(getid);
    if (_data == null || _data.contentIsEmpty) {
      loadAuto();

      await EventLooper.instance.onListen(() async => _futures.awaitId(getid));
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
  final caches = <int, TextData>{};
  // 记录重新下载的id，并延迟删除，避免频繁访问
  final reloadIds = <int>{};

  int get tasksLength => _futures.length;
  // 正在进入章节阅读页面，[true] 阻止页面退出
  // var _locked = false;
  // bool get locked => _locked;

  // 异步任务时防止用户滚动
  // int computeCount = 0;
  Completer<void>? canCompute;
  Completer<void>? canLoad;
  bool _inBookView = false;
  bool _inPreOrNext = false;
  bool shouldUpdate = false;

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
  final _error = ValueNotifier(NotifyMessage(false));

  NopPageViewController? controller;
  ValueListenable<bool> get loading => _loading;
  ValueListenable<bool> get ignore => _ignore;
  ValueListenable<NotifyMessage> get error => _error;

  final header = ValueNotifier<String>('');
  final footer = ValueNotifier<String>('');

  int _innerIndex = 0;

  late TextStyle style;
  late TextStyle secstyle;

  // 只能做为结果返回，并且处理状态
  // 一旦有了新状态，就要显示信息
  void painter() {
    // computeCount++;
    notifyState(ignore: false, loading: false);
    add(_InnerEvent());
  }

  Future<void> reset({bool clearCache = false, int? cid}) async {
    if (clearCache) {
      caches.clear();
      if (_futures.isNotEmpty) {
        final tasks = Map.of(_futures);
        // 还有任务在
        tasks.forEach((key, _future) {
          _future.whenComplete(() {
            caches.remove(key);
          });
        });
      }
    }

    _tData = TextData()..cid = cid ?? tData.cid;
  }

  void completerCanLoad() {
    if (canLoad != null && !canLoad!.isCompleted) {
      canLoad!.complete();
    }
  }

  // void completercanCompute() {
  //   if (canCompute != null && !canCompute!.isCompleted) {
  //     canCompute!.complete();
  //   }
  // }

  // void setcanCompute() {
  //   if (canCompute == null || canCompute!.isCompleted) {
  //     canCompute = Completer<void>();
  //   }
  // }

  void out() {
    _inBookView = false;
    adpotCache = false;
    resetController();
  }

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

  Future<void> undelayedDump() async {
    if (bookid == null || tData.contentIsEmpty) return;
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
    caches[_cnpid.cid!] = _cnpid;
  }

  TextData? _getTextData(int? key) => caches[key];

  // 更新队列
  void updateCaches(TextData data) {
    getCurrentIds();
    if (caches.length > 8) {
      Timeline.timeSync('updateCaches', () {
        caches.removeWhere((key, _) => !_idSets.contains(key));
      });
    }
  }

  Future<void> loadData(int _contentKey, int _bookid) async {
    if (caches.containsKey(_contentKey)) return;
    await load(_bookid, _contentKey);
  }

  Future<void> load(int _bookid, int contentid, {bool update = false}) async {
    final words = (size.width - paddingRect.horizontal) ~/ config.fontSize!;
    final lines = await repository.bookEvent.load(_bookid, contentid, words, update: update);
    if (lines.contentIsNotEmpty) {
      final pages = await divText(lines.pages, lines.cname!, contentid, words);

      if (pages.isEmpty) return;
      final _cnpid = TextData(
        content: pages,
        nid: lines.nid,
        pid: lines.pid,
        cid: lines.cid,
        hasContent: lines.hasContent,
        cname: lines.cname,
      );
      if (!ignoreTask(contentid)) addCache(_cnpid);
    }
  }
  // Future<void> loadFromDb(int contentid, int _bookid) async {
  //   var queryList = await repository.innerdb.loadFromDb(contentid, _bookid);
  //   if (queryList.isNotEmpty) {
  //     final map = queryList.first;
  //     late BookContent bookContent;
  //     await frameCallbackLooper(() {
  //       bookContent = BookContent.fromJson(map);
  //     });
  //     if (map.contentIsNotEmpty) {
  //       return adoptText(bookContent, contentid, _bookid);
  //     }
  //   }
  // }

  /// 下载
  // Future<void> download(int contentid, int _bookid, {bool adopt = true}) async {
  //   assert(Log.i('loading Id: $contentid', stage: this, name: 'download'));
  //   final bookContent = await repository.getContentFromNet(_bookid, contentid);

  //   if (bookContent.content != null) {
  //     // 首先保存到数据库中
  //     // repository.innerdb.saveToDatabase(bookContent);

  //     if (_bookid != bookid || !adopt) return;
  //     return adoptText(bookContent, contentid, _bookid);
  //   }
  // }

  bool adpotCache = true;
  // Future<void> adoptText(BookContent bookContent, int contentid, int _bookid) async {
  //   if (_bookid != bookid) return;
  //   final list = await divText(bookContent.content!, bookContent.cname!);
  //   if (list.isEmpty) return;
  //   final _cnpid = TextData(
  //     content: list,
  //     nid: bookContent.nid,
  //     pid: bookContent.pid,
  //     cid: bookContent.cid,
  //     hasContent: bookContent.hasContent,
  //     cname: bookContent.cname,
  //   );
  //   if (adpotCache) addCache(_cnpid);
  // }

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
    required this.topHeight,
    required this.size,
    required this.windowTopPadding,
    required this.showrect,
    required this.whiteHeight,
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
  final int topHeight;
  final Size size;
  final double windowTopPadding;
  final bool showrect;
  final double whiteHeight;
}

enum ContentBounds {
  getLeft,
  getRight,
}

class ContentViewConfig {
  ContentViewConfig({
    this.fontSize,
    this.lineBwHeight,
    this.bgcolor,
    this.fontFamily,
    this.fontColor,
    this.locale,
    this.axis,
    this.patternList,
    this.portrait,
  });
  double? fontSize;
  double? lineBwHeight;
  Color? bgcolor;
  String? fontFamily;
  Color? fontColor;
  Locale? locale;
  Axis? axis;
  Map? patternList;
  bool? portrait;
  ContentViewConfig copyWith({
    double? fontSize,
    double? lineBwHeight,
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
        lineBwHeight: lineBwHeight ?? this.lineBwHeight,
        bgcolor: bgcolor ?? this.bgcolor,
        locale: locale ?? this.locale,
        axis: axis ?? this.axis,
        patternList: patternList ?? this.patternList,
        portrait: portrait ?? this.portrait);
  }

  bool get isEmpty {
    return bgcolor == null || fontSize == null || fontColor == null || axis == null || lineBwHeight == null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ContentViewConfig &&
            fontColor == other.fontColor &&
            fontFamily == other.fontFamily &&
            fontSize == other.fontSize &&
            lineBwHeight == other.lineBwHeight &&
            bgcolor == other.bgcolor &&
            locale == other.locale &&
            axis == other.axis &&
            patternList == other.patternList;
  }

  @override
  String toString() {
    return '$runtimeType: fontSize: $fontSize, bgcolor: $bgcolor, fontColor: $fontColor, lineBwHeight: $lineBwHeight,'
        ' fontFamily: $fontFamily,  local: $locale, axis: $axis';
  }
}

abstract class PainterEvent {
  const PainterEvent();
}

class PainterShowShadowEvent extends PainterEvent {
  const PainterShowShadowEvent();
}

class _InnerEvent extends PainterEvent {}

class PainterLoadEvent extends PainterEvent {}

class PainterMetricsChangeEvent extends PainterEvent {}

class NotifyMessage {
  const NotifyMessage(this.error, {this.msg = network});

  static const network = '网络错误';
  static const notNext = '没有下一章了';
  final bool error;
  final String msg;
}

typedef FrameLooperCallback = bool Function();

class FutureTasks<T> {
  FutureTasks({FrameLooperCallback? onFrameLooper}) : _onFrameLooper = onFrameLooper;
  final FrameLooperCallback? _onFrameLooper;

  final _tasks = <Future<T> Function()>[];
  int get length => _tasks.length;

  Completer<void>? _completer;
  int _threhsold = 4;

  Future<void> awaitComplete({int threshold = 4}) async {
    _threhsold = math.max(1, threshold);
    while (_tasks.length >= _threhsold && (_onFrameLooper == null || !_onFrameLooper!())) {
      _completer ??= Completer<void>();
      await _completer!.future;
    }
  }

  final _tasksFutures = <Future<T>>[];

  Future<List<T>> get wait => Future.wait(_tasksFutures);

  void completed() {
    if (_tasks.length <= _threhsold + 1 && _completer != null && !_completer!.isCompleted) {
      _completer!.complete();
      _completer = null;
    }
  }

  Future<void> addTask(Future<T> Function() func, {void Function()? callback}) async {
    await awaitComplete(threshold: _threhsold);
    if (_tasks.contains(func)) return;
    final f = func();
    _tasks.add(func);
    _tasksFutures.add(f);
    f.whenComplete(() {
      _tasks.remove(func);
      _tasksFutures.remove(f);
      callback?.call();
      completed();
    });
  }
}

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
