import 'dart:isolate';

import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import 'base/base.dart';

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

/// 只处理数据库相关操作
class DatabaseImpl extends MultiDatabaseResolveMain
    with
        DatabaseMixin,
        ZhangduDatabaseMixin,
        ComplexOnDatabaseMixin,
        ZhangduComplexOnDatabaseMixin {
  DatabaseImpl({
    required this.appPath,
    required this.useSqflite3,
    required this.remoteSendPort,
  });
  @override
  final SendPort remoteSendPort;

  @override
  final String appPath;
  @override
  final bool useSqflite3;

  @override
  void onResolvedFailed(message) {
    Log.e('DatabaseImpl: error> $message', onlyDebug: false);
  }
}
