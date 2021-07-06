import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:nop_db/nop_db.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/utils.dart';
import '../base/book_event.dart';
import '../base/repository.dart';
import '../book_event_main.dart';
import '../isolate_side.dart';
import '../base/type_adapter.dart';

class BookRepository extends Repository with SendEventMixin {
  final _initCallbacks = <Future<void> Function()>[];
  @override
  void addInitCallback(Future<void> Function() callback) {
    if (_initCallbacks.contains(callback)) return;
    _initCallbacks.add(callback);
  }

  @override
  late BookEvent bookEvent = BookEventMain(this);
  late ReceivePort clientRP;
  late SendPort clientSP;
  late Isolate _isolate;

  var _init = false;
  Future<void>? _f;

  @override
  Future<void> get initState async {
    _f ??= _initState().whenComplete(() => _f = null);
    return _f;
  }

  Future<void> _initState() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    final _futures = <Future>{};

    _futures.add(Future(() async {
      final _secF = <Future>{};

      final appPath = (await getApplicationDocumentsDirectory()).path;
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapter(AxisAdapter())
        ..registerAdapter(TargetPlatformAdapter())
        ..registerAdapter(PageBuilderAdapter());

      Hive.init('$appPath/shudu/hive');

      final _minitCallbacks = List.of(_initCallbacks);
      _initCallbacks.clear();
      _minitCallbacks.forEach((callback) => _secF.add(callback()));

      _secF.add(Future<void>(() async {
        clientRP = ReceivePort();
        _isolate =
            await Isolate.spawn(_isolateEvent, [clientRP.sendPort, appPath]);

        _clientF ??= Completer<void>();
        _init = true;

        clientRP.listen(_listen);

        await _clientF?.future;
        _clientF = null;
      }));

      await Future.wait(_secF);
    }));

    _futures.add(getBatteryLevel);
    _futures.add(getViewInsets());

    await Future.wait(_futures);
  }

  Completer<void>? _clientF;

  void _listen(r) {
    if (!_init) return;
    if (add(r)) return;

    if (r is SendPort) {
      _clientF?.complete();
      clientSP = r;
      return;
    }

    Log.e('messager error');
  }

  @override
  void dispose() {
    clientRP.close();
    _isolate.kill(priority: Isolate.immediate);
    super.dispose();

    _init = false;
  }

  @override
  void send(message) {
    clientSP.send(message);
  }

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
