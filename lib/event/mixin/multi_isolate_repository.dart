import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nop/nop.dart';

import '../base/export.dart';
import '../repository.dart';
import 'base/export.dart';
import 'base/system_infos.dart';
import 'database_only_impl.dart';

class MultiIsolateRepository extends Repository
    with
        SendEventPortStreamMixin,
        // SendEventPortMixin,
        SendCacheMixin {
  // [appPath, cachePath]
  BookIsolateArgs? args;

  @override
  FutureOr<void> onInitStart() async {
    args = await initStartArgs();
  }

  @override
  RemoteServer get databaseRemoteServer {
    assert(args != null);
    if (!kIsWeb) {
      return IsolateRemoteServer<BookIsolateArgs>(
          entryPoint: dataBaseEntryPoint, args: getArgs(args!));
    } else {
      return LocalRemoteServer(
          entryPoint: dataBaseEntryPoint, args: getArgs(args!));
    }
  }

  @override
  RemoteServer get bookRemoteServer {
    assert(args != null);
    if (!kIsWeb) {
      return IsolateRemoteServer(
          entryPoint: _multiIsolateEntryPoint,
          args: getArgs(args!),
          debugName: 'book_remote_server');
    } else {
      return LocalRemoteServer(
          entryPoint: _multiIsolateEntryPoint, args: getArgs(args!));
    }
  }
}

/// 统一由主隔离创建，并分配[SendPortOwner]
Runner _multiIsolateEntryPoint(ServerConfigurations<BookIsolateArgs> configs) {
  Log.logPathFn = (path) => path;
  return Runner(runner: BookEventMultiIsolate(configurations: configs));
}

/// 与 [MultiIsolateRepository] 配合使用
/// 任务隔离(remote):处理 数据库、网络任务
class BookEventMultiIsolate extends MultiBookResolveMain
    with
        // senders
        SendEventPortStreamMixin,
        // SendInitCloseMixin,
        // net
        HiveDioMixin,
        NetworkMixin,
        // complex
        ComplexMixin {
  BookEventMultiIsolate({
    required ServerConfigurations<BookIsolateArgs> configurations,
  })  : appPath = configurations.args.appPath,
        cachePath = configurations.args.appPath,
        super(configurations: configurations);

  @override
  final String appPath;
  @override
  final String cachePath;

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', lines: 2, onlyDebug: false);
  }

  @override
  void onError(msg, error) {
    Log.e('onError: $msg\n$error', onlyDebug: false);
  }
}
