import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../repository.dart';
import 'base/complex_mixin.dart';
import 'base/network_mixin.dart';
import 'base/zhangdu_mixin.dart';
import 'database_only_impl.dart';

class MultiIsolateRepository extends Repository
    with
        ListenMixin,
        // SendEventMixin,
        SendEventPortMixin,
        SendCacheMixin,
        SendMultiIsolateMixin,
        MultiBookEventDefaultMessagerMixin // 默认
{
  // [appPath, cachePath, useSqflite3]
  List? args;

  @override
  FutureOr<void> onInitStart() async {
    notifiyStateRoot(false);
    args = await initStartArgs();
    Log.i('args: $args', onlyDebug: false);
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
  void onResumeListen() {
    super.onResumeListen();
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

  final db = BookEventMultiIsolate(
    appPath: appPath,
    cachePath: cachePath,
    useSqflite3: useSqflite3,
    remoteSendPort: remoteSendPort,
  );
  db.init();
}

/// 与 [MultiIsolateRepository] 配合使用
/// 任务隔离(remote):处理 数据库、网络任务
/// 接受一个[SendPortOwner]处理数据库消息
class BookEventMultiIsolate extends MultiBookEventDefaultResolveMain
    with

        // sender
        SendEventMixin,
        // SendEventPortMixin,
        SendCacheMixin,
        SendInitCloseMixin,
        // -- SendPortOwner 代理----
        ComplexOnDatabaseEventMessager, // 初始化：要返回的Messager协议
        // net
        HiveDioMixin,
        NetworkMixin,
        ZhangduNetMixin,
        // complex
        ComplexMixin,
        ZhangduComplexMixin {
  BookEventMultiIsolate({
    required this.appPath,
    required this.cachePath,
    required this.useSqflite3,
    required this.remoteSendPort,
  });

  @override
  final String appPath;
  @override
  final String cachePath;

  final bool useSqflite3;
  @override
  final SendPort remoteSendPort;

  @override
  FutureOr<void> initTask() => run();

  @override
  FutureOr<void> closeTask() => onClose();
  
  @override
  SendPortOwner? getSendPortOwner(key) {
    final owner = super.getSendPortOwner(key);
    if (owner == null) {
      Log.e('owner == null,需要与$key匹配的`SendPortOwner`发送消息', onlyDebug: false);
    }
    return owner;
  }

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', lines: 1, onlyDebug: false);
  }

  @override
  void onError(msg, error) {
    Log.e('onError: $msg\n$error', onlyDebug: false);
  }
}
