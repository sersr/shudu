import 'package:nop/nop.dart';

import '../base/export.dart';
import 'base/export.dart';
import 'base/system_infos.dart';

// 子隔离，数据库 入口
void dataBaseEntryPoint(IsolateConfigurations<BookIsolateArgs> configs) {
  final userArgs = configs.args;
  final sendHandle = configs.sendHandle;
  OneFile.runZoned(DatabaseImpl(
    appPath: userArgs.appPath,
    remoteSendHandle: sendHandle,
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
