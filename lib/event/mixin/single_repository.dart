import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../repository.dart';
import 'base/base.dart';

/// 单一 隔离
/// 主隔离(native)
class SingleRepository extends Repository
    with SendEventMixin, SendCacheMixin, SendIsolateMixin {
  SingleRepository();

  @override
  Future<RemoteServer> onCreateIsolate(SendHandle remoteSendPort) async {
    final args = await initStartArgs();
    if (!kIsWeb) {
      // [remoteSendPort, appPath, cachePath]
      final newIsolate = await Isolate.spawn(
          singleIsolateEntryPoint, [remoteSendPort, ...args]);
      return IsolateRemoteServer(newIsolate);
    } else {
      singleIsolateEntryPoint([remoteSendPort, ...args]);
      return RemoteServer();
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
    yield MapEntry(bookEventDefault, onCreateIsolate); // 所有任务都由此处理
    yield MapEntry(database, () async => RemoteServer()); // 提供一个`handle`
    yield* super.createRemoteServerIterable();
  }

  Future<RemoteServer> onCreateIsolate() async {
    final args = await initStartArgs();
    if (!kIsWeb) {
      // [remoteSendPort, appPath, cachePath]
      final newIsolate = await Isolate.spawn(
          singleIsolateEntryPoint, [localSendPort, ...args]);
      return IsolateRemoteServer(newIsolate);
    } else {
      singleIsolateEntryPoint([localSendPort, ...args]);
      return RemoteServer();
    }
  }
}

void singleIsolateEntryPoint(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];

  Log.i('$appPath | $cachePath', onlyDebug: false);

  BookEventIsolate(
    remoteSendPort: remoteSendPort,
    appPath: appPath,
    cachePath: cachePath,
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
