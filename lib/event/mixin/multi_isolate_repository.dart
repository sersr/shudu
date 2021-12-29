import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';
import '../base/book_event.dart';
import '../repository.dart';
import 'base/export.dart';
import 'base/system_infos.dart';
import 'database_only_impl.dart';

class MultiIsolateRepository extends Repository
    with
        ListenMixin,
        SendEventMixin,
        // SendEventPortMixin,
        SendCacheMixin,
        SendMultiServerMixin,
        MultiBookEventDefaultMessagerMixin // 默认
{
  // [appPath, cachePath]
  IsolateArgs? args;

  @override
  FutureOr<void> onInitStart() async {
    args = await initStartArgs();
  }

  @override
  Future<RemoteServer> createRemoteServerDatabase() async {
    assert(args != null);
    final localArgs = args!.copyWith(localSendPort);
    if (!kIsWeb) {
      final isolate = await Isolate.spawn(dataBaseEntryPoint, localArgs);
      return IsolateRemoteServer(isolate);
    } else {
      dataBaseEntryPoint(localArgs);
      return LocalRemoteServer();
    }
  }

  @override
  Future<RemoteServer> createRemoteServerBookEventDefault() async {
    assert(args != null);
    final localArgs = args!.copyWith(localSendPort);
    if (!kIsWeb) {
      final isolate = await Isolate.spawn(_multiIsolateEntryPoint, localArgs);
      return IsolateRemoteServer(isolate);
    } else {
      _multiIsolateEntryPoint(localArgs);
      return LocalRemoteServer();
    }
  }
}

/// 统一由主隔离创建，并分配[SendPortOwner]
void _multiIsolateEntryPoint(IsolateArgs args) {
  OneFile.runZoned(BookEventMultiIsolate(
    appPath: args.appPath,
    cachePath: args.cachePath,
    remoteSendPort: args.sendHandle,
  ).init);
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
  FutureOr<void> closeTask() => null;

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', lines: 2, onlyDebug: false);
  }

  @override
  void onError(msg, error) {
    Log.e('onError: $msg\n$error', onlyDebug: false);
  }
}
