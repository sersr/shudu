import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:dartz/dartz.dart' as dartz;
import '../base/book_event.dart';
import '../repository.dart';
import 'base/base.dart';
import 'database_only_impl.dart';

class MultiIsolateRepository extends Repository
    with
        // ComplexMixin, // 简单的条件判断可以在主隔离中调用
        ListenMixin,
        SendEventMixin,
        // SendEventPortMixin,
        SendCacheMixin,
        SendMultiServerMixin,
        MultiBookEventDefaultMessagerMixin // 默认
{
  // [appPath, cachePath]
  List? args;

  @override
  FutureOr<void> onInitStart() async {
    args = await initStartArgs();
    Log.i('args: $args', onlyDebug: false);
  }

  @override
  Future<RemoteServer> createRemoteServerDatabase() async {
    assert(args != null);
    if (!kIsWeb) {
      final isolate =
          await Isolate.spawn(dataBaseEntryPoint, [localSendPort, ...?args]);
      return IsolateRemoteServer(isolate);
    } else {
      dataBaseEntryPoint([localSendPort, ...?args]);
      return LocalRemoteServer();
    }
  }

  @override
  Future<RemoteServer> createRemoteServerBookEventDefault() async {
    assert(args != null);
    if (!kIsWeb) {
      final isolate = await Isolate.spawn(
          _multiIsolateEntryPoint, [localSendPort, ...?args]);
      return IsolateRemoteServer(isolate);
    } else {
      _multiIsolateEntryPoint([localSendPort, ...?args]);
      return LocalRemoteServer();
    }
  }
}

/// 统一由主隔离创建，并分配[SendPortOwner]
void _multiIsolateEntryPoint(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  dartz.Option;
  BookEventMultiIsolate(
    appPath: appPath,
    cachePath: cachePath,
    remoteSendPort: remoteSendPort,
  ).init();
}

/// 与 [MultiIsolateRepository] 配合使用
/// 任务隔离(remote):处理 数据库、网络任务
/// 接受一个[SendPortOwner]处理数据库消息
class BookEventMultiIsolate extends MultiBookEventDefaultResolveMain
    with
        // senders
        SendEventMixin,
        // SendEventPortMixin,
        SendCacheMixin,
        SendInitCloseMixin,
        // net
        HiveDioMixin,
        NetworkMixin,
        ZhangduNetMixin,
        ServerEventMessager,
        // complex
        ComplexMixin,
        ZhangduComplexMixin {
  BookEventMultiIsolate({
    required this.appPath,
    required this.cachePath,
    required this.remoteSendPort,
  });

  @override
  final String appPath;
  @override
  final String cachePath;

  @override
  final SendHandle remoteSendPort;

  @override
  FutureOr<void> initTask() => run();

  @override
  FutureOr<void> closeTask() => onClose();

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', lines: 2, onlyDebug: false);
  }

  @override
  void onError(msg, error) {
    Log.e('onError: $msg\n$error', onlyDebug: false);
  }
}
