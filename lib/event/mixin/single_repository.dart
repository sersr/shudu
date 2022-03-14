import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/export.dart';
import '../repository.dart';
import 'base/export.dart';
import 'base/system_infos.dart';

/// 单一 隔离
/// 主隔离(native)
class SingleRepository extends Repository
    with SendEventMixin, SendCacheMixin, SendIsolateMixin {
  SingleRepository();

  @override
  Future<RemoteServer> onCreateServer(SendHandle remoteSendHandle) async {
    final args = await initStartArgs();
    final localArgs = args.copyWith(remoteSendHandle);

    if (!kIsWeb) {
      final newIsolate =
          await Isolate.spawn(singleIsolateEntryPoint, localArgs);
      return IsolateRemoteServer(newIsolate);
    } else {
      singleIsolateEntryPoint(localArgs);
      return LocalRemoteServer();
    }
  }
}

/// fake
/// single Isolate
class SingleRepositoryWithServer extends Repository
    with SendEventMixin, SendCacheMixin, ListenMixin, SendMultiServerMixin {
  SingleRepositoryWithServer();

  @override
  List<MapEntry<String, CreateRemoteServer>> createRemoteServerIterable() {
    return super.createRemoteServerIterable()
      ..add(MapEntry<String, CreateRemoteServer>(
          bookEventDefault, Left(onCreateIsolate))) // 所有任务都由此处理
      ..add(MapEntry<String, CreateRemoteServer>(
          database, const Right(NullRemoteServer()))); // 提供一个`handle`
  }

  Future<RemoteServer> onCreateIsolate() {
    return initStartArgs().then((args) {
      final localArgs = args.copyWith(localSendHandle);

      if (!kIsWeb) {
        return Isolate.spawn(singleIsolateEntryPoint, localArgs)
            .then(IsolateRemoteServer.wrap);
      } else {
        singleIsolateEntryPoint(localArgs);
        return LocalRemoteServer();
      }
    });
  }
}

void singleIsolateEntryPoint(IsolateArgs args) {
  Log.i(args, onlyDebug: false);
  OneFile.runZoned(BookEventIsolate(
    remoteSendHandle: args.sendHandle,
    appPath: args.appPath,
    cachePath: args.cachePath,
  ).run);
}

/// single Isolate
///
/// 所有的事件都在同一个隔离中运行
/// 缺点: 随着任务增加，处理消息的速度会变慢
/// 与[SingleRepository]配合使用
class BookEventIsolate extends BookEventResolveMain
    with
        // base
        DatabaseMixin,
        // net
        HiveDioMixin,
        NetworkMixin,
        // complex on Database
        ComplexOnDatabaseMixin,
        // complex
        ComplexMixin {
  BookEventIsolate({
    required this.remoteSendHandle,
    required this.appPath,
    required this.cachePath,
  });

  @override
  final SendHandle remoteSendHandle;
  @override
  final String appPath;
  @override
  final String cachePath;

  @override
  void onError(msg, error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', onlyDebug: false);
  }
}
