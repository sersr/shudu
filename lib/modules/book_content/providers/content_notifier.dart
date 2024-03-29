import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:flutter_nop/router.dart';

import '../../../event/export.dart';
import '../../book_info/views/info_page.dart';
import '../import.dart';
import '../widgets/page_view_controller.dart';
import 'content_notifier/export.dart';

/// 只提供向外暴露的api
class ContentNotifier with NopLifecycle {
  ContentNotifier();

  late final Repository repository = getType();
  late final ContentNotifierImpl handle = ContentNotifierImpl(repository);
  @override
  void nopInit() {
    super.nopInit();
    handle.init(this);
  }

  void notifyState(
      {bool? loading, bool? notEmptyOrIgnore, NotifyMessage? error}) {
    handle.notifyState(
        loading: loading, notEmptyOrIgnore: notEmptyOrIgnore, error: error);
  }

  // delegate
  Future<void> newBookOrCid(int newBookId, int cid, int page,
      {ApiType api = ApiType.biquge}) {
    return handle.newBookOrCid(newBookId, cid, page, api: api);
  }

  Future<void> touchBook(int newBookId, int cid, int page,
          {ApiType api = ApiType.biquge}) =>
      handle.touchBook(newBookId, cid, page, api: api);

  void metricsChange(MediaQueryData data) => handle.metricsChange(data);

  Future<void> shadow() => handle.shadow();

  Future<void> updateCurrent() => handle.updateCurrent();
  Future<void> reload() => handle.startFirstEvent(clear: false);
  Future<void> goNext() => handle.goNext();
  Future<void> goPre() => handle.goPre();

  ValueListenable<bool> get loading => handle.loading;
  ValueListenable<bool> get notEmptyOrIgnore => handle.notEmptyOrIgnore;
  ValueListenable<NotifyMessage> get error => handle.error;
  Listenable get listenable => Listenable.merge([loading, error]);

  ValueNotifier<bool> get pannelPaddingNotifier => handle.pannelPaddingNotifier;
  EdgeInsets get pannelPadding => handle.pannelPadding;

  ValueNotifier<ContentViewConfig> get config => handle.config;
  bool get inBook => handle.inBook;
  // bool get uiOverlayShow => handle.uiOverlayShow;
  // set uiOverlayShow(bool v) => handle.uiOverlayShow = v;
  Future<void>? get runner => handle.initQueue.runner;
  set controller(ContentViewControllerBase? base) => handle.controller = base;
  void scheduleTask() => handle.scheduleTask();
  void stopSave() => handle.autoRun.stopSave();
  void stopAutoRun() => handle.autoRun.stopAutoRun();
  void stopTicked() => handle.autoRun.stopTicked();
  bool get autoRunActive => handle.autoRun.value;
  ValueListenable<bool> get autoRunNotifier => handle.autoRun.isActive;
  ValueListenable<String> get header => handle.header;
  ValueListenable<String> get footer => handle.footer;
  TextStyle get secstyle => handle.secstyle;
  TextStyle get style => handle.style;
  EdgeInsets get contentLayoutPadding => handle.contentLayoutPadding;
  int get bookId => handle.bookId;
  int? get cid => handle.tData.cid;
  ApiType get api => handle.api;
  ValueNotifier<bool> get showCname => handle.showCname;
  ValueNotifier<double> get autoValue => handle.autoValue;
  ValueNotifier<double> get brightness => handle.brightness;
  ValueNotifier<bool> get follow => handle.follow;
  void setBrightness(double v) => handle.setBrightness(v);
  void setFollow(bool? v) => handle.setFollow(v);
  Future<void> onOut() async {
    handle.out();
    await handle.dumpIgnore();
    await runner;
    await handle.onOut();
  }

  void reloadBrightness() => handle.reloadBrightness();

  void auto() => handle.auto();

  void setPrefs(ContentViewConfig config) => handle.setPrefs(config);

  // 从阅读页面跳转到详情页
  (RouteQueueEntry, SaveStateData) goInfoPage(BuildContext context) {
    showCname.value = false;
    handle.controller?.goIdle();

    final data = handle.saveStateOnOut();
    final entry = BookInfoPage.push(data.saveBookId, data.saveApi);
    final content = RestorationContent.getFromEntry(context);
    content.update(entry);
    content.data = data;
    return (entry, data);
  }

  void dispose() {
    handle.dispose();
  }
}

class ContentNotifierImpl extends ChangeNotifierBase
    with
        ContentDataBase,
        ContentBrightness,
        ContentStatus,
        Configs,
        ContentRestore,
        ContentLayout,
        ContentLoad,
        ContentTasks,
        ContentAuto,
        ContentGetter,
        ContentEvent {
  ContentNotifierImpl(this.repository);
  @override
  final Repository repository;

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}

class RestorationContent extends RestorableProperty<Map<dynamic, dynamic>?> {
  ContentNotifierImpl? _handle;

  static RestorationContent getFromEntry(BuildContext context) {
    final current = RouteQueueEntry.of(context);
    return context.grass<RestorationContent>(group: current?.restorationId);
  }

  void setHandle(ContentNotifierImpl? handle) {
    _handle = handle;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  bool uiOverlayShow = false;

  void update(RouteQueueEntry entry) {
    onChanged?.call(entry);
  }

  void Function(RouteQueueEntry entry)? onChanged;

  @override
  Map? createDefaultValue() {
    return null;
  }

  @override
  Map? fromPrimitives(Object? data) {
    if (data is! Map) return null;
    return data;
  }

  SaveStateData? _data;
  SaveStateData? get data => _data;
  set data(SaveStateData? value) {
    _data = value;
    notifyListeners();
  }

  @override
  void initWithValue(Map? value) {
    if (value == null) return;

    final newData = SaveStateData.fromJson(value);
    if (newData is SaveStateData) {
      _data = newData;
    }
  }

  @override
  Object? toPrimitives() {
    return (data ?? _handle?.saveData)?.toJson();
  }
}
