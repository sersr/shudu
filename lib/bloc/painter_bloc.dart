import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';

import '../data/book_content.dart';
import '../pages/book_content_view/page_view_controller.dart';
import '../utils/utils.dart';
import 'book_cache_bloc.dart';
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

abstract class PainterEvent extends Equatable {
  PainterEvent();
  @override
  List<Object?> get props => [];
}

class _PainterInnerEvent extends PainterEvent {}

class PainterReloadFromNetEvent extends PainterEvent {}

class PainterNotifyIdEvent extends PainterEvent {
  PainterNotifyIdEvent(this.id, this.cid, this.page);
  final int? id;
  final int? cid;
  final int? page;
  @override
  List<Object?> get props => [id, cid, page];
}

class PainterNotifySizeEvent extends PainterEvent {
  PainterNotifySizeEvent({required this.size});
  final Size size;

  @override
  List<Object> get props => [size];
}

class PainterSetPreferencesEvent extends PainterEvent {
  PainterSetPreferencesEvent({this.config});
  final ContentViewConfig? config;
  @override
  List<Object?> get props => [config];
}

class PainterDeleteCachesEvent extends PainterEvent {
  PainterDeleteCachesEvent(this.bookId);
  final int bookId;

  @override
  List<Object?> get props => [bookId];
}

class PainterNotifyLoadEvent extends PainterEvent {}

class PainterSaveEvent extends PainterEvent {}

class PainterPreEvent extends PainterEvent {}

class PainterNextEvent extends PainterEvent {}

// class PainterGCEvent extends PainterEvent {}

class PainterMetricsChangeEvent extends PainterEvent {}

class PainterState {
  PainterState({this.config, this.loading, this.empty, this.ignore});

  final ContentViewConfig? config;
  final bool? loading;
  final bool? empty;
  final bool? ignore;
  bool get isNull => config == null || loading == null || empty == null;
}

enum Status { ignore, error, done }

class TextData {
  TextData({this.content, this.cid, this.pid, this.nid, this.cname}) {
    content ??= [];
  }
  List<ui.Picture>? content;
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
  PainterBloc({required this.bookCacheBloc, required this.repository, required this.bookIndexBloc})
      : super(PainterState(loading: false, ignore: true, empty: true)) {
    completer.complete(Status.ignore);
    // Fps.instance.start();
  }

  final BookRepository repository;
  final BookCacheBloc bookCacheBloc;
  final BookIndexBloc bookIndexBloc;

  /// ----------   状态   --------------------------
  Size? size;

  int? bookid;

  int? currentPage = 1;

  // bool showRect = false;

  /// ----------------------------------------------

  TextData tData = TextData();
  ContentViewConfig config = ContentViewConfig();

  Map<int, TextData> cache = <int, TextData>{};
  Map<int, BookContent> memoryCache = {};

  /// download ID
  List<int> loadingId = [];

  /// 网络任务异步状态
  var completer = Completer<Status>();

  var sizeChanged = true;

  @override
  Stream<PainterState> mapEventToState(PainterEvent event) async* {
    if (event is PainterNotifySizeEvent) {
      // print(event.size);
      final _size = Size(event.size.width - 32.0, event.size.height);
      if (size != _size) {
        size = _size;
        sizeChanged = true;
      } else {
        sizeChanged = false;
      }
    } else if (event is PainterNotifyIdEvent) {
      yield* newBook(event);
    } else if (event is PainterNotifyLoadEvent) {
      yield painter(loading: true);
      await loadFirst();
      await Future.delayed(Duration(milliseconds: 400));
      yield painter();
    } else if (event is PainterDeleteCachesEvent) {
      await deleteCache(event.bookId);
    } else if (event is PainterSetPreferencesEvent) {
      yield* setPrefs(event);
    } else if (event is PainterSaveEvent) {
      inBookView = false;
      memoryToDatabase();
    } else if (event is PainterPreEvent) {
      yield* goPre();
    } else if (event is PainterNextEvent) {
      yield* goNext();
    } else if (event is _PainterInnerEvent) {
      yield painter();
    } else if (event is PainterReloadFromNetEvent) {
      if (inBookView && tData.contentIsNotEmpty) {
        loadPN(tData.pid!, tData.cid!, tData.nid!, bookid!, update: true);
      }
    } else if (event is PainterMetricsChangeEvent) {
      if (sizeChanged) {
        reset(clearCache: true);
        sizeChanged = false;
        yield painter(ignore: true);
        if (!completer.isCompleted) {
          inBookView = false;
          await completer.future;
          inBookView = true;
        }
        await loadFirst();
        yield painter();
      }
    }
  }

  Stream<PainterState> goPre() async* {
    final _pid = tData.pid;
    if (_pid == null) return;
    final _cid = tData.cid;
    final _nid = tData.nid;
    final _bookid = bookid!;
    yield painter(loading: true);
    await Future.delayed(Duration(milliseconds: 100));
    if (!cache.containsKey(tData.pid)) {
      await completer.future;
      loadPN(_pid, _cid!, _nid!, _bookid);
      if (!cache.containsKey(tData.pid)) {
        yield painter();
        return;
      }
    }
    if (canCompute != null && !canCompute!.isCompleted) {
      await canCompute!.future;
    }
    tData = cache[tData.pid] ?? TextData();
    currentPage = 1;
    if (controller != null) {
      controller!.setPixelsWithoutNtf(0.0);
    }
    virtualIndex = 0;

    yield painter();
    loadPNCb();
    bookIndexBloc.add(BookIndexShowEvent(id: bookid, cid: tData.cid));
  }

  Stream<PainterState> goNext() async* {
//     var client = HttpClient();
// client.getUrl(Uri.parse("http://www.example.com/"))
//     .then((HttpClientRequest request) {
//       // Optionally set up headers...
//       // Optionally write to the request object...
//       return request.close();
//     })
//     .then((HttpClientResponse response) {
//       // Process the response.
//       response.transform(utf8.decoder);
//     });
    final _nid = tData.nid;
    if (_nid == null) return;
    final _pid = tData.pid;
    final _cid = tData.cid;
    final _bookid = bookid!;
    yield painter(loading: true);
    await Future.delayed(Duration(milliseconds: 100));
    if (!cache.containsKey(tData.nid)) {
      await completer.future;
      loadPN(_pid!, _cid!, _nid, _bookid);
      if (!cache.containsKey(tData.nid)) {
        yield painter();
        return;
      }
    }
    if (canCompute != null && !canCompute!.isCompleted) {
      await canCompute!.future;
    }
    tData = cache[tData.nid] ?? TextData();
    currentPage = 1;
    if (controller != null) {
      controller!.setPixelsWithoutNtf(0.0);
    }
    virtualIndex = 0;

    yield painter();
    bookIndexBloc.add(BookIndexShowEvent(id: bookid, cid: tData.cid));
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

    if (flush) {
      reset(clearCache: true);
      yield painter(loading: true, ignore: true);
      await Future.delayed(Duration(milliseconds: 100));
      yield painter(ignore: true);
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
    final _bgcolor = box.get('bgcolor') ?? 4288787622;
    final _fontColor = box.get('fontColor') ?? 4283716948;
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
  }

  void reset({bool clearCache = false}) {
    loadingId.clear();

    /// 重置对象引用
    ///
    /// [cid]... 存储在[TextData]对象中，
    /// 在接下的步骤中可能会更改 cid,以重新加载数据，
    /// 如果没有新建实例，[tData] 的更改也会是[cache] 改变，
    /// [tData] 和 [cache] 中都有一个引用
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
  bool inBookView = false;
  NopPageViewController? controller;
  Stream<PainterState> newBook(PainterNotifyIdEvent event) async* {
    inBookView = true;
    if (event.id == null || event.cid == -1) return;
    if (config.bgcolor == null) {
      await getPrefs();
    }
    if (controller != null) {
      controller!.setPixelsWithoutNtf(0.0);
    }
    virtualIndex = 0;
    if (tData.cid == null || tData.cid != event.cid || sizeChanged) {
      assert(Log.i('page: ${event.page}', stage: this, name: 'newBook'));
      final clear = bookid != event.id || sizeChanged;

      /// 等待[load](异步)执行完成
      /// 避免数据竞争
      currentPage = event.page;
      tData.cid = event.cid;
      reset(clearCache: clear);
      sizeChanged = false;
      bookid = event.id;

      /// 文本已清空，页面显示空白
      yield painter(ignore: true, loading: true);

      await completer.future;

      await canLoad?.future;
      // yield painter(ignore: true);

      computeCount++;
      loadFirst();
      await completer.future;
      computeCount--;
      yield painter();
      if (config.axis == Axis.vertical) {
        resetController();
      }
    }
  }

  /// 持久化本地
  void memoryToDatabase() {
    if (memoryCache.isEmpty) return;
    final _map = Map.of(memoryCache);
    memoryCache.clear();
    _map.forEach((key, bookContent) async {
      assert(key == bookContent.cid ||
          Log.e('key: $key, bookContent: ${bookContent.cid}', stage: this, name: 'memoryToDatabase'));
      int? count = 0;
      count = Sqflite.firstIntValue(await repository.db
          .rawQuery('SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?', [bookContent.id, bookContent.cid]));
      if (count! > 0) {
        await repository.db.rawUpdate(
            'UPDATE BookContent SET pid = ?, nid = ?, hasContent = ?,content = ? WHERE bookId = ? AND cid = ?', [
          bookContent.pid,
          bookContent.nid,
          bookContent.hasContent,
          bookContent.content,
          bookContent.id,
          bookContent.cid
        ]);
        return;
      }
      await repository.db.rawInsert(
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
    });
  }

  Future<void> awaitCompute(FutureOr<void> Function() call) async {
    if (canCompute != null && !canCompute!.isCompleted) {
      Log.i('awaiting >>', stage: this, name: 'awaitCompute');
      await canCompute!.future;
    }
    if (!inBookView) return;

    computeCount += 1;
    await call();
    computeCount -= 1;
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
      memoryCache[bookContent.cid!] = bookContent;
      await loadFromMemory(contentid, _bookid);
      memoryToDatabase();
    }
  }

  // return: 可能为空
  Future<TextData?> loadData(int _contentid, int _bookid) async {
    TextData? result = TextData();
    var contain = false;
    void cacheReturn(int? _contentid) {
      if (cache.containsKey(_contentid)) {
        result = cache[_contentid];
        contain = true;
        return;
      }
      contain = false;
    }

    /// 1
    /// cache
    cacheReturn(_contentid);
    if (contain) return result;

    /// 2
    /// 从 memoryCache 中 加载
    await loadFromMemory(_contentid, _bookid);
    cacheReturn(_contentid);
    if (contain) return result;

    /// 3
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

      /// 存在[tData] 为空的可能，[newBook]触发，
      if (_tData != null && cache.containsKey(_tData.cid)) {
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
    cache[_cnpid.cid!] = _cnpid;
  }

  Future<void> loadFromDb(int contentid, int _bookid) async {
    var queryList = await repository.db.rawQuery(
        'SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [_bookid, contentid]);
    if (queryList.isNotEmpty) {
      final map = queryList.first;
      if (map.contentIsNotEmpty) {
        if (map['hasContent'] != 1 || map['pid'] == -1 || map['nid'] == -1) {
          await downFromNet(contentid, _bookid);
        } else {
          assert(Log.i('url: ${BookRepository.contentUrl(_bookid, contentid)}', stage: this, name: 'loadFromDb'));
          await awaitCompute(() async {
            if (_bookid != bookid) return;
            final list = await divText(map['content'] as String, size!, config, map['cname'] as String);
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
        }
      }
    }
  }

  Future<void> loadFromMemory(int contentid, int _bookid) async {
    if (memoryCache.containsKey(contentid) && bookid == _bookid) {
      final map = memoryCache[contentid];
      await awaitCompute(() async {
        if (_bookid != bookid) return;
        final list = await divText(map!.content!, size!, config, map.cname!);
        assert(list.isNotEmpty);
        final _cnpid = TextData(content: list, nid: map.nid, pid: map.pid, cid: map.cid, cname: map.cname);
        cacheGbg(_cnpid);
      });
    }
  }

  PainterState painter({bool loading = false, bool ignore = false}) {
    final result = PainterState(
      config: config,
      ignore: ignore,
      loading: loading,
      empty: tData.isNotEmpty,
    );
    return result;
  }

  /// 首次（重置）加载
  Future<void> loadFirst() async {
    final _bookid = bookid!;
    final _cid = tData.cid!;
    Log.i('loadFirst: computeCount: $computeCount', stage: this, name: 'loadFirst');
    await load(() async {
      assert(Log.i('cid: $_cid', stage: this, name: 'loadFirst'));
      final _currentText = await loadData(_cid, _bookid);
      if (_bookid == bookid && _cid == _currentText!.cid) {
        tData = _currentText;
      }
    });
    if (bookid == _bookid && tData.contentIsNotEmpty && _cid == tData.cid) {
      if (currentPage! > tData.content!.length) {
        currentPage = tData.content!.length;
      }
    }
  }

  /// [loadFirst]
  /// [loadPN]
  /// 数据加载状态:[completer]
  /// 当频繁地进行页面切换时，已进行了相关优化；
  /// 在退出页面时，没有绝对的等待[completer]的完成，
  /// 即在[completer]没有完成时，再次进入页面[newBook]，
  /// 会修改数据，[cache],[bookid],[tData]
  int loadCount = 0;
  Future<void> load(Future<void> Function() callback) async {
    if (loadCount != 0) return;
    if (completer.isCompleted) {
      completer = Completer<Status>();
      loadCount += 1;
      print('load: start >');
    } else {
      return;
    }
    await callback();
    loadCount -= 1;
    print('load: done  <\n——————————————————————');
    completerResolve(tData.contentIsNotEmpty && cache.containsKey(tData.nid) && cache.containsKey(tData.pid)
        ? Status.done
        : Status.error);
  }

  final resolveFromNet = <int?>[];

  // /// pid/nid == -1的解决方案
  Future<void> reloadFromNet(int _cid, int _bookid) async {
    Log.w('重新下载： 当前章节是否为第一章或最后一张,$_cid', stage: this, name: 'reloadFromNet');
    await downFromNet(_cid, _bookid);
    final result = cache[_cid] ?? TextData();
    await awaitCompute(() async {
      if (_bookid == bookid && tData.cid == _cid && result.contentIsNotEmpty) {
        tData = result;
        if (currentPage! > tData.content!.length) {
          currentPage = tData.content!.length;
        }
        add(_PainterInnerEvent());
        await Future.delayed(Duration(milliseconds: 100));
      }
    });
  }

  /// 异步 调用
  Future<void> loadPN(int _pid, int _cid, int _nid, int _bookid, {bool update = false}) async {
    await load(() async {
      if (_nid == -1 || _pid == -1 || update) {
        if (update) {
          resolveFromNet.remove(_cid);
        }
        if (!resolveFromNet.contains(_cid)) {
          resolveFromNet.add(_cid);
          nexttime = DateTime.now().millisecondsSinceEpoch;
          await reloadFromNet(_cid, _bookid);
          if (_bookid == bookid && _cid == tData.cid) {
            _nid = tData.nid!;
            _pid = tData.pid!;
          }
        }
      }
      // 进行异步任务时，需要检查是否要退出，以免等待过长时间。
      if (!inBookView) return;
      if (!cache.containsKey(_nid) && _nid != -1) {
        await loadData(_nid, _bookid);
      }
      if (!inBookView) return;
      if (!cache.containsKey(_pid) && _pid != -1) {
        await loadData(_pid, _bookid);
      }
    });
  }

  Future<void> deleteCache(int bookId) async {
    await repository.db.rawDelete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  int nexttime = 0;
  Future<void> loadPNCb() async {
    if (inBookView) {
      if (tData.nid == -1 || tData.pid == -1) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (nexttime + 1000 * 180 <= now) {
          nexttime = now;
          resolveFromNet.remove(tData.cid);
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
      fontFamily: 'NotoSansSC',
    );
  }

  bool delayed = false;
  bool hasContent(int key, int index) {
    assert(tData.contentIsNotEmpty);
    final exPage = index - virtualIndex;
    var result = true;
    if (key == 0) {
      result = currentPage! + exPage < tData.content!.length || cache.containsKey(tData.nid);
    } else {
      result = currentPage! + exPage > 1 || cache.containsKey(tData.pid);
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

  int virtualIndex = 0;
  late TextStyle style;
  late TextStyle secstyle;

  Widget? getWidget(int page, {bool changeState = false}) {
    if (changeState && page == virtualIndex) return null;
    var currentContentFirstIndex = virtualIndex - currentPage! + 1;
    TextData? text = tData;
    Widget? child;
    while (text != null && text.contentIsNotEmpty) {
      final tol = page - currentContentFirstIndex;
      final length = text.content!.length;
      if (tol >= 0 && tol <= length - 1) {
        virtualIndex = page;
        currentPage = tol + 1;
        if (!changeState) {
          child = ContentView(
            pic: text.content![currentPage! - 1],
            secstyle: secstyle,
            style: style,
            isHorizontal: config.axis == Axis.horizontal,
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

  Completer<void>? canCompute;
  int computeCount = 0;
  static const topPad = 8.0;
  static const padding = 12.0;
  static const botPad = 4.0;
  final reg = RegExp('\u0009|\u000B|\u000C|\u000D|\u0020|'
      '\u00A0|\u1680|\uFEFF|\u205F|\u202F|\u2028|\u2000|\u2001|\u2002|'
      '\u2003|\u2004|\u2005|\u2006|\u2007|\u2008|\u2009|\u200A+');

  Future<List<ui.Picture>> divText(String text, Size size, ContentViewConfig config, String cname) async {
    assert(text.isNotEmpty);
    final leftPadding = (size.width % style.fontSize!) / 2;
    final left = 16.0 + leftPadding;
    final pages = <List<String>>[];

    print('working   >>>');
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
      ..layout(maxWidth: size.width);
    final _cPainter = TextPainter(
        text: TextSpan(
            text: cname, style: TextStyle(fontSize: 22, color: Color(config.fontColor!), fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width);
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
    final otherHeight = padding * 2 + topPad + botPad + 26;
    final contentHeight = (size.height - otherHeight) / config.lineBwHeight!;
    for (var mcs in lineMcs) {
      final end = _textPainter.getPositionForOffset(Offset(_textPainter.width, hx));
      hx += mcs.height;
      if (hx > contentHeight * lineCount - ex) {
        hx -= mcs.height;
        ex = contentHeight * lineCount - hx;
        lineCount += 1;
        pages.add(page);
        page = <String>[];
        final l = _text.substring(start, end.offset).replaceAll('\n', '');
        if (l.isEmpty) {
          // 文本为空，但是逻辑中还是占用着空间，所以要移到[ex](额外空间)
          ex += mcs.height;
        } else {
          page.add(l);
        }
        hx += mcs.height;
      } else {
        page.add(_text.substring(start, end.offset).replaceAll('\n', ''));
      }
      start = end.offset;
    }
    // 到最后，我们还有一页没处理
    // 处理最后一行空白的情况
    page.removeWhere((element) {
      return element.replaceAll(RegExp(' |\u3000+'), '').isEmpty;
    });
    if (page.isNotEmpty) {
      pages.add(page);
    }
    print('div : ${(Timeline.now - nowx) / 1000}ms');
    // end: div string--------------------------------------

    /// pictures -------------------------------------------
    final pics = <ui.Picture>[];

    /// 最后一页行数可能不会占满，因此保留上一个额外高度[exh]
    var lastPageExh = 0.0;
    for (var r = 0; r < pages.length; r++) {
      var exh = 0.0;
      var h = 0.0;
      final recoder = ui.PictureRecorder();
      final canvas = ui.Canvas(recoder);
      late TextPainter cnamePainter;
      late TextPainter bottomRight;
      late double right;

      /// layout
      final isHorizontal = config.axis == Axis.horizontal;
      if (isHorizontal) {
        cnamePainter = TextPainter(text: TextSpan(text: cname, style: secstyle), textDirection: TextDirection.ltr)
          ..layout(maxWidth: size.width);
        bottomRight = TextPainter(
            text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle), textDirection: TextDirection.ltr)
          ..layout(maxWidth: size.width);
        right = size.width - bottomRight.width - leftPadding * 2;
      }

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
        exh = (size.height - otherHeight) / lineCounts - style.fontSize!;
        lastPageExh = exh;
      }

      canvas.save();
      canvas.translate(left, 0.0);

      if (isHorizontal) {
        h += topPad;
        cnamePainter.paint(canvas, Offset(0.0, h));
        h += 13.0;
      }
      if (r == 0) {
        if (!isHorizontal) {
          h -= padding;
        }
        h += (style.fontSize! + exh) * (topHeight + 3);
        _cPainter.paint(canvas, Offset(0.0, h - _cPainter.height));
        if (!isHorizontal) {
          h += padding;
        }
      }
      // canvas.drawRect(
      // Offset(0.0, h) & Size(size.width, padding + exh / 2), Paint()..color = Colors.black.withAlpha(100));
      if (isHorizontal) {
        h += padding;
      }
      h += exh / 2;
      for (var l in pages[r]) {
        final _tep = TextPainter(
          text: TextSpan(text: l, style: style),
          textDirection: TextDirection.ltr,
          // strutStyle: StrutStyle(height: (ax / style.fontSize + config.lineBwHeight - 1))
        )
          ..layout(maxWidth: size.width)
          ..paint(canvas, Offset(0.0, h));
        // canvas.drawRect(Offset(0.0, h) & Size(_tep.width, _tep.height), Paint()..color = Colors.black.withAlpha(100));
        h += _tep.height + exh;
      }
      // canvas.drawRect(
      //     Offset(0.0, h - exh) & Size(size.width, padding + exh / 2), Paint()..color = Colors.black.withAlpha(100));
      if (isHorizontal) {
        bottomRight.paint(canvas, Offset(right, size.height - bottomRight.height - botPad));
      }

      canvas.restore();
      pics.add(recoder.endRecording());
    }

    print('用时: ${((Timeline.now - now) / 1000).toStringAsFixed(1)}ms');
    print('work done <<<');

    return pics;
  }
}

class ContentView extends LeafRenderObjectWidget {
  ContentView({this.pic, this.secstyle, this.style, this.isHorizontal = true});

  final TextStyle? secstyle;
  final TextStyle? style;
  final ui.Picture? pic;
  final bool isHorizontal;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContentView(
      pic: pic,
      style: style,
      secstyle: secstyle,
      isHorizontal: isHorizontal,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderContentView renderObject) {
    renderObject
      ..pic = pic
      ..style = style
      ..isHorizontal = isHorizontal
      ..secstyle = secstyle;
  }
}

class RenderContentView extends RenderBox {
  RenderContentView({ui.Picture? pic, TextStyle? secstyle, TextStyle? style, bool? isHorizontal})
      : _pic = pic,
        _secstyle = secstyle,
        _style = style,
        _isHorizontal = isHorizontal {
    bottomLeft = TextPainter(text: TextSpan(), textDirection: TextDirection.ltr);
  }
  late TextPainter bottomLeft;
  bool? _isHorizontal;
  bool? get isHorizontal => _isHorizontal;
  set isHorizontal(bool? v) {
    if (_isHorizontal == v) return;
    _isHorizontal = v;
    markNeedsLayout();
  }

  TextStyle? _secstyle;
  TextStyle? get secstyle => _secstyle;
  set secstyle(TextStyle? v) {
    if (_secstyle == v) return;
    _secstyle = v;
    markNeedsLayout();
  }

  TextStyle? _style;
  TextStyle? get style => _style;
  set style(TextStyle? v) {
    if (_style == v) return;
    _style = v;
    markNeedsPaint();
  }

  ui.Picture? _pic;
  ui.Picture? get pic => _pic;
  set pic(ui.Picture? v) {
    if (v == _pic) return;
    _pic = v;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (isHorizontal!) {
      final time = DateTime.now();
      bottomLeft.text = TextSpan(text: '${time.hour.timePadLeft}:${time.minute.timePadLeft}', style: secstyle);
      bottomLeft.layout(maxWidth: size.width);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final leftPadding = ((size.width - 32) % style!.fontSize!) / 2;
    // final right = size.width - bottomRight.width + leftPadding;

    context.canvas.drawPicture(pic!);
    if (isHorizontal!) {
      bottomLeft.paint(context.canvas, Offset(leftPadding + 16.0, size.height - bottomLeft.height - 4.0));
    }
    // bottomRight.paint(context.canvas, Offset(right, size.height - bottomRight.height - 4.0));
    canvas.restore();
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;
}
