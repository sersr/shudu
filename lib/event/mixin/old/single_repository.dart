import 'dart:isolate';

import 'package:useful_tools/useful_tools.dart';

import '../../repository.dart';
import 'database_delegate_mixin.dart';

/// 单一 隔离
/// 主隔离(native)
class SingleRepository extends RepositoryBase {
  SingleRepository();

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) {
    return initWork(remoteSendPort);
  }

  @override
  Future<Isolate> createIsolate(SendPort remoteSendPort, List args) async {
    /// Isolate event
    /// [remoteSendPort, appPath, cachePath, useSqflite3]
    return Isolate.spawn(singleIsolateEntryPoint, [remoteSendPort, ...args]);
  }
}

/// 单一隔离\代理
void singleIsolateEntryPoint(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];

  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  final db = BookEventIsolateDeleagete /** [BookEventIsolate] */ (
    remoteSendPort: remoteSendPort,
    appPath: appPath,
    cachePath: cachePath,
    useSqflite3: useSqflite3,
  );

  db.run();
}
