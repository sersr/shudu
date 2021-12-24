import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import 'base/export.dart';

// 子隔离，数据库 入口
void dataBaseEntryPoint(args) async {
  final remoteSendPort = args[0] as SendHandle;
  final appPath = args[1] as String;
  // final cachePath = args[2] as String;
  DatabaseImpl(
    appPath: appPath,
    remoteSendPort: remoteSendPort,
  ).run();
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
    required this.remoteSendPort,
  });
  @override
  final SendHandle remoteSendPort;

  @override
  final String appPath;

  @override
  void onResolvedFailed(message) {
    Log.e('DatabaseImpl: error> $message', onlyDebug: false);
  }
}
