import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';

import '../database/database.dart';
import '../event/event.dart';
import '../pages/book_content_view/widgets/page_view_controller.dart';
import '../utils/utils.dart';
import 'book_index_notifier.dart';
import 'constansts.dart';

enum Status { ignore, error, done }

class TextData {
  TextData(
      {List<ContentMetrics> content = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      bool? hasContent})
      : _content = content,
        _hasContent = hasContent;
  List<ContentMetrics> get content => _content;
  final List<ContentMetrics> _content;
  int? cid;
  int? pid;
  int? nid;
  String? cname;
  final bool? _hasContent;
  bool get hasContent => _hasContent ?? false;
  bool get isEmpty =>
      content.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      _hasContent == null;

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
  int get hashCode => hashValues(cid, pid, nid, content, cname, hasContent);

  @override
  String toString() {
    return 'cid: $cid, pid: $pid, nid: $nid, cname: $cname';
  }
}

class ContentNotifier extends ChangeNotifier {
  ContentNotifier({
    required this.repository,
    // required this.indexBloc
  });

  final Repository repository;
  // final BookIndexNotifier indexBloc;

  int? bookid;
  int currentPage = 1;
  int _innerIndex = 0;

  final config = ValueNotifier<ContentViewConfig>(ContentViewConfig());
  // 同步----
  Future? _metricsF;
  Future? _newF;
  Future? get enter => _newF;
  Future? _loadF;
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
  var safeBottom = 6.0;

  TextStyle _getStyle(ContentViewConfig config) {
    return TextStyle(
      locale: const Locale('zh', 'CN'),
      fontSize: config.fontSize,
      color: config.fontColor!,
      height: 1.0,
      // leadingDistribution: TextLeadingDistribution.even,
      fontFamily: 'NotoSansSC', // SourceHanSansSC
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
    updateCaches(data);
    _tData = data;
  }

  final _eventLooper = EventLooper.instance;

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

  void _notify() {
    notifyState(
        //                        notEmpty        ||  ignore
        notEmptyOrIgnore: tData.contentIsNotEmpty || !inBook,
        loading: false);
    notifyListeners();
  }
}

extension ContentStatus on ContentNotifier {
  void out() {
    _inBookView = false;
  }

  bool get inBook => _inBookView;
  void inbook() {
    _inBookView = true;
  }

  // _innerIndex == page == 0
  void resetController() {
    controller?.goIdle();
    _innerIndex = 0;
    controller?.setPixelsWithoutNtf(0.0);
  }
}

extension DataLoading on ContentNotifier {
  Future<void> reset({bool clearCache = false, int? cid}) async {
    if (clearCache) {
      _caches.clear();

      if (_futures.isNotEmpty) {
        final _tasks = List.of(_futures.values);

        _disposeFutures.addAll(_tasks);
        await Future.wait(_disposeFutures);
      }

      _caches.clear();
    }
    _getCurrentIds();

    _tData = TextData()..cid = cid ?? tData.cid;
  }

  Future<void> dump() async {
    final cid = tData.cid;
    final _bookid = bookid;
    if (_bookid == null || cid == null) return;
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
      _caches.removeWhere((key, data) {
        final remove = !_keys.contains(key);
        if (remove) data._content.forEach((p) => p.picture.dispose());
        return remove;
      });
    }
  }

  Future<void> loadData(int _contentKey, int _bookid) async {
    if (_caches.containsKey(_contentKey)) return;
    await load(_bookid, _contentKey);
  }

  Future<void> load(int _bookid, int contentid, {bool update = false}) async {
    if (_ignoreTask(contentid, update: update)) return;

    final lines =
        await repository.bookEvent.getContent(_bookid, contentid, update);

    if (lines != null && lines.contentIsNotEmpty) {
      _eventLooper.currentTask?.ident = contentid;
      final pages = await _asyncLayout(lines.pages, lines.cname!);

      if (pages.isEmpty || _ignoreTask(contentid, update: update)) return;
      final _cnpid = TextData(
        content: pages,
        nid: lines.nid,
        pid: lines.pid,
        cid: lines.cid,
        hasContent: lines.hasContent,
        cname: lines.cname,
      );

      addCache(_cnpid);
    }
  }
}

extension Tasks on ContentNotifier {
  /// 任务逻辑----------------
  /// 首次（重置）加载
  Future<void> _loadFirst() async {
    if (tData.cid == null || bookid == null) return;
    final _bookid = bookid!;
    final _key = tData.cid!;
    assert(Log.i(
      'cid: $_key',
    ));
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
        contentid != null &&
        contentid != -1 &&
        !_caches.containsKey(contentid) &&
        !_futures.isLoading(contentid)) {
      final _ntask =
          _eventLooper.addEventTask(() => loadData(contentid, _bookid));

      _futures.addTask(contentid, _ntask, solve: _ignoreTask);
    }
  }

  void _loadWithId(int? id) => _loadTasks(bookid!, id);

  void unDelayedLoad() => _loadCallback();

  void _loadCallback() {
    if (_scheduled) return;
    scheduleMicrotask(() {
      _scheduled = false;
      _loadResolve();
      _loadAuto();
    });
    _scheduled = true;
  }

  void _loadAuto() => _getCurrentIds()
      .where((e) => !_caches.containsKey(e))
      .forEach(_loadWithId);

  // 处于最后一章节时，查看是否有更新
  Future<void> _loadResolve() async {
    if (tData.nid == -1 || !tData.hasContent) {
      if (tData.contentIsEmpty) return;

      void _getdata() {
        if (_caches.containsKey(tData.cid)) {
          if (tData.contentIsNotEmpty &&
              (currentPage == tData.content.length || currentPage == 1)) {
            tData = _getTextData(tData.cid!)!;
            if (currentPage > tData.content.length) {
              currentPage = tData.content.length;
            }
            _notify();
          }
        }
      }

      final cid = tData.cid!;
      final _data = _caches[cid];

      if (_data != null &&
          _data.contentIsNotEmpty &&
          tData.nid != -1 &&
          tData.hasContent) {
        // 已经重新加载到 caches 了
        _getdata();
        return;
      }

      if (_reloadIds.contains(cid)) return;
      assert(Log.w('nid = ${tData.nid}, hasContent: ${tData.hasContent}'));

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
    if (_data != null && (!_data.hasContent || _data.nid == -1)) {
      await _reload();
    }
  }

  Future<void> _reload() async {
    await load(bookid!, tData.cid!, update: true);
    final _data = _getTextData(tData.cid);
    if (_data != null && _data.contentIsNotEmpty) {
      tData = _data;
    }
    if (currentPage > tData.content.length) {
      currentPage = tData.content.length;
    }
  }

  Future _delayedLoad() async {
    if (inBook) {
      await _loadF;
      _loadF ??= Future.delayed(const Duration(seconds: 1), _loadCallback)
        ..whenComplete(() => _loadF = null);
    }
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

  bool _ignoreTask(int contentid, {bool update = false}) {
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

    if (nnid != null) {
      final thirty = _getTextData(nnid);
      _ids
        ..add(nnid)
        ..add(thirty?.nid);
    }

    final pre = _getTextData(pid);
    final prePid = pre?.pid;

    if (prePid != null) _ids.add(prePid);

    return _ids.whereType<int>();
  }

  // void _waitFor() async {
  //   final ident = _eventLooper.currentTask?.ident;
  //   if (tData.contentIsEmpty ||
  //       _willGoF != null ||
  //       !inBook ||
  //       autoRun.value ||
  //       ident != null &&
  //           (_contains(ident, tData.nid) || _contains(ident, tData.pid))) {
  //     if (loading.value) notifyState(loading: false);
  //     _eventLooper.async = false;
  //   }
  // }

  // bool _contains(Object? ident, int? id) {
  //   return ident == id && !_caches.containsKey(id);
  // }

  // Future<void> get wait => _eventLooper.wait(_waitFor);
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

    // 大标题
    late final TextPainter _bigTitlePainter;
    // 小标题
    late final TextPainter smallTitlePainter;

    await wait;

    _bigTitlePainter = TextPainter(
        text: TextSpan(
            text: cname,
            style: style.copyWith(
                fontSize: 22, height: 1.2, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);

    await wait;

    smallTitlePainter = TextPainter(
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

          await wait;

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
                print('no: $_s |$start, ${pc.length}');
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

      dpaint(canvas,
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
        picture: picture,
        secstyle: secstyle,
        left: left,
        size: _size,
      );
      textPages.add(met);
    }

    return textPages;
  }

// 返回 一组数据：整体绘制区域，每一行的坐标，矩形面积，每一行的文本内容，
  void dpaint(Canvas canvas,
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
      required double topExtraHeight}) {
    final _size = size;
    final _windowTopPadding = isHorizontal ? windowTopPadding : 0.0;

    var h = 0.0;
    canvas.save();
    canvas.translate(left, _windowTopPadding);
    if (isHorizontal) {
      h += contentTopPad;
      titlePainter.paint(canvas, Offset(0.0, h));
      h += titlePainter.height;
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
          Offset(right, _size.height - bottomRight.height - contentBotttomPad));
    }
    canvas.restore();
  }
}

extension Event on ContentNotifier {
  Future<void> showdow() async {
    showrect = !showrect;
    await reset(clearCache: true);

    await _newF;

    await _loadFirst();
    _notify();
  }

  Future<void> newBookOrCid(int newBookid, int cid, int page,
      {bool inBook = false}) async {
    await enter;
    _newF ??= _newBookOrCid(newBookid, cid, page, inBook)
      ..whenComplete(() {
        Log.w('complete');
        return _newF = null;
      });
  }

  Future<bool> setNewBookOrCid(int newBookid, int cid, int page) async {
    if (!inBook) resetController();

    if (tData.cid != cid || bookid != newBookid) {
      assert(Log.i('new: $newBookid $cid'));
      footer.value = '';
      header.value = '';
      notifyState(notEmptyOrIgnore: true, loading: false);

      final diff = bookid != newBookid;

      await reset(clearCache: diff, cid: cid);
      currentPage = page;
      bookid = newBookid;

      await dump();
      return true;
    }
    return false;
  }

  Future<void> _newBookOrCid(
      int newBookid, int cid, int page, bool inBook) async {
    if (cid == -1) return;

    autoRun.stopTicked();

    orientation(config.value.portrait!);

    await setNewBookOrCid(newBookid, cid, page);

    if (tData.contentIsEmpty) {
      notifyState(notEmptyOrIgnore: true);

      _getCurrentIds();

      final _t = Timer(
          const Duration(milliseconds: 300), () => notifyState(loading: true));

      inbook();
      await _loadFirst();

      _t.cancel();

      resetController();
    }

    // indexBloc.loadIndexs(bookid, tData.cid);

    inbook();

    await _metricsF;

    _notify();

    uiStyle(dark: false);
  }

  Future<void> metricsChange() async {
    await _metricsF;
    _metricsF ??= _metricsChange()..whenComplete(() => _metricsF = null);
  }

  Future<void> _metricsChange() async {
    // 实时
    final changed = await _modifiedSize();
    if (changed) {
      _notify();
      notifyState(notEmptyOrIgnore: true);
      if (inBook && tData.cid != null && bookid != null) {
        autoRun.stopTicked();

        await reset(clearCache: true);

        await _loadFirst();
        _notify();
      }
    }
  }

  Future<void> reload() async {
    notifyState(loading: true, notEmptyOrIgnore: true);

    await _newF;

    await _loadFirst();

    _notify();
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
    if (tData.contentIsEmpty) return;

    autoRun.stopTicked();
    final timer = Timer(const Duration(milliseconds: 100), () {
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
  }

  Future<bool> _modifiedSize() async {
    final w = ui.window;
    var _size = w.physicalSize / w.devicePixelRatio;
    var _p = EdgeInsets.fromWindowPadding(w.padding, w.devicePixelRatio);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final _sizeOut = (await repository.getViewInsets).size;

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
        if ((_p.top == 0.0 && safePadding.top != _p.top) ||
            size.height < _size.height ||
            size.width != _size.width) {
          size = _size;
          safePadding = _p;
          paddingRect = safePadding.copyWith(
              bottom: _p.bottom != 0.0 ? 10.0 : 0.0, left: 16.0, right: 16.0);

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
}

extension ContentGetter on ContentNotifier {
  int hasContent() {
    var _r = 0;
    if (tData.contentIsNotEmpty) {
      final hasRight = hasNext();
      final hasLeft = hasPre();

      if (hasRight) _r |= ContentBounds.addRight;
      if (hasLeft) _r |= ContentBounds.addLeft;
    } else {
      return ContentBounds.notLeftAndRight;
    }

    _delayedLoad();

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
          _loadCallback();
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
    final _portrait = _config.portrait!;

    if (_fontSize != config.value.fontSize ||
        _fontFamily != config.value.fontFamily ||
        _fontColor != config.value.fontColor ||
        _height != config.value.lineTweenHeight ||
        _axis != config.value.axis) {
      flush = true;
    }
    final portrait = config.value.portrait;
    var resetToZero = _axis != config.value.axis;

    config.value = _config;

    if (_portrait != portrait) {
      await orientation(_portrait);
      resetToZero = true;
      flush = true;
    }

    if (flush) {
      autoRun.stopTicked();

      await reset(clearCache: true);

      await _loadFirst();

      if (resetToZero ||
          currentPage == tData.content.length ||
          currentPage == 1) resetController();
    }
    await _metricsF?.whenComplete(resetController);
    _notify();
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
      final _p = await box.get('patternList');
      final _portrait = await box.get('portrait');
      final _autoValue = await box.get('autoValue');

      if (_bgcolor != _config.bgcolor)
        await box.put('bgcolor', _config.bgcolor);
      if (_fontColor != _config.fontColor)
        await box.put('fontColor', _config.fontColor);
      if (axis != _config.axis) await box.put('axis', _config.axis);
      if (_p != _config.patternList)
        await box.put('patternList', _config.patternList);
      if (_portrait != _config.portrait)
        await box.put('portrait', _config.portrait);
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
      _loadCallback();
      _autoF ??= _eventLooper.scheduler.endOfFrame.then((_) => autoRun.start())
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

    var millisecond =
        math.max(1, _e.inMicroseconds / Duration.microsecondsPerMillisecond);

    controller!.setPixels(_start + autoValue.value / millisecond);
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
  final ui.Picture picture;
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
  set value(bool v) {
    isActive.value = v;
  }

  Ticker? _ticker;
  void start() {
    _ticker?.dispose();
    isActive.value = true;
    _ticker = Ticker(onTick, debugLabel: 'autoRun')..start();
  }

  void stopTicked() {
    _ticker?.dispose();
    reset();
    isActive.value = false;
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
      {void Function()? callback, void Function(T)? solve}) {
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
