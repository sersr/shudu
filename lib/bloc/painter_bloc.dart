import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../data/book_content.dart';

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
  String toString() {
    return 'cid: $cid, pid: $pid, nid: $nid, cname: $cname';
  }
}

class PainterBloc extends Bloc<PainterEvent, PainterState> {
  PainterBloc({required this.repository, required this.bookIndexBloc, required this.bookCacheBloc})
      : super(PainterState(empty: true));

  final Repository repository;
  final BookIndexBloc bookIndexBloc;
  final BookCacheBloc bookCacheBloc;

  int? bookid;

  int currentPage = 1;

  TextData tData = TextData();
  ContentViewConfig config = ContentViewConfig();

  @override
  Stream<PainterState> mapEventToState(PainterEvent event) async* {
    if (event is PainterMetricsChangeEvent) {
      await metricsChange();
    } else if (event is PainterSetPreferencesEvent) {
      await setPrefs(event);
    } else if (event is PainterShowShadowEvent) {
      await showdow();
    } else if (event is _InnerEvent) {
      if (_inBookView) {
        yield PainterState(empty: tData.isNotEmpty);
      }
      computeCount--;
    } else if (event is PainterLoadEvent) {
      await inCompute(() async {
        // 空白内容，加载状态
        notifyState(loading: true, ignore: true);
        await loadFirst();
        await Future.delayed(Duration(milliseconds: 300));
        painter();
      });
    }
  }

  Future<void> metricsChange() async {
    await sizeChange();
    if (sizeChanged) {
      sizeChanged = false;
      if (_inBookView) {
        notifyState(ignore: true);
        reset(clearCache: true);
        _locked = true;
        await loadFirst();
        // 所有变量都变了，[controller.pixels] [_innerIndex] [currentPage] 可能不同步
        // [currentPage] 被重新约束了
        if (_inBookView) {
          resetController();
          painter();
        }
        _locked = false;
      }
    }
  }

  Future goNext() => willGoProOrNext(isPid: false);
  Future goPre() => willGoProOrNext(isPid: true);

  bool showrect = false;
  Future<void> showdow() async {
    showrect = !showrect;
    exitBlockingAndInCompute(() async {
      reset(clearCache: true);
      await loadFirst();
      painter();
    });
  }

  Future<void> setPrefs(PainterSetPreferencesEvent event) async {
    var flush = false;
    final _fontSize = event.config!.fontSize!;
    final _height = event.config!.lineBwHeight!;
    final _bgcolor = event.config!.bgcolor!;
    final _fontColor = event.config!.fontColor!;
    final _fontFamily = event.config!.fontFamily!;
    final _axis = event.config!.axis!;
    final _p = event.config!.patternList!;
    final _portrait = event.config!.portrait!;
    if (_fontSize != config.fontSize ||
        _fontFamily != config.fontFamily ||
        _fontColor != config.fontColor ||
        _height != config.lineBwHeight ||
        _axis != config.axis ||
        event.patternChange) {
      flush = true;
    }

    // 横屏切换由 sizeChange 处理
    await orientation(_portrait);
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

    print(config);
    if (flush) {
      await exitBlockingAndInCompute(() async {
        reset(clearCache: true);
        final timer = Timer(Duration(milliseconds: 400), () {
          notifyState(loading: true);
        });
        await loadFirst();
        timer.cancel();
      });
    }
    statusColor();
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
    otherHeight = ePadding * 2 + topPad + botPad + secstyle.fontSize! * 2;
  }

  Future<void> newBookOrCid(int newBookid, int cid, int page) async {
    if (cid == -1) return;
    controller?.goBallisticResolveWithLastActivity();

    orientation(config.portrait!);
    final _lastInBookView = _inBookView;

    if (tData.cid == null || tData.cid != cid || sizeChanged || tData.contentIsEmpty) {
      assert(Log.i('page: $page', stage: this, name: 'newBook'));
      final diffBook = bookid != newBookid || sizeChanged;
      assert(canLoad == null || canLoad!.isCompleted);
      if (!_lastInBookView) canLoad = Completer<void>();
      notifyState(ignore: true);

      await exitBlocking(() async {
        await canLoad?.future;
        out();

        if (!_lastInBookView) {
          await uiOverlay();
        }
        await Future.delayed(const Duration(milliseconds: 50));
        await sizeChange();

        // size 可能改变，视图还没有更新
        if (sizeChanged) {
          painter();
        }
        sizeChanged = false;

        notifyState(ignore: true);

        final timer = Timer(Duration(milliseconds: 100), () async {
          notifyState(loading: true);
        });
        currentPage = page;

        reset(clearCache: diffBook, cid: cid);
        bookid = newBookid;

        // 重置状态
        completercanCompute();

        inbook();
        await dump();

        await loadFirst();
        if (!timer.isActive) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        timer.cancel();
        painter();

        resetController();
      });
    } else {
      inbook();
      if (!_lastInBookView || !config.portrait!) {
        Future.delayed(const Duration(milliseconds: 300), uiOverlay);
      }
    }
    notifyState(loading: false, ignore: false);
    Future.delayed(const Duration(milliseconds: 400), () => statusColor());
  }

  Size size = Size.zero;
  var sizeChanged = true;
  var safePadding = EdgeInsets.zero;
  var paddingRect = EdgeInsets.zero;

  /// 待测试
  Future<void> sizeChange() async {
    var _size = Size.zero;
    var _p = EdgeInsets.zero;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await repository.getViewInsets();
        _size = repository.viewInsets.size;
        _p = repository.viewInsets.padding;
        assert(Log.i('safePadding: $paddingRect, $_size', stage: this, name: 'sizeChange'));
        break;

      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        final w = ui.window;
        _size = w.physicalSize / w.devicePixelRatio;
        _p = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);
        break;

      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        final w = ui.window;
        _size = w.physicalSize / w.devicePixelRatio;
        _p = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);

        if ((_p.top == 0.0 && safePadding.top != _p.top) || size.height < _size.height || size.width != _size.width) {
          size = _size;
          safePadding = _p;
          paddingRect = _p.copyWith(bottom: _p.bottom != 0.0 ? 10.0 : 0.0, left: 16.0, right: 16.0);
          sizeChanged = true;
        } else {
          sizeChanged = false;
        }
        return;
    }
    if (size != _size || safePadding != _p) {
      size = _size;
      safePadding = _p;
      sizeChanged = true;
      // 从安全边界获取
      paddingRect = EdgeInsets.only(
        left: safePadding.left + 16,
        top: safePadding.top,
        right: safePadding.right + 16,
        bottom: safePadding.bottom,
      );
    }
  }

  /// 首次（重置）加载
  Future<void> loadFirst() async {
    final _bookid = bookid!;
    final _key = tData.cid!;
    assert(Log.i('cid: $_key', stage: this, name: 'loadFirst'));
    await loadData(_key, _bookid);
    final _currentText = getTextData(_key);
    if (_bookid == bookid && _currentText != null && _currentText.contentIsNotEmpty && _key == _currentText.cid) {
      tData = _currentText;
    }
    if (bookid == _bookid && tData.contentIsNotEmpty && _key == tData.cid) {
      if (currentPage > tData.content.length) {
        currentPage = tData.content.length;
      }
    }
  }

  bool hasContent(ContentBounds key, int index) {
    assert(tData.contentIsNotEmpty);
    final exPage = index - _innerIndex;
    var result = true;
    if (key == ContentBounds.getRight) {
      result = currentPage + exPage < tData.content.length || caches.containsKey(tData.nid);
    } else {
      result = currentPage + exPage > 1 || caches.containsKey(tData.pid);
    }
    delayedLoad();
    return result;
  }

  /// TODO: 对 pid / nid 进行校验
  /// 发现一个极小的错误：原始数据 pid / nid 可能没有对应，（如：preData.pid == currentData.pid）
  /// 如：从 nextData 检测 pid == currentData.cid，则一直递推（最多3次）
  /// 最后从 indexs 推断
  Widget? getWidget(int page, {bool changeState = false}) {
    if (changeState && page == _innerIndex) return null;
    // print('page:$page, $_innerIndex');
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
          dump();
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
        if (config.axis == Axis.vertical) {
          final footv = '$currentPage/${text.content.length}页';
          scheduleMicrotask(() {
            footer.value = footv;
            header.value = text.cname!;
          });
        }
        break;
      } else if (contentIndex < 0) {
        if (caches.containsKey(text.pid)) {
          text = getTextData(text.pid!)!;
          currentContentFirstIndex -= text.content.length;
        } else {
          break;
        }
      } else if (contentIndex >= length) {
        if (caches.containsKey(text.nid)) {
          currentContentFirstIndex += length;
          text = getTextData(text.nid!)!;
        } else {
          break;
        }
      }
    }
    return child;
  }

  TextStyle getStyle(ContentViewConfig config) {
    return TextStyle(
      fontSize: config.fontSize,
      color: config.fontColor!,
      height: 1.0,
      fontFamily: 'NotoSansSC', // SourceHanSansSC
    );
  }

  static const pageNumSize = 13.0;
  static const topPad = 8.0;
  static const ePadding = 8.0;
  static const botPad = 4.0;
  // static double safeleft = 16;
  late double otherHeight;
  final reg = RegExp('\u0009|\u000B|\u000C|\u000D|\u0020|'
      '\u00A0|\u1680|\uFEFF|\u205F|\u202F|\u2028|\u2000|\u2001|\u2002|'
      '\u2003|\u2004|\u2005|\u2006|\u2007|\u2008|\u2009|\u200A|(&nbsp;)+');

  /// TODO: 在 [Isolate] 进行布局
  /// ffi
  List<ContentMetrics> divText(String _text, String cname) {
    assert(_text.isNotEmpty);
    final _size = Size(size.width - paddingRect.horizontal, size.height - paddingRect.vertical);

    final leftExtraPadding = (_size.width % style.fontSize!) / 2;
    final left = paddingRect.left + leftExtraPadding;
    final pages = <List<String>>[];

    assert(Log.i('working   >>>'));
    final now = Timeline.now;

    // /// layout
    // var _text = text.replaceAll(reg, '').replaceAll(RegExp('([(\n|<br/>)\u3000*]+(\n|<br/>))|(<br/>)'), '\n');
    // if (_text.startsWith(RegExp('\n'))) {
    //   _text = _text.replaceFirst(RegExp('\n'), '');
    // }
    // if (!_text.startsWith(RegExp('\u3000'))) {
    //   _text = '\u3000\u3000' + _text;
    // }

    final _textPainter = TextPainter(text: TextSpan(text: _text, style: style), textDirection: TextDirection.ltr)
      ..layout(maxWidth: _size.width);
    final _cPainter = TextPainter(
        text: TextSpan(
            text: cname, style: TextStyle(fontSize: 22, color: config.fontColor!, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: _size.width);
    final nowx = Timeline.now;

    var page = <String>[];
    final lineMcs = _textPainter.computeLineMetrics();

    final contentAll = _size.height - otherHeight;
    final topHeight = (_cPainter.height / lineMcs.first.height).floor();
    final lineHeight = config.lineBwHeight! * config.fontSize!;
    final lineHeightAndExtral = (contentAll % lineHeight) / (contentAll ~/ lineHeight) + lineHeight;

    var whiteCounts = 0;
    var leaf = 10;
    var done = false;
    while (true) {
      for (var i = 1; i < 10; i++) {
        final s = (lineHeightAndExtral * i - 110);
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
      if (done) {
        break;
      }
      leaf += 10;
    }
    if (lineHeightAndExtral * whiteCounts > 200) {
      whiteCounts--;
    }

    // lines
    var lineCount = 1;
    // 当前行（高）
    var hieghtIncrement = 0.0;
    var start = 0;

    var whiteHeight = whiteCounts * lineHeightAndExtral;
    var whiteAndOtherHeight = style.fontSize! * topHeight + whiteHeight / config.lineBwHeight!;
    final contentHeight = contentAll / config.lineBwHeight!;

    for (var mcs in lineMcs) {
      final end = _textPainter.getPositionForOffset(Offset(_textPainter.width, hieghtIncrement));
      final l = _text.substring(start, end.offset).replaceAll('\n', '');

      hieghtIncrement += mcs.height;
      if (mcs.height > style.fontSize!) {
        whiteAndOtherHeight -= (mcs.height - style.fontSize!);
      }

      if (hieghtIncrement > contentHeight * lineCount - whiteAndOtherHeight) {
        hieghtIncrement -= mcs.height;
        whiteAndOtherHeight = contentHeight * lineCount - hieghtIncrement;
        lineCount += 1;
        pages.add(page);
        page = <String>[];
        if (l.isEmpty) {
          // 文本为空，但是逻辑中还是占用着空间，所以要移到[ex](额外空间)
          whiteAndOtherHeight += mcs.height;
        } else {
          page.add(l);
        }
        hieghtIncrement += mcs.height;
      } else {
        page.add(l);
      }
      start = end.offset;
    }
    // 到最后，我们还有一页没处理
    // 处理最后一行空白的情况
    page.removeWhere((element) {
      return element.replaceAll(RegExp('( |\u3000)+'), '').isEmpty;
    });
    // 避免空白页
    if (page.isNotEmpty) {
      pages.add(page);
    }
    assert(Log.i('div : ${(Timeline.now - nowx) / 1000}ms'));
    // end: div string--------------------------------------

    /// 最后一页行数可能不会占满，因此保留上一个额外高度[exh]
    // var lastPageExh = 0.0;
    var textPages = <ContentMetrics>[];
    final cnamePainter =
        TextPainter(text: TextSpan(text: cname, style: secstyle), textDirection: TextDirection.ltr, maxLines: 1)
          ..layout(maxWidth: _size.width);

    var exh = lineHeightAndExtral - config.fontSize!;
    for (var r = 0; r < pages.length; r++) {
      /// layout
      final isHorizontal = config.axis == Axis.horizontal;
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle), textDirection: TextDirection.ltr)
        ..layout(maxWidth: _size.width);
      final right = _size.width - bottomRight.width - leftExtraPadding * 2;

      final _teps = <TextPainter>[];
      for (var l in pages[r]) {
        final _tep = TextPainter(
          text: TextSpan(text: l, style: style),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: _size.width);
        _teps.add(_tep);
      }

      final met = ContentMetrics(
          painters: _teps,
          extraHeightInLines: exh,
          isHorizontal: isHorizontal,
          secstyle: secstyle,
          fontSize: style.fontSize!,
          topPad: topPad,
          cPainter: cnamePainter,
          botRightPainter: bottomRight,
          cBigPainter: _cPainter,
          right: right,
          left: left,
          index: r,
          topHeight: topHeight,
          size: _size,
          windowTopPadding: paddingRect.top,
          showrect: showrect,
          whiteLines: whiteHeight);
      textPages.add(met);
    }
    assert(Log.i('用时: ${((Timeline.now - now) / 1000).toStringAsFixed(1)}ms'));
    assert(Log.i('work done <<<'));
    return textPages;
  }

  /// 缓存逻辑实现
  void cacheGbg(TextData _cnpid) {
    while (cacheQueue.length > 6) {
      caches.remove(cacheQueue.removeFirst());
    }

    cacheQueue.addLast(_cnpid.cid!);
    caches[_cnpid.cid!] = _cnpid;
  }

  /// 任务逻辑----------------
  void _load(int _bookid, int? contentid) {
    // 超过5个任务，由用户触发调用
    if (!_inBookView || _futures.length > 5) return;

    if (contentid != null &&
        _bookid == bookid &&
        contentid != -1 &&
        !caches.containsKey(contentid) &&
        !isLoading(contentid)) {
      final _ntask = loadData(contentid, _bookid);
      addTask(contentid, _ntask);
    }
  }

  void loadId(int? id) => _load(bookid!, id);

  Future? awiatId(int? id) => _futures[id];

  bool isLoading(int? id) => loadingId.contains(id) || _futures.containsKey(id);

  void unDelayedLoad() => _loadCallback();

  // 不用担心是否太频繁访问，在隔离中会自动判断并添加延时
  void loadauto(int? id) {
    final ndata = getTextData(id);
    if (ndata != null) loadId(ndata.nid);
    final pdata = getTextData(id);
    if (pdata != null) loadId(pdata.pid);
  }

  void _loadCallback() {
    loadResolve();

    // 自动缓存第二章，最多双向二级缓存
    loadId(tData.nid);
    loadId(tData.pid);
    loadauto(tData.nid);
    loadauto(tData.pid);
  }

  // 自动管理异步状态
  void addTask(int id, Future future) {
    assert(!_futures.containsKey(id));
    if (_futures.containsKey(id)) return;
    assert(loadingId.contains(id));
    _futures[id] = future.then((_) {
      _futures.remove(id);
      // 自动二级缓存
      // 当前章节向前向后缓存两个章节
      loadauto(tData.nid);
      loadauto(tData.pid);
    });

    assert(Log.i('正在进行的后台数：${_futures.length}', stage: this, name: 'addTask'));
  }

  /// 延迟，
  /// 在布局阶段重复调用
  /// 覆盖了 [tData] 是否会发生意外
  Future<void> loadResolve() async {
    if (tData.nid == -1 || tData.hasContent != 1) {
      void _getdata() {
        if (caches.containsKey(tData.cid)) {
          if (tData.contentIsNotEmpty &&
              (currentPage == tData.content.length || currentPage == 1) &&
              (canCompute == null || canCompute!.isCompleted)) {
            // 只会在停止滚动并且到达最后一页时更新UI
            tData = getTextData(tData.cid!)!;
            if (currentPage > tData.content.length) {
              currentPage = tData.content.length;
            }
            painter();
          }
        }
      }

      if (tData.contentIsNotEmpty) {
        final id = tData.cid!;
        final _tdata = caches[id];

        if (_tdata != null && _tdata.contentIsNotEmpty && _tdata.nid != -1) {
          // 已经重新加载到 caches 了
          _getdata();
          return;
        }

        if (errorID.contains(id)) return;

        assert(Log.i('https:nid == -1', stage: this, name: 'loadResolve'));

        errorID.add(id);
        Future.delayed(const Duration(seconds: 10), () => errorID.remove(id));
        await downFromNet(id, bookid!);
        _getdata();
      }
    }
  }

  // 立即
  Future<void> resolveId() async {
    if (tData.contentIsEmpty) return;
    var _tdata = getTextData(tData.cid);
    if (_tdata != null && (_tdata.hasContent != 1 || _tdata.nid == -1)) {
      await downFromNet(tData.cid!, bookid!);
      _tdata = getTextData(tData.cid);
      if (_tdata != null && _tdata.contentIsNotEmpty) {
        tData = _tdata;
      }
    }
  }

  bool delayed = false;
  void delayedLoad() {
    if (!delayed && _inBookView) {
      delayed = true;
      _loadCallback();
      dump();
      Future.delayed(const Duration(seconds: 5), () {
        delayed = false;
      });
    }
  }

  /// 任务逻辑---------------- end

  /// 锁函数
  // 无法退出，无法交互
  // 保证不会出现意外
  Future exitBlockingAndInCompute(FutureCallback callback) async {
    return exitBlocking(() => inCompute(callback));
  }

  Future exitBlocking(FutureCallback callback) async {
    _locked = true;
    await callback();
    _locked = false;
  }

  Future inCompute(FutureCallback callback) async {
    await _awaitCompute();
    computeCount++;
    await callback();
    computeCount--;
  }

  Future<void> _awaitCompute() async {
    if (canCompute != null && !canCompute!.isCompleted) {
      Log.i('awaiting >> ', stage: this, name: 'awaitCompute');
      await canCompute!.future;
    }
  }

  // 文本布局要占用 UI 时间，只在空闲计算
  Future<void> awaitCompute(FutureCallback callback) async {
    return inCompute(() async {
      if (!_inBookView) return;
      if (_loading.value) {
        notifyState(loading: false);
        await Future.delayed(const Duration(milliseconds: 20));
      }
      await callback();
    });
  }

  Future<void> updateCurrent() => inCompute(resolveId);

  /// pid == -1 一般是不需要重新下载的
  Future<void> willGoProOrNext({bool isPid = false}) async {
    if (_inPreOrNext || tData.contentIsEmpty) return;
    notifyState(loading: true);
    _inPreOrNext = true;
    // 禁止手势指针
    await inCompute(() async {
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
          notifyState(loading: false, error: const NotifyMessage(true, msg: NotifyMessage.notNext));
        }
      }
    });

    notifyState(loading: false);
    _inPreOrNext = false;
  }

  Future<bool> getContent(int getid) async {
    var _data = getTextData(getid);
    if (_data == null || _data.contentIsEmpty) {
      unDelayedLoad();
      await awiatId(getid);
      _data = getTextData(getid);
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
  final errorID = <int>{};
  final caches = <int, TextData>{};
  final cacheQueue = Queue<int>();
  final loadingId = <int>{};

  int get tasksLength => _futures.length;
  // 正在进入章节阅读页面，[true] 阻止页面退出
  var _locked = false;
  bool get locked => _locked;

  // 异步任务时防止用户滚动
  int computeCount = 0;
  Completer<void>? canCompute;
  Completer<void>? canLoad;
  bool _inBookView = false;
  bool _awaitDump = false;
  bool _inPreOrNext = false;

  ///-------------------------

  // 加载状态
  // 是否直接忽略
  // 显示网络错误信息
  NopPageViewController? controller;
  final _loading = ValueNotifier(false);
  final _ignore = ValueNotifier(true);
  final _error = ValueNotifier(NotifyMessage(false));

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
    computeCount++;
    notifyState(ignore: false, loading: false);
    add(_InnerEvent());
  }

  void reset({bool clearCache = false, int? cid}) {
    tData = TextData()..cid = cid ?? tData.cid;
    if (clearCache) {
      cacheQueue.clear();
      caches.clear();
    }
  }

  void completerCanLoad() {
    if (canLoad != null && !canLoad!.isCompleted) {
      canLoad!.complete();
    }
  }

  void completercanCompute() {
    if (canCompute != null && !canCompute!.isCompleted) {
      canCompute!.complete();
    }
  }

  void setcanCompute() {
    if (canCompute == null || canCompute!.isCompleted) {
      canCompute = Completer<void>();
    }
  }

  void out() {
    _inBookView = false;
    resetController();
  }

  void inbook() => _inBookView = true;

  // _innerIndex == page == 0
  void resetController() {
    controller?.setPixelsWithoutNtf(0.0);
    _innerIndex = 0;
    controller?.goIdle();
  }

  Future<void> dump() async {
    if (_awaitDump) return;
    if (tData.cid != null) {
      _awaitDump = true;
      await undelayedDump();
      Future.delayed(const Duration(seconds: 1), () => _awaitDump = false);
    }
  }

  Future<void> undelayedDump() async {
    await repository.innerdb.updateMainInfo(bookid!, tData.cid!, currentPage);
    bookIndexBloc.add(BookIndexShowEvent(id: bookid, cid: tData.cid));
  }

  void notifyState({bool? loading, bool? ignore, NotifyMessage? error}) {
    if (loading.isNotNull) _loading.value = loading!;
    if (ignore.isNotNull) _ignore.value = ignore!;
    if (error.isNotNull) _error.value = error!;
  }

  void statusColor() {
    final hsl = HSVColor.fromColor(config.bgcolor!);
    uiStyle(dark: hsl.value > 0.6);
  }

  /// 文本加载-----------------
  TextData? getTextData(int? key) {
    if (caches.containsKey(key)) {
      // 移到最后
      cacheQueue.remove(key);
      cacheQueue.addLast(key!);
      return caches[key];
    }
    assert(Log.i('textData is null', stage: this, name: 'getTextData'));
  }

  Future<void> loadData(int _contentKey, int _bookid) async {
    if (loadingId.contains(_contentKey) || caches.containsKey(_contentKey)) return;

    loadingId.add(_contentKey);

    var contain = false;

    void _innerGetData(int _key) {
      final result = getTextData(_key);
      contain = result != null && result.contentIsNotEmpty;
    }

    if (!contain) {
      await loadFromDb(_contentKey, _bookid);
      _innerGetData(_contentKey);
    }

    if (!contain) {
      await downFromNet(_contentKey, _bookid);
      _innerGetData(_contentKey);
    }
    loadingId.remove(_contentKey);
  }

  Future<void> loadFromDb(int contentid, int _bookid, {bool adopt = true}) async {
    var queryList = await repository.innerdb.loadFromDb(contentid, _bookid);
    if (queryList.isNotEmpty) {
      final map = queryList.first;
      final bookContent = BookContent.fromJson(map);
      if (map.contentIsNotEmpty) {
        return adoptText(bookContent, contentid, _bookid, adopt: adopt);
      }
    }
  }

  /// 下载章节内容
  Future<void> downFromNet(int contentid, int _bookid, {bool adopt = true}) async {
    if (contentid == -1) return;
    assert(Log.i('add loadingId: $contentid', stage: this, name: 'downFromNet'));
    final bookContent = await repository.getContentFromNet(_bookid, contentid);
    if (_bookid != bookid) return;
    if (bookContent.content != null) {
      // 首先保存到数据库中
      repository.innerdb.saveToDatabase(bookContent);
      return adoptText(bookContent, contentid, _bookid, adopt: adopt);
    }
  }

  Future<void> adoptText(BookContent bookContent, int contentid, int _bookid, {bool adopt = true}) async {
    return awaitCompute(() {
      if (_bookid != bookid) return;
      final list = divText(bookContent.content!, bookContent.cname!);
      assert(list.isNotEmpty);
      final _cnpid = TextData(
        content: list,
        nid: bookContent.nid,
        pid: bookContent.pid,
        cid: bookContent.cid,
        hasContent: bookContent.hasContent,
        cname: bookContent.cname,
      );
      if (adopt) cacheGbg(_cnpid);
    });
  }

  ///-----------------
  Future<void> deleteCache(int bookId) async {
    return repository.innerdb.deleteCache(bookId);
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
    required this.topPad,
    required this.index,
    required this.topHeight,
    required this.size,
    required this.windowTopPadding,
    required this.showrect,
    required this.whiteLines,
  });
  final List<TextPainter> painters;
  final double extraHeightInLines;
  final TextStyle secstyle;
  final double fontSize;
  final bool isHorizontal;
  final double topPad;
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
  final double whiteLines;
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

class PainterSetPreferencesEvent extends PainterEvent {
  PainterSetPreferencesEvent({this.config, this.patternChange = false});
  final ContentViewConfig? config;
  final bool patternChange;
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
