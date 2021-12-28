import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../repository.dart';
import 'base/export.dart';
import 'base/system_infos.dart';

/// 单一 隔离
/// 主隔离(native)
class SingleRepository extends Repository
    with SendEventMixin, SendCacheMixin, SendIsolateMixin {
  SingleRepository();

  @override
  Future<RemoteServer> onCreateIsolate(SendHandle remoteSendPort) async {
    final args = await initStartArgs();
    final localArgs = args.copyWith(remoteSendPort);

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
class SingleRepositoryOnServer extends Repository
    with SendEventMixin, SendCacheMixin, ListenMixin, SendMultiServerMixin {
  SingleRepositoryOnServer();

  @override
  Iterable<MapEntry<String, CreateRemoteServer>>
      createRemoteServerIterable() sync* {
    yield MapEntry<String, CreateRemoteServer>(
        bookEventDefault, Left(onCreateIsolate)); // 所有任务都由此处理
    yield MapEntry<String, CreateRemoteServer>(
        database, const Right(NullRemoteServer())); // 提供一个`handle`
    yield* super.createRemoteServerIterable();
  }

  Future<RemoteServer> onCreateIsolate() {
    return initStartArgs().then((args) {
      final localArgs = args.copyWith(localSendPort);

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

  BookEventIsolate(
    remoteSendPort: args.sendHandle,
    appPath: args.appPath,
    cachePath: args.cachePath,
  ).run();
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
        ZhangduDatabaseMixin,
        // net
        HiveDioMixin,
        NetworkMixin,
        ZhangduNetMixin,
        // complex on Database
        ComplexOnDatabaseMixin,
        ZhangduComplexOnDatabaseMixin,
        // complex
        ComplexMixin,
        ZhangduComplexMixin {
  BookEventIsolate({
    required this.remoteSendPort,
    required this.appPath,
    required this.cachePath,
  });

  @override
  final SendHandle remoteSendPort;
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
