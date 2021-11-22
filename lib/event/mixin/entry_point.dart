import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';
import 'resolve_event.dart';
import 'database_delegate_mixin.dart';

/// 单一隔离
void singleIsolateEvent(List args) async {
  final port = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];

  final receivePort = ReceivePort();
  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  final db = BookEventIsolate(port, appPath, cachePath, useSqflite3);

  await runZonedGuarded(() async {
    await db.initState();
    receivePort.listen((m) {
      try {
        if (db.resolveAll(m)) return;
      } catch (e, s) {
        Log.e('error: $e\n$s');
      }
      Log.e('somthing was error: $m');
    });
  }, (e, s) {
    Log.e('$e\n$s');
  }, zoneSpecification:
      ZoneSpecification(errorCallback: (self, delegate, zone, e, s) {
    // Log.e('error:$e\n$s');
    return delegate.errorCallback(zone, e, s);
  }));

  port.send(receivePort.sendPort);
}

/// 统一由主隔离创建，并分配[SendPortOwner]
void multiIsolateEvent(List args) async {
  final port = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];
  final databaseRepositorySendPort = args[4];

  final receivePort = ReceivePort();
  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  final db = BookEventMultiIsolate(
    port,
    appPath,
    cachePath,
    useSqflite3,
    SendPortOwner(
        localSendPort: databaseRepositorySendPort,
        remoteSendPort: receivePort.sendPort),
  );

  await runZonedGuarded(() async {
    await db.initState();
    receivePort.listen((m) {
      try {
        if (db.add(m)) return;
        if (db.resolveAll(m)) return;
      } catch (e, s) {
        Log.e('error: $e\n$s');
      }
      Log.e('somthing was error: $m');
    });
  }, (e, s) {
    Log.e('$e\n$s');
  }, zoneSpecification:
      ZoneSpecification(errorCallback: (self, delegate, zone, e, s) {
    // Log.e('error:$e\n$s');
    return delegate.errorCallback(zone, e, s);
  }));

  port.send(receivePort.sendPort);
}

/// [multiIsolateEvent] 子隔离，处理数据库任务
void dataBaseEntryPoint(args) async {
  final localSendPort = args[0] as SendPort;
  final appPath = args[1] as String;
  // final cachePath = args[2] as String;
  final useSqflite3 = args[3] as bool;
  final db = DatabaseImpl(
      appPath: appPath,
      // cachePath: cachePath,
      useSqflite3: useSqflite3);
  final rcPort = ReceivePort();

  // 确保所有消息都会收到回复
  await runZonedGuarded(() async {
    await db.initState();
    rcPort.listen((message) {
      if (db.resolveAll(message)) return;
      Log.e('error: $message');
    });
  }, (e, s) {
    Log.e('$e\n$s', onlyDebug: false);
  }, zoneSpecification:
      ZoneSpecification(errorCallback: (self, delegate, zone, e, s) {
    // Log.e('error:$e\n$s');
    return delegate.errorCallback(zone, e, s);
  }));

  localSendPort.send(rcPort.sendPort);
}
