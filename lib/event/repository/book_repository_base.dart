import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
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

  Isolate? _isolate;
  Isolate? get isolate => _isolate;

  Future<bool> initBase(ReceivePort rcPort) async {
    if (_init) return false;
    final _waits = <Future>{};
    if (Platform.isAndroid) _waits.add(FlutterDisplayMode.setHighRefreshRate());

    _waits.add(orientation(true));
    _waits.add(getBatteryLevel);
    _waits.add(getViewInsets);

    late Directory appDir;
    _waits.add(
        getApplicationDocumentsDirectory().then((value) => appDir = value));

    List<Directory>? cachePaths;
    if (Platform.isAndroid) {
      _waits.add(
          getExternalCacheDirectories().then((value) => cachePaths = value));
    }
    await Future.wait(_waits);

    final appPath = appDir.path;
    final cachePath = cachePaths?.isNotEmpty == true
        ? cachePaths!.first.path
        : join(appPath, 'cache');

    hiveInit('$appPath/shudu/hive');

    // print('${cachePaths?.map((e) => e.path).join(',')}');
    // print((await appDir.list().toList()).join('\n'));

    /// Isolate event
    await Isolate.spawn(isolateEvent, [rcPort.sendPort, appPath, cachePath])
        .then((value) => _isolate = value);

    _init = true;
    return true;
  }

  var _init = false;

  @override
  void dispose() {
    Hive.close().then((value) => _init = false);
    isolate?.kill(priority: Isolate.immediate);
  }
}
