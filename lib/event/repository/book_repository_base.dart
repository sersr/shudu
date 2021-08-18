import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:nop_db/database/nop_impl/sqflite_main_isolate.dart';
import 'package:nop_db/nop_db.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:useful_tools/common.dart';
import 'package:useful_tools/event_queue.dart';

import '../../provider/options_notifier.dart';
import '../base/book_event.dart';
import '../base/repository.dart';
import '../event.dart';

abstract class BookRepositoryBase extends Repository implements SendEvent {
  Battery? _battery;
  ViewInsets _viewInsets = ViewInsets.zero;
  @override
  ViewInsets get viewInsets => _viewInsets;
  @override
  late BookEvent bookEvent = BookEventMain(this);

  var _bottomHeight = 0;
  @override
  int get bottomHeight => _bottomHeight;

  @override
  Future<ViewInsets> get getViewInsets async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final viewInsets = await Bangs.safePadding;
      _viewInsets = viewInsets;
      _bottomHeight = await Bangs.bottomHeight ~/ window.devicePixelRatio;

      assert(Log.i('bottomHeight: $_bottomHeight'));
    }
    return _viewInsets;
  }

  DeviceInfoPlugin? deviceInfo;
  @override
  Future<int> get getBatteryLevel async {
    _battery ??= Battery();

    deviceInfo ??= DeviceInfoPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
      // var androidInfo = await deviceInfo.androidInfo;
      level = await _battery!.batteryLevel;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      var iosInfo = await deviceInfo!.iosInfo;

      if (!iosInfo.isPhysicalDevice) return level;

      level = await _battery!.batteryLevel;
    }

    return level;
  }

  bool _systemOverlaysAreVisible = false;
  @override
  bool get systemOverlaysAreVisible => _systemOverlaysAreVisible;

  Future<void> _onSystemOverlaysChanges(bool visible) async {
    _systemOverlaysAreVisible = visible;
    if (_changesListeners.isNotEmpty)
      for (var c in _changesListeners) {
        c(visible);
      }
  }

  final _changesListeners = <BoolCallback>{};
  @override
  void addSystemOverlaysListener(BoolCallback callback) {
    if (!_changesListeners.contains(callback)) {
      _changesListeners.add(callback);
    }
  }

  @override
  void removeSystemOverlaysListener(BoolCallback callback) {
    _changesListeners.remove(callback);
  }

  bool hasBottomNavbar = false;
  double height = 0;

  final _safeBottom = ValueNotifier(0.0);
  @override
  ValueNotifier<double> get safeBottom => _safeBottom;

  ///
  /// Isolate
  ///

  Isolate? _isolate;

  Isolate? get isolate => _isolate;

  set isolate(Isolate? n) {
    if (_isolate != n && _isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
    }
    _isolate = n;
    _init.value = _isolate != null;
  }

  EventQueue get _initQueue => EventQueue.createEventQueue('app Init');
  Future? get runner => _initQueue.runner;

  Future<void> onDone(ReceivePort rcPort);
  Future<void> onInit() async {
    if (_isolate != null) {
      assert(_init.value);
      return;
    }
    SystemChrome.setSystemUIChangeCallback(_onSystemOverlaysChanges);
    final _waits = <Future>{};

    late Directory appDir;
    Directory? appDirExt;

    List<Directory>? cacheDirs;

    if (Platform.isAndroid) {
      Bangs.bangs.setNavigationChangeCallback(_changeCallback);
      // 存储在外部，避免重新安装时数据丢失
      appDirExt = Directory('/storage/emulated/0/shudu');
      _waits
        ..add(getExternalCacheDirectories().then((dirs) => cacheDirs = dirs))
        ..add(Permission.manageExternalStorage.status.then((status) {
          if (status.isDenied) {
            return Permission.manageExternalStorage.request().then((status) {
              if (status.isDenied) appDirExt = null;
            });
          }
        }));
    }

    _waits
      ..add(getApplicationDocumentsDirectory().then((dir) => appDir = dir))
      ..add(setOrientation(true))
      ..add(getBatteryLevel)
      ..add(getViewInsets);

    await Future.wait(_waits);
    final appPath = appDirExt?.path ?? appDir.path;
    final cachePath = cacheDirs?.isNotEmpty == true
        ? cacheDirs!.first.path
        : join(appPath, 'cache');

    // hiveInit(join(appPath, 'shudu', 'hive'));

    final rcPort = ReceivePort();
    bool useFfi = false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        useFfi = true;
        break;
      default:
    }
    bool useSqflite3 = await OptionsNotifier.sqfliteBox;
    Log.w('useSqflite3: $useSqflite3', onlyDebug: false);
    if (!useFfi && useSqflite3) {
      SqfliteMainIsolate.initMainDb();
    }

    /// Isolate event
    final newIsolate = await Isolate.spawn(isolateEvent,
        [rcPort.sendPort, appPath, cachePath, useFfi, useSqflite3]);
    await onDone(rcPort);

    /// 完成时再设置
    isolate = newIsolate;
  }

  void initBase() {
    _initQueue.addOneEventTask(onInit);
  }

  void _changeCallback(bool isShow, int navHeight) {
    hasBottomNavbar = isShow;
    height = navHeight / window.devicePixelRatio;

    if (hasBottomNavbar) {
      safeBottom.value = height;
    } else {
      safeBottom.value = 0;
    }
  }

  final ValueNotifier<bool> _init = ValueNotifier(false);

  @override
  ValueNotifier<bool> get init {
    assert(_init.value == (_isolate != null));
    return _init;
  }

  @mustCallSuper
  Future<void> onClose() async {
    await Hive.close();
    isolate = null;
  }

  @override
  Future<void> close() {
    final t = _initQueue.addOneEventTask(onClose);
    assert(runner != null);
    return runner ?? t;
  }
}
