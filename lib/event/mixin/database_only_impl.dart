import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/export.dart';
import 'base/export.dart';
import 'base/system_infos.dart';

// 子隔离，数据库 入口
void dataBaseEntryPoint(IsolateArgs args) {
  OneFile.runZoned(DatabaseImpl(
    appPath: args.appPath,
    remoteSendHandle: args.sendHandle,
  ).run);
}

/// 只处理数据库相关操作
class DatabaseImpl extends MultiDatabaseResolveMain
    with DatabaseMixin, ComplexOnDatabaseMixin {
  DatabaseImpl({
    required this.appPath,
    required this.remoteSendHandle,
  });
  @override
  final SendHandle remoteSendHandle;

  @override
  final String appPath;

  @override
  void onResolvedFailed(message) {
    Log.e('DatabaseImpl: error> $message', onlyDebug: false);
  }
}
