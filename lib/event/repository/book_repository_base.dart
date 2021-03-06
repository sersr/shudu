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
// import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive/hive.dart';
import 'package:nop_db/nop_db.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/utils.dart';
import '../base/book_event.dart';
import '../base/repository.dart';
import '../base/type_adapter.dart';
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
      _changesListeners.forEach((c) => c(visible));
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

  Isolate? _isolate;
  Isolate? get isolate => _isolate;

  Future<ReceivePort?> initBase() async {
    if (init) return null;

    SystemChrome.setSystemUIChangeCallback(_onSystemOverlaysChanges);
    final _waits = <Future>{};

    late Directory appDir;
    List<Directory>? cacheDirs;

    if (Platform.isAndroid) {
      _waits
        // ..add(FlutterDisplayMode.setHighRefreshRate())
        ..add(getExternalCacheDirectories().then((dirs) => cacheDirs = dirs));
    }

    _waits
      ..add(getApplicationDocumentsDirectory().then((dir) => appDir = dir))
      ..add(orientation(true))
      ..add(getBatteryLevel)
      ..add(getViewInsets);

    await Future.wait(_waits);

    final appPath = appDir.path;
    final cachePath = cacheDirs?.isNotEmpty == true
        ? cacheDirs!.first.path
        : join(appPath, 'cache');

    hiveInit(join(appPath, 'shudu', 'hive'));

    // print('${cachePaths?.map((e) => e.path).join(',')}');
    // print((await appDir.list().toList()).join('\n'));
    final rcPort = ReceivePort();

    /// Isolate event
    await Isolate.spawn(isolateEvent, [rcPort.sendPort, appPath, cachePath])
        .then((value) => _isolate = value);

    return rcPort;
  }

  bool get init => _isolate != null;
  Future? closeTask;
  
  Future<void> close() {
    return closeTask ??= Hive.close().then((_) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
    })
      ..whenComplete(() => closeTask = null);
  }
}
