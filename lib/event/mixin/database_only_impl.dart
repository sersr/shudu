import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../base/complex_event.dart';
import 'base/database_mixin.dart';
import 'base/zhangdu_mixin.dart';

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
class DatabaseImpl
    with
        Resolve,
        ResolveMixin,
        MultiDatabaseOnResumeMixin,
        DatabaseMixin,
        ZhangduDatabaseMixin,
        ComplexOnDatabaseMixin,
        ZhangduComplexOnDatabaseMixin,
        BookCacheEventResolve, // 1
        BookContentEventResolve, // 2
        ZhangduDatabaseEventResolve, // 3
        ComplexOnDatabaseEventResolve // 4
{
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
  void onResumeResolve() {
    Log.i('DatabaseImpl: onresume', onlyDebug: false);
    super.onResumeResolve();
  }

  @override
  void onResolvedFailed(message) {
    Log.e('DatabaseImpl: error> $message', onlyDebug: false);
  }
}
