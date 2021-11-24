import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../repository.dart';
import 'database_only_impl.dart';
import 'resolve_event.dart';

/// ---------------- multi Isolate --------------------

class MultiIsolateRepository extends Repository
    with
        SendEventPortMixin,
        SendCacheMixin,
        SendMultiIsolateMixin,
        MultiBookEventDefaultMixin, // 默认
        MultiDatabaseMixin // 由代码生成
{
  // [appPath, cachePath, useSqflite3]
  List? args;

  @override
  FutureOr<void> onInitStart() async {
    notifiyStateRoot(false);
    args = await initStartArgs();
    Log.i('start args: $args', onlyDebug: false);
  }

  @override
  Future<Isolate> createIsolateDatabase(SendPort remoteSendPort) {
    assert(args != null);
    return Isolate.spawn(dataBaseEntryPoint, [remoteSendPort, ...?args]);
  }

  @override
  Future<Isolate> createIsolateBookEventDefault(SendPort remoteSendPort) {
    assert(args != null);
    return Isolate.spawn(_multiIsolateEntryPoint, [remoteSendPort, ...?args]);
  }

  @override
  void onResume() {
    assert(databaseIsolateSendPortOwner != null);

    /// 处理隔离之间的关系
    defaultSendPortOwner!.localSendPort.send(SendPortName(
        databaseIsolate, databaseIsolateSendPortOwner!.localSendPort));
    super.onResume();
    notifiyStateRoot(true);
    // args = null; // 安全
  }

  @override
  void dispose() {
    super.dispose();
    notifiyStateRoot(false);
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
