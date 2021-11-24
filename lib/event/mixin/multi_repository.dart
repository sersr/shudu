import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../repository.dart';
import 'database_only_impl.dart';
import 'resolve_event.dart';

/// 子隔离: 处理数据库任务
class DatabaseRepository extends RepositoryBase {
  DatabaseRepository();
  List? args;

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) {
    Log.w(args);
    return Isolate.spawn(dataBaseEntryPoint, [remoteSendPort, ...?args]);
  }
}

/// 主隔离: 网络，数据库([DatabaseRepository]代理)
class MultiRepository extends RepositoryBase {
  MultiRepository();

  final DatabaseRepository databaseRepository = DatabaseRepository();
  @override
  SendEvent get bookCacheEventSendEvent => databaseRepository;
  @override
  SendEvent get bookContentEventSendEvent => databaseRepository;
  @override
  SendEvent get zhangduDatabaseEventSendEvent => databaseRepository;

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) {
    return initWork(remoteSendPort);
  }

  @override
  Future<Isolate> createIsolate(SendPort remoteSendPort, List args) async {
    // args: [appPath, cachePath, useSqflite3]
    final newIsolate =
        Isolate.spawn(_multiIsolateEntryPoint, [remoteSendPort, ...args]);
    databaseRepository.args = args;
    await databaseRepository.init();

    return newIsolate;
  }

  @override
  void onResume() {
    assert(sendPortOwner != null);
    // 需要手动指定
    sendPortOwner!.localSendPort.send(SendPortName(
        'database' /* 与远程 Isolate 匹配 */,
        databaseRepository.sendPortOwner!.localSendPort));
    super.onResume();
  }

  @override
  FutureOr<void> onCloseStart() async {
    await super.onCloseStart();
    return databaseRepository.close();
  }
}

/// 统一由主隔离创建，并分配[SendPortOwner]
void _multiIsolateEntryPoint(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];

  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  final db = BookEventMultiIsolate(
    appPath: appPath,
    cachePath: cachePath,
    useSqflite3: useSqflite3,
    remoteSendPort: remoteSendPort,
  );
  db.run();
}
