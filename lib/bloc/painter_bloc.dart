import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';

import '../data/book_content.dart';
import '../pages/book_content_view/page_view_controller.dart';
import '../utils/utils.dart';
import 'book_index_bloc.dart';
import 'book_repository.dart';

typedef WidgetCallback = Widget? Function(int page, {required bool changeState});
typedef SetPageNotifier = void Function(double, void Function(int page));

class ContentViewConfig {
  ContentViewConfig(
      {this.fontSize, this.lineBwHeight, this.bgcolor, this.fontFamily, this.fontColor, this.locale, this.axis});
  double? fontSize;
  double? lineBwHeight;
  int? bgcolor;
  String? fontFamily;
  int? fontColor;
  Locale? locale;
  Axis? axis;
  ContentViewConfig copyWith(
      {double? fontSize,
      double? lineBwHeight,
      int? bgcolor,
      int? fontFamily,
      int? fontColor,
      Locale? locale,
      Axis? axis}) {
    return ContentViewConfig(
      fontColor: fontColor ?? this.fontColor,
      fontFamily: fontFamily as String? ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineBwHeight: lineBwHeight ?? this.lineBwHeight,
      bgcolor: bgcolor ?? this.bgcolor,
      locale: locale ?? this.locale,
      axis: axis ?? this.axis,
    );
  }

  @override
  String toString() {
    return '$runtimeType: fontSize: $fontSize, lineBwHeight: $lineBwHeight,'
        ' bgcolor: $bgcolor, fontFamily: $fontFamily, fontColor: $fontColor, local: $locale, axis: $axis';
  }
}

abstract class PainterEvent {
  PainterEvent();
}

class PainterShowShadowEvent extends PainterEvent {}

class PainterReloadEvent extends PainterEvent {}

class PainterInitEvent extends PainterEvent {}

class PainterNewBookIdEvent extends PainterEvent {
  PainterNewBookIdEvent(this.id, this.cid, this.page);
  final int id;
  final int cid;
  final int page;
}

class PainterSetPreferencesEvent extends PainterEvent {
  PainterSetPreferencesEvent({this.config});
  final ContentViewConfig? config;
}

class PainterDeleteCachesEvent extends PainterEvent {
  PainterDeleteCachesEvent(this.bookId);
  final int bookId;
}

class PainterLoadEvent extends PainterEvent {}

class PainterOutEvent extends PainterEvent {
  PainterOutEvent({this.changeState = true});
  final bool changeState;
}

class PainterPreEvent extends PainterEvent {}

class PainterNextEvent extends PainterEvent {}

class PainterMetricsChangeEvent extends PainterEvent {}

class PainterState {
  PainterState({this.empty});
  final bool? empty;
  bool get isNull => empty == null;
}

enum Status { ignore, error, done }

class TextData {
  TextData({this.content, this.cid, this.pid, this.nid, this.cname}) {
    content ??= [];
  }
  List<ContentMetrics>? content;
  int? cid;
  int? pid;
  int? nid;
  String? cname;

  bool get isEmpty => content!.isEmpty || cid == null || pid == null || nid == null || cname == null;

  bool get isNotEmpty => !isEmpty;
  void clear() {
    content?.clear();
    pid = nid = cname = null;
  }

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;
}

class PainterBloc extends Bloc<PainterEvent, PainterState> {
  PainterBloc({required this.repository, required this.bookIndexBloc}) : super(PainterState(empty: true)) {
    completer.complete(Status.ignore);
    sizeChange();
    // Fps.instance.start();
  }

  final BookRepository repository;
  final BookIndexBloc bookIndexBloc;

  /// ----------   状态   --------------------------
  Size size = Size.zero;

  int? bookid;

  int currentPage = 1;

  // bool showRect = false;

  /// ----------------------------------------------

  TextData tData = TextData();
  ContentViewConfig config = ContentViewConfig();

  var cache = <int, TextData>{};

  /// download ID
  List<int> loadingId = [];

  /// 网络任务异步状态
  var completer = Completer<Status>();

  var sizeChanged = true;
  var padding = const EdgeInsets.all(0.0);
  var realPadding = const EdgeInsets.all(0.0);
  @override
  Stream<PainterState> mapEventToState(PainterEvent event) async* {
    if (event is PainterNewBookIdEvent) {
      yield* await newBook(event);
    } else if (event is PainterInitEvent) {
      if (config.bgcolor == null) {
        await getPrefs();
      }
    } else if (event is PainterMetricsChangeEvent) {
      yield* await metricsChange();
    } else if (event is PainterSetPreferencesEvent) {
      yield* await setPrefs(event);
    } else if (event is PainterDeleteCachesEvent) {
      await deleteCache(event.bookId);
    } else if (event is PainterPreEvent) {
      yield* await goPre();
    } else if (event is PainterNextEvent) {
      yield* await goNext();
    } else if (event is PainterShowShadowEvent) {
      yield* await showdow();
    } else if (event is PainterLoadEvent) {
      yield painter(ign: true);
      loading.value = true;
      await completer.future;
      await loadFirst();
      await Future.delayed(Duration(milliseconds: 400));
      yield painter();
      loading.value = false;
    } else if (event is PainterReloadEvent) {
      if (_inBookView && tData.contentIsNotEmpty) {
        await loadPN(tData.pid!, tData.cid!, tData.nid!, bookid!, update: true);
      }
    } else if (event is PainterOutEvent) {
      if (event.changeState) {
        _inBookView = false;
      }
      // memoryToDatabase();
    }
  }

  Stream<PainterState> metricsChange() async* {
    sizeChange();
    if (sizeChanged && _inBookView) {
      reset(clearCache: true);
      sizeChanged = false;
      yield painter(ign: true);
      if (!completer.isCompleted) {
        _inBookView = false;
        await completer.future;
        _inBookView = true;
      }
      await loadFirst();
      yield painter();
    }
  }

  Stream<PainterState> goPre() async* {
    final _pid = tData.pid;
    if (_pid == null) return;
    final _cid = tData.cid;
    final _nid = tData.nid;
    final _bookid = bookid!;
    yield painter();
    loading.value = true;
    await Future.delayed(Duration(milliseconds: 100));
    if (!cache.containsKey(tData.pid)) {
      await completer.future;
      await loadPN(_pid, _cid!, _nid!, _bookid);
      if (!cache.containsKey(tData.pid)) {
        yield painter();
        loading.value = false;
        error.value = true;
        return;
      }
    }
    if (canCompute != null && !canCompute!.isCompleted) {
      await canCompute!.future;
    }
    tData = cache[tData.pid] ?? TextData();
    currentPage = 1;
    controller?.setPixelsWithoutNtf(0.0);
    _innerIndex = 0;

    yield painter();
    loading.value = false;
    loadPNCb();
    bookIndexBloc.add(BookIndexShowEvent(id: bookid, cid: tData.cid));
  }

  Stream<PainterState> goNext() async* {
    final _nid = tData.nid;
    if (_nid == null) return;
    final _pid = tData.pid;
    final _cid = tData.cid;
    final _bookid = bookid!;
    yield painter();
    loading.value = true;
    if (!cache.containsKey(tData.nid)) {
      await completer.future;
      await loadPN(_pid!, _cid!, _nid, _bookid);
      if (!cache.containsKey(tData.nid)) {
        yield painter();
        loading.value = false;
        error.value = true;
        return;
      }
    }
    if (canCompute != null && !canCompute!.isCompleted) {
      await canCompute!.future;
    }
    tData = cache[tData.nid] ?? TextData();
    currentPage = 1;
    controller?.setPixelsWithoutNtf(0.0);
    _innerIndex = 0;

    yield painter();
    bookIndexBloc.add(BookIndexShowEvent(id: bookid, cid: tData.cid));
    loading.value = false;
    loadPNCb();
  }

  void completerResolve(Status value) {
    if (!completer.isCompleted) {
      completer.complete(value);
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

  void out() {
    _inBookView = false;
    if (tData.contentIsEmpty) {
      ignore.value = true;
    }
  }

  void inbook() {
    _inBookView = true;
  }

  bool showrect = false;
  Stream<PainterState> showdow() async* {
    showrect = !showrect;
    reset(clearCache: true);
    yield painter(ign: true);
    loading.value = true;
    await completer.future;
    await loadFirst();
    yield painter();
    loading.value = false;
  }

  Stream<PainterState> setPrefs(PainterSetPreferencesEvent event) async* {
    var flush = false;
    final _fontSize = event.config!.fontSize!;
    final _height = event.config!.lineBwHeight!;
    final _bgcolor = event.config!.bgcolor!;
    final _fontColor = event.config!.fontColor!;
    final _fontFamily = event.config!.fontFamily!;
    final _axis = event.config!.axis!;
    if (_fontSize != config.fontSize ||
        _fontFamily != config.fontFamily ||
        _height != config.lineBwHeight ||
        _fontColor != config.fontColor ||
        _axis != config.axis) {
      flush = true;
    }

    await getPrefs((box) async {
      await box.put('bgcolor', _bgcolor);
      await box.put('fontColor', _fontColor);
      await box.put('axis', _axis.index);
      if (_fontSize > 0) await box.put('fontSize', _fontSize);
      if (_height >= 1.0) await box.put('lineBwHeight', _height);
      if (_fontFamily.isNotEmpty) await box.put('fontFamily', _fontFamily);
    });
    print(config);
    if (flush) {
      reset(clearCache: true);
      yield painter(ign: true);
      loading.value = true;
      await completer.future;
      await loadFirst();
    }
    yield painter();
  }

  Future<void> getPrefs([Future<void> Function(Box)? callback]) async {
    final box = await Hive.openBox('settings');
    if (callback != null) {
      await callback(box);
    }
    final _bgcolor = box.get('bgcolor') ?? 4293120424;
    final _fontColor = box.get('fontColor') ?? 4283321934;
    final axis = box.get('axis') ?? Axis.horizontal.index;
    final _fontSize = box.get('fontSize') ?? 18.0;
    final _height = box.get('lineBwHeight') ?? 1.4;
    final _fontFamily = box.get('fontFamily') ?? '';
    await box.close();
    config.fontSize = _fontSize;
    config.lineBwHeight = _height;
    config.bgcolor = _bgcolor;
    config.fontFamily = _fontFamily;
    config.fontColor = _fontColor;

    config.axis = axis == Axis.horizontal.index ? Axis.horizontal : Axis.vertical;

    style = getStyle(config);
    secstyle = getStyle(config.copyWith(fontSize: 13));
    otherHeight = ePadding * 2 + topPad + botPad + secstyle.fontSize! * 2;
  }

  void reset({bool clearCache = false}) {
    loadingId.clear();
    tData = TextData()..cid = tData.cid;
    if (clearCache) {
      cache.clear();
    }
  }

  void resetController() {
    if (controller != null && controller!.viewPortDimension != null) {
      controller!.setPixelsWithoutNtf(controller!.page.round() * controller!.viewPortDimension!);
    }
  }

  Completer<void>? canLoad;
  bool _inBookView = false;
  NopPageViewController? controller;
  // 加载状态
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  // 是否直接忽略
  ValueNotifier<bool> ignore = ValueNotifier<bool>(false);
  // 显示网络错误信息
  ValueNotifier<bool> error = ValueNotifier(false);
  Stream<PainterState> newBook(PainterNewBookIdEvent event) async* {
    if (event.cid == -1) return;
    ignore.value = true;
    controller?.setPixelsWithoutNtf(0.0);
    final _lastIbv = _inBookView;

    _innerIndex = 0;
    if (tData.cid == null || tData.cid != event.cid || sizeChanged) {
      assert(Log.i('page: ${event.page}', stage: this, name: 'newBook'));
      final clear = bookid != event.id || sizeChanged;
      if (!clear) {
        loading.value = true;
      }

      _inBookView = false;
      if (!completer.isCompleted) {
        // 尽快退出其他任务；
        if (loadingId.isNotEmpty) {
          await repository.restartClient();
        }
        await completer.future;
      }

      currentPage = event.page;
      tData.cid = event.cid;
      reset(clearCache: clear);
      bookid = event.id;
      _inBookView = true;

      // 更新信息
      dump();
      await canLoad?.future;

      if (!_lastIbv) {
        await SystemChrome.setEnabledSystemUIOverlays([]);
      }
      await Future.delayed(Duration(milliseconds: 150));
      sizeChange();

      sizeChanged = false;
      bookIndexBloc.add(BookIndexShowEvent(id: bookid, cid: tData.cid));
      final timer = Timer(Duration(milliseconds: 500), () {
        loading.value = true;
      });
      await loadFirst();
      timer.cancel();
      yield painter();
      if (config.axis == Axis.vertical) {
        resetController();
      }
    } else {
      _inBookView = true;
      await canLoad?.future;
      if (!_lastIbv) {
        await SystemChrome.setEnabledSystemUIOverlays([]);
      }
    }
    loading.value = false;
    ignore.value = false;
  }

  void sizeChange() {
    final w = ui.window;
    var _size = w.physicalSize / w.devicePixelRatio;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final sysinsets = w.systemGestureInsets;
        var _padding = EdgeInsets.fromWindowPadding(sysinsets, w.devicePixelRatio);
        // 虚拟导航栏

        if (padding.top != _padding.top) {
          padding = _padding.copyWith(bottom: 0.0);
          sizeChanged = true;
        }
        if (padding.bottom > _padding.bottom || _padding.bottom > 0.0) {
          // 虚拟导航栏 bottom += 8.0; 底部非直角；
          if (padding.bottom != 8.0) {
            padding = padding.copyWith(bottom: 8.0);
            sizeChanged = true;
          }
        }
        assert(Log.i('size: $size, $_size, $padding'));
        // 检测底部导航栏是否是虚拟的
        if (size != _size) {
          if (_size.height != size.height - realPadding.bottom) {
            size = _size;
            sizeChanged = true;
            realPadding = _padding;
          }
        }
        break;

      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        var _padding = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);
        if (size != _size || padding != _padding) {
          size = _size;
          padding = _padding;
          sizeChanged = true;
        }
        break;
      case TargetPlatform.fuchsia:
      // 不清楚，暂时和iOS一样
      case TargetPlatform.iOS:
        // ios 全面屏：padding，size 不变,待测试
        var _padding = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);
        if ((_padding.top == 0.0 && padding.top != _padding.top) ||
            // padding.bottom != _padding.bottom || // iPhone 不用检测底部
            size.height < _size.height ||
            size.width != _size.width) {
          size = _size;
          padding = _padding.copyWith(bottom: _padding.bottom != 0.0 ? 10.0 : 0.0);
          sizeChanged = true;
        } else {
          sizeChanged = false;
        }
        break;
    }
  }

  /// 持久化本地
  Future<void> memoryToDatabase(BookContent bookContent) async {
    final count = Sqflite.firstIntValue(await repository.innerdb.db
        .rawQuery('SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?', [bookContent.id, bookContent.cid]));
    if (count! > 0) {
      await repository.innerdb.db.rawUpdate(
          'UPDATE BookContent SET pid = ?, nid = ?, hasContent = ?,content = ? WHERE bookId = ? AND cid = ?', [
        bookContent.pid,
        bookContent.nid,
        bookContent.hasContent,
        bookContent.content,
        bookContent.id,
        bookContent.cid
      ]);
    } else {
      await repository.innerdb.db.rawInsert(
        'INSERT INTO BookContent (bookId, cid, cname, nid, pid, content, hasContent)'
        ' VALUES(?,?,?,?,?,?,?)',
        [
          bookContent.id,
          bookContent.cid,
          bookContent.cname,
          bookContent.nid,
          bookContent.pid,
          bookContent.content,
          bookContent.hasContent,
        ],
      );
    }
  }

  // 等待UI空闲
  Future<void> awaitCompute(FutureOr<void> Function() call) async {
    if (canCompute != null && !canCompute!.isCompleted) {
      Log.i('awaiting >>', stage: this, name: 'awaitCompute');
      await canCompute!.future;
    }
    if (!_inBookView) return;
    computeCount++;
    if (loading.value) {
      loading.value = false;
      await Future.delayed(Duration(milliseconds: 50));
    }
    await call();
    computeCount--;
  }

  /// 这是访问网络的唯一方式；
  /// 由于访问网络有时间延迟，并且存在多次访问同一网址的可能，所以保存 contentid 在 [loadingId] 中,
  /// 以检测即将要访问的网址是否已存在。
  Future<void> downFromNet(int contentid, int _bookid) async {
    if (contentid == -1 || loadingId.contains(contentid)) return;
    loadingId.add(contentid);
    assert(Log.i('add loadingId: $contentid', stage: this, name: 'downFromNet'));
    final bookContent = await repository.getContentFromNet(_bookid, contentid);
    loadingId.remove(contentid);
    if (_bookid != bookid) return;
    if (bookContent.content != null) {
      await awaitCompute(() async {
        if (_bookid != bookid) return;
        final list = await divText(bookContent.content!, bookContent.cname!);
        assert(list.isNotEmpty);
        final _cnpid = TextData(
          content: list,
          nid: bookContent.nid,
          pid: bookContent.pid,
          cid: bookContent.cid,
          cname: bookContent.cname,
        );
        cacheGbg(_cnpid);
      });
      await memoryToDatabase(bookContent);
    }
  }

  // return: 可能为空
  Future<TextData> loadData(int _contentid, int _bookid) async {
    var result = TextData();
    var contain = false;
    void cacheReturn(int _contentid) {
      if (cache.containsKey(_contentid)) {
        result = cache[_contentid]!;
        contain = result.nid != null && result.nid != -1;
        return;
      }
      contain = false;
    }

    /// 1
    /// cache
    cacheReturn(_contentid);
    if (contain) return result;

    /// 2
    /// 从 数据库 中 加载
    await loadFromDb(_contentid, _bookid);
    cacheReturn(_contentid);
    if (contain) return result;

    /// last
    await downFromNet(_contentid, _bookid);
    cacheReturn(_contentid);
    return result;
  }

  /// 缓存当前章节前后几章
  void cacheGbg(TextData _cnpid) {
    if (cache.length >= 6) {
      final _tData = cache[tData.cid];
      if (_tData != null) {
        if (cache.containsKey(_tData.cid)) {
          final _cache = <int, TextData>{};

          if (cache.containsKey(_tData.pid)) {
            final _cp = cache[_tData.pid]!;
            _cache[_cp.cid!] = _cp;
            if (cache.containsKey(_cp.pid)) {
              _cache[_cp.pid!] = cache[_cp.pid]!;
            }
            // cache = _cache;
          }
          if (cache.containsKey(_tData.nid)) {
            final _cn = cache[_tData.nid]!;
            _cache[_cn.cid!] = _cn;
            if (cache.containsKey(_cn.nid)) {
              _cache[_cn.nid!] = cache[_cn.nid]!;
            }
          }
          _cache[_tData.cid!] = _tData;
          cache = _cache;
        }
      }
    }
    cache[_cnpid.cid!] = _cnpid;
  }

  Future<void> loadFromDb(int contentid, int _bookid) async {
    var queryList = await repository.innerdb.db.rawQuery(
        'SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [_bookid, contentid]);
    if (queryList.isNotEmpty) {
      final map = queryList.first;
      if (map.contentIsNotEmpty) {
        // if (map['hasContent'] != 1 || map['nid'] == -1) {
        //   await downFromNet(contentid, _bookid);
        // } else {
        assert(Log.i('url: ${BookRepository.contentUrl(_bookid, contentid)}', stage: this, name: 'loadFromDb'));
        await awaitCompute(() async {
          if (_bookid != bookid) return;
          final list = await divText(map['content'] as String, map['cname'] as String);
          assert(list.isNotEmpty);
          final _cnpid = TextData(
            cid: map['cid'] as int,
            nid: map['nid'] as int,
            pid: map['pid'] as int,
            cname: map['cname'] as String,
            content: list,
          );
          cacheGbg(_cnpid);
        });
        // }
      }
    }
  }

  PainterState painter({bool ign = false}) {
    ignore.value = ign;
    return PainterState(
      empty: tData.isNotEmpty,
    );
  }

  /// 首次（重置）加载
  Future<void> loadFirst() async {
    final _bookid = bookid!;
    final _cid = tData.cid!;
    Log.i('loadFirst: computeCount: $computeCount', stage: this, name: 'loadFirst');
    await load(() async {
      assert(Log.i('cid: $_cid', stage: this, name: 'loadFirst'));
      final _currentText = await loadData(_cid, _bookid);
      if (_bookid == bookid && _cid == _currentText.cid) {
        tData = _currentText;
      }
    });
    if (bookid == _bookid && tData.contentIsNotEmpty && _cid == tData.cid) {
      if (currentPage > tData.content!.length) {
        currentPage = tData.content!.length;
      }
    }
  }

  /// [loadFirst]
  /// [loadPN]
  /// 数据加载状态:[completer]
  int loadCount = 0;
  Future<void> load(Future<void> Function() callback) async {
    if (loadCount != 0) return;
    if (!completer.isCompleted) return;

    completer = Completer<Status>();
    assert(Log.i('load: start >'));
    loadCount += 1;
    await callback();
    loadCount -= 1;
    assert(Log.i('load: done  <\n——————————————————————'));
    completerResolve(tData.contentIsNotEmpty && cache.containsKey(tData.nid) && cache.containsKey(tData.pid)
        ? Status.done
        : Status.error);
  }

  final errorID = <int?>[];

  // /// pid/nid == -1的解决方案
  // Future<void> reloadFromNet(int _cid, int _bookid) async {
  //   Log.w('重新下载： 当前章节是否为第一章或最后一张,$_cid', stage: this, name: 'reloadFromNet');
  //   await downFromNet(_cid, _bookid);
  // }

  /// 异步 调用
  Future<void> loadPN(int _pid, int _cid, int _nid, int _bookid, {bool update = false}) async {
    await load(() async {
      if (_nid == -1 || update) {
        if (!errorID.contains(_cid) || update) {
          errorID.add(_cid);
          await downFromNet(_cid, _bookid);
          final _tdata = await loadData(_cid, _bookid);
          if (_tdata.contentIsNotEmpty && tData.cid == _cid) {
            tData = _tdata;
            if (_nid == -1 && tData.nid != null) _nid = tData.nid!;
          }
        }
      }
      // 进行异步任务时，需要检查页面是否已退出，以免等待过长时间。
      if (_inBookView && _nid != -1 && !cache.containsKey(_nid)) {
        await loadData(_nid, _bookid);
      }
      if (_inBookView && _pid != -1 && !cache.containsKey(_pid)) {
        await loadData(_pid, _bookid);
      }
    });
  }

  Future<void> deleteCache(int bookId) async {
    await repository.innerdb.db.rawDelete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  int nexttime = 0;
  Future<void> loadPNCb() async {
    if (_inBookView) {
      if (tData.nid == -1 || tData.pid == -1) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (nexttime + 1000 * 180 <= now) {
          nexttime = now;
          errorID.remove(tData.cid);
        }
      }
      if (tData.contentIsNotEmpty) {
        await loadPN(tData.pid!, tData.cid!, tData.nid!, bookid!);
      }
    }
  }

  TextStyle getStyle(ContentViewConfig config) {
    return TextStyle(
      fontSize: config.fontSize,
      color: Color(config.fontColor!),
      height: 1.0,
      fontFamily: 'NotoSansSC', // SourceHanSansSC
    );
  }

  bool delayed = false;
  bool hasContent(int key, int index) {
    assert(tData.contentIsNotEmpty);
    final exPage = index - _innerIndex;
    var result = true;
    if (key == 0) {
      result = currentPage + exPage < tData.content!.length || cache.containsKey(tData.nid);
    } else {
      result = currentPage + exPage > 1 || cache.containsKey(tData.pid);
    }
    if (!delayed) {
      delayed = true;
      if (!cache.containsKey(tData.pid) || !cache.containsKey(tData.nid)) {
        loadPNCb();
      }
      Future.delayed(Duration(seconds: 1), () {
        delayed = false;
      });
    }
    return result;
  }

  final header = ValueNotifier<String>('');
  final footer = ValueNotifier<String>('');

  int _innerIndex = 0;
  late TextStyle style;
  late TextStyle secstyle;

  Widget? getWidget(int page, {bool changeState = false}) {
    if (changeState && page == _innerIndex) return null;
    var currentContentFirstIndex = _innerIndex - currentPage + 1;
    TextData? text = tData;
    Widget? child;
    while (text != null && text.contentIsNotEmpty) {
      final tol = page - currentContentFirstIndex;
      final length = text.content!.length;
      if (tol >= 0 && tol <= length - 1) {
        _innerIndex = page;
        currentPage = tol + 1;
        if (!changeState) {
          child = ContentView(
            contentMetrics: tData.content![currentPage - 1],
          );
        }
        if (config.axis == Axis.vertical) {
          final footv = '${currentPage}/${text.content!.length}页';
          scheduleMicrotask(() {
            footer.value = footv;
            header.value = text!.cname!;
          });
        }
        break;
      } else if (tol < 0) {
        if (cache.containsKey(tData.pid)) {
          text = tData = cache[tData.pid]!;
          currentContentFirstIndex -= text.content!.length;
        } else {
          text = null;
        }
      } else if (tol >= length) {
        if (cache.containsKey(tData.nid)) {
          currentContentFirstIndex += length;
          text = tData = cache[tData.nid]!;
        } else {
          text = null;
        }
      }
    }
    return child;
  }

  Future<void> dump() async {
    if (tData.cid != null) {
      await repository.innerdb.updateMainInfo(bookid!, tData.cid!, currentPage);
    }
  }

  Completer<void>? canCompute;
  int computeCount = 0;
  static const topPad = 8.0;
  static const ePadding = 12.0;
  static const botPad = 4.0;
  late double otherHeight;
  final reg = RegExp('\u0009|\u000B|\u000C|\u000D|\u0020|'
      '\u00A0|\u1680|\uFEFF|\u205F|\u202F|\u2028|\u2000|\u2001|\u2002|'
      '\u2003|\u2004|\u2005|\u2006|\u2007|\u2008|\u2009|\u200A+');

  Future<List<ContentMetrics>> divText(String text, String cname) async {
    assert(text.isNotEmpty);
    final _size = Size(size.width - 32.0, size.height - padding.top - padding.bottom);

    final leftExtraPadding = (_size.width % style.fontSize!) / 2;
    final left = 16.0 + leftExtraPadding;
    final pages = <List<String>>[];

    assert(Log.i('working   >>>'));
    final now = Timeline.now;

    /// layout
    var _text = text.replaceAll(reg, '').replaceAll(RegExp('([\n\u3000*]+)\n'), '\n');
    if (_text.startsWith(RegExp('\n'))) {
      _text = _text.replaceFirst(RegExp('\n'), '');
    }
    if (!_text.startsWith(RegExp('\u3000'))) {
      _text = '\u3000\u3000' + _text;
    }

    final _textPainter = TextPainter(text: TextSpan(text: _text, style: style), textDirection: TextDirection.ltr)
      ..layout(maxWidth: _size.width);
    final _cPainter = TextPainter(
        text: TextSpan(
            text: cname, style: TextStyle(fontSize: 22, color: Color(config.fontColor!), fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: _size.width);
    final nowx = Timeline.now;

    // lines
    var lineCount = 1;
    // 当前行（高）
    var hx = 0.0;
    var start = 0;
    var page = <String>[];
    final lineMcs = _textPainter.computeLineMetrics();
    final topHeight = (_cPainter.height / lineMcs.first.height).floor();
    // 额外空间（首页上部空白空间，空白行）
    var ex = style.fontSize! * (topHeight + 3);
    final contentHeight = (_size.height - otherHeight) / config.lineBwHeight!;
    for (var mcs in lineMcs) {
      final end = _textPainter.getPositionForOffset(Offset(_textPainter.width, hx));
      final l = _text.substring(start, end.offset).replaceAll('\n', '');
      hx += mcs.height;
      if (mcs.height > style.fontSize!) {
        ex -= (mcs.height - style.fontSize!);
      }
      if (hx > contentHeight * lineCount - ex) {
        hx -= mcs.height;
        ex = contentHeight * lineCount - hx;
        lineCount += 1;
        pages.add(page);
        page = <String>[];
        if (l.isEmpty) {
          // 文本为空，但是逻辑中还是占用着空间，所以要移到[ex](额外空间)
          ex += mcs.height;
        } else {
          page.add(l);
        }
        hx += mcs.height;
      } else {
        page.add(l);
      }
      start = end.offset;
    }
    // 到最后，我们还有一页没处理
    // 处理最后一行空白的情况
    page.removeWhere((element) {
      return element.replaceAll(RegExp(' |\u3000+'), '').isEmpty;
    });
    // 避免空白页
    if (page.isNotEmpty) {
      pages.add(page);
    }
    assert(Log.i('div : ${(Timeline.now - nowx) / 1000}ms'));
    // end: div string--------------------------------------

    /// 最后一页行数可能不会占满，因此保留上一个额外高度[exh]
    var lastPageExh = 0.0;
    var textPages = <ContentMetrics>[];
    final cnamePainter = TextPainter(text: TextSpan(text: cname, style: secstyle), textDirection: TextDirection.ltr)
      ..layout(maxWidth: _size.width);
    for (var r = 0; r < pages.length; r++) {
      var exh = 0.0;

      /// layout
      final isHorizontal = config.axis == Axis.horizontal;
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle), textDirection: TextDirection.ltr)
        ..layout(maxWidth: _size.width);
      final right = _size.width - bottomRight.width - leftExtraPadding * 2;

      var lineCounts = pages[r].length;

      /// first page
      if (r == 0) {
        lineCounts += topHeight + 3;
      }
      if (contentHeight > (lineCounts + 1) * style.fontSize!) {
        if (lastPageExh == 0.0) {
          exh = (config.lineBwHeight! - 1) * style.fontSize!;
        } else {
          exh = lastPageExh;
        }
      } else {
        exh = (_size.height - otherHeight) / lineCounts - style.fontSize!;
        exh = exh;
        lastPageExh = exh;
      }
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
        botPad: botPad,
        topPad: topPad,
        cPainter: cnamePainter,
        botRightPainter: bottomRight,
        cBigPainter: _cPainter,
        right: right,
        left: left,
        index: r,
        topHeight: topHeight,
        size: _size,
        windowTopPadding: padding.top,
        showrect: showrect,
      );
      textPages.add(met);
    }
    assert(Log.i('用时: ${((Timeline.now - now) / 1000).toStringAsFixed(1)}ms'));
    assert(Log.i('work done <<<'));
    return textPages;
  }
}

class ContentMetrics {
  const ContentMetrics({
    required this.painters,
    required this.extraHeightInLines,
    required this.isHorizontal,
    required this.secstyle,
    required this.fontSize,
    required this.botPad,
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
  });
  final List<TextPainter> painters;
  final double extraHeightInLines;
  final TextStyle secstyle;
  final double fontSize;
  final bool isHorizontal;
  final double topPad;
  final double botPad;
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
}

class ContentView extends LeafRenderObjectWidget {
  ContentView({
    required this.contentMetrics,
  });

  final ContentMetrics contentMetrics;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContentView(contentMetrics: contentMetrics);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderContentView renderObject) {
    renderObject.contentMetrics = contentMetrics;
  }
}

class RenderContentView extends RenderBox {
  RenderContentView({
    required ContentMetrics contentMetrics,
  }) : _contentMetrics = contentMetrics {
    bottomLeft = TextPainter(text: TextSpan(), textDirection: TextDirection.ltr);
  }
  late TextPainter bottomLeft;

  ContentMetrics? _contentMetrics;
  ContentMetrics? get contentMetrics => _contentMetrics;
  set contentMetrics(ContentMetrics? v) {
    if (_contentMetrics == v) return;
    _contentMetrics = v;
    markNeedsLayout();
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void performLayout() {
    // size = constraints.biggest;
    if (contentMetrics!.isHorizontal) {
      final time = DateTime.now();
      bottomLeft.text =
          TextSpan(text: '${time.hour.timePadLeft}:${time.minute.timePadLeft}', style: contentMetrics!.secstyle);
      bottomLeft.layout(maxWidth: size.width);
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    dpaint(context, offset);
  }

  void dpaint(PaintingContext context, Offset offset) {
    // context.setIsComplexHint();
    final canvas = context.canvas;
    final isHorizontal = contentMetrics!.isHorizontal;
    final topPad = contentMetrics!.topPad;
    final bottomRight = contentMetrics!.botRightPainter;
    final right = contentMetrics!.right;
    final botPad = contentMetrics!.botPad;
    final e = contentMetrics!.extraHeightInLines;
    final fontSize = contentMetrics!.fontSize;
    final extraPadding = 12.0;
    final topHeight = contentMetrics!.topHeight;
    final _teps = contentMetrics!.painters;
    final index = contentMetrics!.index;
    final left = contentMetrics!.left;
    final cnamePainter = contentMetrics!.cPainter;
    final cBigPainter = contentMetrics!.cBigPainter;
    final _size = contentMetrics!.size;

    final windowTopPadding = isHorizontal ? contentMetrics!.windowTopPadding : 0;
    var h = 0.0;
    canvas.save();
    canvas.translate(offset.dx + left, offset.dy + windowTopPadding);
    if (isHorizontal) {
      h += topPad;
      cnamePainter.paint(canvas, Offset(0.0, h));
      h += cnamePainter.height;
    }
    if (index == 0) {
      if (!isHorizontal) {
        h -= extraPadding;
      }
      h += (fontSize + e) * (topHeight + 3);
      cBigPainter.paint(canvas, Offset(0.0, h - cBigPainter.height));
      if (!isHorizontal) {
        h += extraPadding;
      }
    }

    if (isHorizontal) {
      h += extraPadding;
    }
    // canvas.drawRect(Offset(0.0, h) & Size(_size.width, e / 2), Paint()..color = Colors.black.withAlpha(100));
    final xh = h;
    for (var _tep in _teps) {
      h += e / 2;
      _tep.paint(canvas, Offset(0.0, h));
      h += fontSize + e / 2;
    }
    // h -= e / 2;
    if (contentMetrics!.showrect) {
      canvas.drawRect(
          Offset(0.0, xh + e / 2) & Size(_size.width, h - xh - e - 1), Paint()..color = Colors.black.withAlpha(100));
    }
    // canvas.drawRect(
    //     Offset(0.0, h - e / 2 - 1) & Size(_size.width, e / 2), Paint()..color = Colors.black.withAlpha(100));
    // canvas.drawRect(Offset(0.0, 0) & Size(_size.width, h), Paint()..color = Colors.black.withAlpha(100));
    if (isHorizontal) {
      bottomRight.paint(canvas, Offset(right, _size.height - bottomRight.height - botPad));
      bottomLeft.paint(canvas, Offset(0.0, _size.height - bottomLeft.height - botPad));
    }
    canvas.restore();
  }

  // @override
  // bool hitTestSelf(ui.Offset position) => true;
}
