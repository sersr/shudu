import 'package:nop/nop.dart';

import '../base/export.dart';
import 'base/export.dart';
import 'base/system_infos.dart';

// 子隔离，数据库 入口
Runner dataBaseEntryPoint(ServerConfigurations<BookIsolateArgs> configs) {
  return Runner(
    runDelegate: OneFile.runZoned,
    runner: DatabaseImpl(configurations: configs),
  );
}

/// 只处理数据库相关操作
class DatabaseImpl extends MultiDatabaseResolveMain
    with DatabaseMixin, ComplexOnDatabaseMixin {
  DatabaseImpl({required ServerConfigurations<BookIsolateArgs> configurations})
      : appPath = configurations.args.appPath,
        super(configurations: configurations);

  @override
  final String appPath;

  @override
  void onResolvedFailed(message) {
    Log.e('DatabaseImpl: error> $message', onlyDebug: false);
  }
}
