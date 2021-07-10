import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../base/repository.dart';
import '../event.dart';

abstract class BookRepositoryBase extends Repository {
  Battery? _battery;
  ViewInsets _viewInsets = ViewInsets.zero;
  @override
  ViewInsets get viewInsets => _viewInsets;

  var _bottomHeight = 0;
  @override
  int get bottomHeight => _bottomHeight;

  @override
  Future<ViewInsets> getViewInsets() async {
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
}

void _isolateEvent(List args) async {
  final port = args[0];
  final appPath = args[1];
  final receivePort = ReceivePort();

  final db = BookEventIsolate(appPath, port);
  await db.initState();

  receivePort.listen((m) {
    if (db.resolve(m)) return;
  });

  port.send(receivePort.sendPort);
}
