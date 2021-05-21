import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api.dart';
import '../bloc/bloc.dart';
import '../utils/utils.dart';
import 'book_event_main.dart';
import 'isolate_side.dart';
import 'messages.dart';
import 'repository.dart';

class BookRepository extends Repository {
  @override
  late String dataPath;

  @override
  late String appPath;

  final _initCallbacks = <Future<void> Function()>[];
  @override
  void addInitCallback(Future<void> Function() callback) {
    if (_initCallbacks.contains(callback)) return;
    _initCallbacks.add(callback);
  }

  late ReceivePort clientRP;
  late SendPort clientSP;
  late Isolate _isolate;
  final client = dioCreater();

  var _init = false;

  @override
  Future<void> initState() async {
    if (_init) {
      assert(Log.w('已经初始化了', stage: this, name: 'initState'));
      return;
    }
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    final _futures = <Future>{};

    _futures.add(Future(() async {
      final _secF = <Future>{};

      appPath = (await getApplicationDocumentsDirectory()).path;
      Hive.registerAdapter(ColorAdapter());
      Hive.registerAdapter(AxisAdapter());
      Hive.registerAdapter(TargetPlatformAdapter());
      Hive.registerAdapter(PageBuilderAdapter());

      Hive.init('$appPath/shudu/hive');
      // await Hive.initFlutter();
      final _minitCallbacks = List.of(_initCallbacks);
      _initCallbacks.clear();
      _minitCallbacks.forEach((callback) {
        _secF.add(callback());
      });

      _secF.add(Future(() async {
        clientRP = ReceivePort();
        _isolate =
            await Isolate.spawn(_isolateNet, [clientRP.sendPort, appPath]);
        clientSP = await clientRP.first;
      }));
      await Future.wait(_secF);
    }));

    _futures.add(getBatteryLevel());
    _futures.add(getViewInsets());
    final _bookEvent = BookEventMain(repository: this);

    bookEvent = _bookEvent;

    _futures.add(_bookEvent.initState());
    await Future.wait(_futures);
    _init = true;
  }

  @override
  void dipose() {
    client.close();
    clientRP.close();
    _isolate.kill(priority: Isolate.immediate);
    _init = false;
  }

  @override
  Future<T> sendMessage<T extends Object?>(dynamic type, dynamic args) async {
    final port = ReceivePort();
    clientSP.send(IsolateSendMessage(type, args, port.sendPort));
    final result = (await port.first) as IsolateReceiveMessage;
    if (result.result == Result.failed) {
      assert(Log.e('返回错误：${result.data}', stage: this, name: 'sendMessage'));
    } else if (result.result == Result.error) {
      Api.moveNext();
    }
    port.close();
    return result.data;
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

  @override
  Future<int> getBatteryLevel() async {
    _battery ??= Battery();
    var deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      // var androidInfo = await deviceInfo.androidInfo;
      level = await _battery!.batteryLevel;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      var iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return level;
      }
      level = await _battery!.batteryLevel;
    }

    return level;
  }
}

void _isolateNet(List args) async {
  final port = args[0];
  final appPath = args[1];
  final receivePort = ReceivePort();
  // final func = MessageFunc(appPath);

  // await func.init();
  final db = BookEventIsolate(appPath);
  await db.initState();

  receivePort.listen(
    (m) async {
      if (m is IsolateSendMessage) {
        db.resolveFunc(m);
      }
    },
  );
  port.send(receivePort.sendPort);
}

Dio dioCreater() => Dio(
      BaseOptions(
        connectTimeout: 5000,
        sendTimeout: 5000,
        receiveTimeout: 10000,
        headers: {
          HttpHeaders.connectionHeader: 'keep-alive',
          HttpHeaders.userAgentHeader:
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                  ' (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36 Edg/90.0.818.56'
        },
      ),
    );

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) {
    final colorValue = reader.readInt();
    return Color(colorValue);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }

  @override
  int get typeId => 0;
}

class AxisAdapter extends TypeAdapter<Axis> {
  @override
  Axis read(BinaryReader reader) {
    final index = reader.readInt();
    return Axis.values[index];
  }

  @override
  void write(BinaryWriter writer, Axis axis) {
    writer.writeInt(axis.index);
  }

  @override
  int get typeId => 1;
}

class TargetPlatformAdapter extends TypeAdapter<TargetPlatform> {
  @override
  TargetPlatform read(BinaryReader reader) {
    final index = reader.readInt();
    return TargetPlatform.values[index];
  }

  @override
  void write(BinaryWriter writer, TargetPlatform obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 2;
}

class PageBuilderAdapter extends TypeAdapter<PageBuilder> {
  @override
  PageBuilder read(BinaryReader reader) {
    final index = reader.readInt();
    return PageBuilder.values[index];
  }

  @override
  void write(BinaryWriter writer, PageBuilder obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 3;
}
