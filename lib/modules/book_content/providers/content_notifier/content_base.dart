import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nop/event_queue.dart';

import '../../../../event/export.dart';
import '../../import.dart';
import '../../text_data.dart';
import '../../widgets/page_view_controller.dart';

mixin ContentDataBase on ChangeNotifier {
  Repository get repository;
  int bookId = -1;
  int currentPage = 1;

  ContentViewControllerBase? controller;
  int _innerIndex = 0;
  int get innerIndex => _innerIndex;

  void setInnerIndex(int newIndex) {
    _innerIndex = newIndex;
  }

  // _innerIndex == page == 0
  void resetController() {
    controller?.goIdle();
    _innerIndex = 0;
    controller?.resetViewportDimension();
    controller?.correct(0.0);
    needUpdateContentDimension();
  }

  // 考虑到页面可能没有对齐
  // void shrinkIndex() {
  //   if (controller?.isScrolling == true) controller?.goIdle();
  //   final extent = controller?.viewPortDimension;
  //   if (extent != null) {
  //     final page = controller!.page;
  //     final floorPage = page.floor();
  //     final offset = page - floorPage;
  //     final resetPixels = offset * extent;
  //     assert(Log.w('start: $page | ${controller?.pixels}'));

  //     controller?.applyContentDimension(minExtent: 0, maxExtent: resetPixels);
  //     controller?.correct(resetPixels);

  //     _innerIndex = controller!.page.round();
  //     assert(Log.w(
  //         'done: ${controller?.page} | ${floorPage * extent} + ${controller?.pixels}'));
  //   } else {
  //     _innerIndex = 0;
  //   }
  //   needUpdateContentDimension();
  // }

  TextData _tData = TextData();
  TextData get tData => _tData;

  void resetData(TextData data) {
    _tData = data;
  }

  set tData(TextData data) {
    if (data == _tData) return;
    assert(data.contentIsNotEmpty, '不该为 空');
    needUpdateContentDimension();
    _tData.dispose();
    _tData = data.clone(); // 复制
    dump();
    updateCaches(data);
  }

  ApiType api = ApiType.biquge;

  bool shouldUpdate(int newBookId, int cid, ApiType api) {
    return tData.cid != cid ||
        bookId != newBookId ||
        this.api != api ||
        tData.contentIsEmpty;
  }

  var _key = Object();
  Object get key => _key;
  void didChangeKey() => _key = Object();

  void clear() {
    assert(!inBook);
    reset();
    _tData.dispose();
    _tData = TextData();
  }

  final initQueue = EventQueue();
  @mustCallSuper
  FutureOr<void> onOut() => initQueue.runner;

  final showCname = ValueNotifier(false);
  final mic = Duration.microsecondsPerMillisecond * 200.0;

  void notifyState(
      {bool? loading, bool? notEmptyOrIgnore, NotifyMessage? error});

  void notifyCustom() {
    notifyState(
        //                        notEmpty        ||  ignore
        notEmptyOrIgnore: tData.contentIsNotEmpty || !inBook,
        loading: false);
  }

  void notify() {
    notifyCustom();
    notifyListeners();
  }

  bool get inBook;
  Future<void> newBookOrCid(int newBookId, int cid, int page,
      {ApiType api = ApiType.biquge});
  void reset();
  void dump();

  void needUpdateContentDimension();

  // 更新队列
  void updateCaches(TextData data);

  /// 加载当前章节内容
  ///
  /// 互斥
  ///
  /// 多次调用会安排任务进入一个队列中
  ///
  /// 配置的更改,窗口的属性变化都有可能调用一次方法
  /// [newBookOrCid]: 重置状态后,会调用一次方法
  Future<void> startFirstEvent({
    bool clear = true,
    bool only = true,
    FutureOr<void> Function()? onStart,
    void Function()? onDone,
  });
}

class NotifyMessage {
  const NotifyMessage._(this.error, {this.msg = ''});
  static const hide = NotifyMessage._(false, msg: '');
  static const netWorkError = NotifyMessage._(true, msg: '网络错误');
  static const noNextError = NotifyMessage._(true, msg: '已经是最后一章了');
  final bool error;
  final String msg;
}
