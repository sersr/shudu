import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import 'resolve_event.dart';

/// 单一隔离
void singleIsolateEvent(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];

  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  final db = BookEventIsolate(
    remoteSendPort: remoteSendPort,
    appPath: appPath,
    cachePath: cachePath,
    useSqflite3: useSqflite3,
  );

  db.run();
}

/// 统一由主隔离创建，并分配[SendPortOwner]
void multiIsolateEvent(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];
  // final databaseRepositorySendPort = args[4];

  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  final db = BookEventMultiIsolate(
    appPath: appPath,
    cachePath: cachePath,
    useSqflite3: useSqflite3,
    remoteSendPort: remoteSendPort,
  );
  db.run();
}

/// [multiIsolateEvent] 子隔离，处理数据库任务
void dataBaseEntryPoint(args) async {
  final remoteSendPort = args[0] as SendPort;
  final appPath = args[1] as String;
  // final cachePath = args[2] as String;
  final useSqflite3 = args[3] as bool;

  final db = DatabaseImpl(
    appPath: appPath,
    remoteSendPort: remoteSendPort,
    useSqflite3: useSqflite3,
  );

  db.run();
}
