import 'dart:async';

import 'package:flutter/Material.dart';
import 'package:flutter/foundation.dart';
import 'package:nop/nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../import.dart';
import '../../text_data.dart';
import 'content_auto.dart';
import 'content_base.dart';
import 'content_config.dart';
import 'content_getter.dart';
import 'content_status.dart';

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
      return startFirstEvent(clear: true);
    }
  }

  Future<void> updateCurrent() => reload().whenComplete(notify);

  /// 进入阅读页面前，必须调用的方法
  Future<void> touchBook(int newBookId, int cid, int page,
      {ApiType api = ApiType.biquge}) async {
    if (!inBook) resetController();

    if (!config.value.orientation!) {
      uiOverlay();
      uiStyle(dark: true);
    }
    await setOrientation(config.value.orientation!);

    setInBook();
    newBookOrCid(newBookId, cid, page, api: api);
  }


  void updateBook(int newBookId, int cid, int page,
      {ApiType api = ApiType.biquge}) {
    if (shouldUpdate(newBookId, cid, api) || currentPage != page) {
      tData.dispose();
      resetData(TextData(cid: cid, api: api));
      this.api = api;
      currentPage = page;
      bookId = newBookId;
      notify();
      notifyState(notEmptyOrIgnore: true, loading: false);
    }
  }

  var _inTask = false;
  bool get inTask => _inTask;

  /// 当前章节
  ///
  /// 加载、重载、设置更改等操作需要更新[tData]要调用的函数
  /// 每一次调用对会添加一次到队列中
  ///
  /// [only]: 本次任务是否可被抛弃
  @override
  Future<void> startFirstEvent({
    bool clear = true,
    bool only = true,
    FutureOr<void> Function()? onStart,
    void Function()? onDone,
  }) {
    didChangeKey();

    void event() async {
      _inTask = true;
      autoRun.stopSave();
      if (clear) reset();

      await onStart?.call();
      final _key = key;

      final localBookId = bookId;
      final localCid = tData.cid;
      if (localCid != null) {
        loadTasks(localBookId, localCid);

        try {
          await awaitKey(localCid);
        } catch (_) {}

        final currentText = getTextData(localCid);
        if (localBookId == bookId &&
            currentText != null &&
            currentText.contentIsNotEmpty &&
            localCid == currentText.cid) {
          tData = currentText;

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

      if (_key == key) notify();

      scheduleMicrotask(autoRun.stopAutoRun);
      Timer.run(scheduleTask);
      _inTask = false;
    }

    return only ? event.pushOneAwait(initQueue) : event.pushAwait(initQueue);
  }

  /// 由滚动状态调用
  /// 只有在渲染后才能更改[innerIndex][controller.pixels]
  // void reduceController() {
  // if (innerIndex.abs() > 100) {
  //   EventQueue.runOne(_reduce, () {
  //     if (innerIndex.abs() > 10) {
  //       assert(Log.w('lenght: $innerIndex'));
  //       return SchedulerBinding.instance!.endOfFrame.whenComplete(_reduce);
  //     }
  //   });
  // }
  // }

  // void _reduce() {
  // if (controller?.isScrolling == false) {
  //   shrinkIndex();
  //   notify();
  // }
  // }

  @override
  Future<void> newBookOrCid(int newBookId, int cid, int page,
      {ApiType api = ApiType.biquge}) async {
    if (!inBook) return;

    if (cid == -1) return;
    final clear = bookId != newBookId;
    if (clear) {
      footer.value = '';
      header.value = '';
    }
    final _reset = shouldUpdate(newBookId, cid, api);

    if (_reset) {
      final _t = Timer(
          const Duration(milliseconds: 600), () => notifyState(loading: true));

      await startFirstEvent(
          only: false,
          clear: clear,
          onStart: () => updateBook(newBookId, cid, page, api: api),
          onDone: resetController);

      _t.cancel();
    }
  }

  Future<void> reload() {
    notifyState(loading: true, notEmptyOrIgnore: true);
    return startFirstEvent(clear: false);
  }

  Future<void> goNext() {
    return EventQueue.runOne(
        _willGoPreOrNext, () => _willGoPreOrNext(preEvent: false));
  }

  Future<void> goPre() {
    return EventQueue.runOne(
        _willGoPreOrNext, () => _willGoPreOrNext(preEvent: true));
  }

  Future<void> _willGoPreOrNext({bool preEvent = false}) async {
    if (tData.contentIsEmpty || initQueue.actived) return;
    notifyState(error: NotifyMessage.hide);

    autoRun.stopSave();
    final timer = Timer(const Duration(milliseconds: 500), () {
      notifyState(loading: true);
    });

    var getId = -1;

    if (preEvent) {
      getId = tData.pid!;
    } else {
      await resolveId();
      getId = tData.nid!;
      if (getId == -1)
        notifyState(loading: false, error: NotifyMessage.noNextError);
    }

    if (getId != -1) {
      final success = await getContent(getId);
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

    var _pannelPadding = _p;
    var _contentLayoutPadding = _p;

    /// 竖屏模式下，需要处理 顶部UI面板、状态栏、挖空遮挡之间的关系
    if (_size.height >= _size.width) {
      /// 状态栏遮挡高度，由`statusHeight`值决定是否可占用状态栏
      final statusHeight = repository.statusHeight;
      // 从上下文中取得固定的状态栏高度
      if (_safeTop == 0 && _p.top != 0) {
        _safeTop = _p.top;
      }
      // 顶部UI面板相关，面板的高度显/隐一致，不管有没有遮挡
      _pannelPadding = _p.copyWith(top: _safeTop);
      // 文本布局关系密切
      _contentLayoutPadding = EdgeInsets.only(
        left: _p.left + 16,
        top: statusHeight, // top: 取决于遮挡的高度(挖孔、刘海、水滴等)
        right: _p.right + 16,
      );
    } else {
      _contentLayoutPadding = EdgeInsets.only(
        left: _p.left + 16,
        right: _p.right + 16,
        top: _p.top,
      );
    }

    scheduleMicrotask(() {
      pannelPadding = _pannelPadding.copyWith(bottom: repository.height);
    });

    if (size != _size || _contentLayoutPadding != contentLayoutPadding) {
      size = _size;
      contentLayoutPadding = _contentLayoutPadding;
      assert(Log.w('size: $_size | $_pannelPadding | $_safeTop | ${_p.top}'));
      return true;
    } else {
      return false;
    }
  }
}
