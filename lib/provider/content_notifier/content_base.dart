import 'dart:async';

import 'package:flutter/material.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../event/export.dart';
import '../../pages/book_content/widgets/page_view_controller.dart';
import '../text_data.dart';

mixin ContentDataBase on ChangeNotifier {
  Repository get repository;
  int bookId = -1;
  int currentPage = 1;

  // 控制边界
  NopPageViewController? controller;
  int _innerIndex = 0;
  int get innerIndex => _innerIndex;

  void setInnerIndex(int newIndex) {
    _innerIndex = newIndex;
  }

  // _innerIndex == page == 0
  void resetController() {
    controller?.goIdle();
    _innerIndex = 0;
    controller?.applyContentDimension(minExtent: 0, maxExtent: 1);
    controller?.correct(0.0);
    needUpdateContentDimension();
  }

  // 考虑到页面可能没有对齐
  void shrinkIndex() {
    if (controller?.isScrolling == true) controller?.goIdle();
    final extent = controller?.viewPortDimension;
    if (extent != null) {
      final page = controller!.page;
      final floorPage = page.floor();
      final offset = page - floorPage;
      final resetPixels = offset * extent;
      assert(Log.w('start: $page | ${controller?.pixels}'));

      controller?.applyContentDimension(minExtent: 0, maxExtent: resetPixels);
      controller?.correct(resetPixels);

      _innerIndex = controller!.page.round();
      assert(Log.w(
          'done: ${controller?.page} | ${floorPage * extent} + ${controller?.pixels}'));
    } else {
      _innerIndex = 0;
    }
    needUpdateContentDimension();
  }

  TextData _tData = TextData();
  TextData get tData => _tData;

  void resetData(TextData data) {
    _tData = data;
  }

  set tData(TextData data) {
    if (data == _tData) return;
    assert(data.contentIsNotEmpty, '不该为 空');

    _tData.dispose();
    _tData = data.clone(); // 复制
    dump();
    updateCaches(data);
  }

  var _key = Object();
  Object get key => _key;
  void didChangeKey() => _key = Object();

  @visibleForTesting
  void clear() {
    reset();
    _tData.dispose();
    _tData = TextData();
  }

  final initQueue = EventQueue();

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

  bool debugTest = false;

  bool get inBook;

  void reset();
  void dump();

  void needUpdateContentDimension();

  // 更新队列
  void updateCaches(TextData data);

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
