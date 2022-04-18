import 'package:flutter/foundation.dart';
import 'package:nop/nop.dart';

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

    if (!kIsWeb) {
      return IsolateRemoteServer(
          entryPoint: singleIsolateEntryPoint,
          args:
              IsolateConfigurations(args: args, sendHandle: remoteSendHandle));
    } else {
      return LocalRemoteServer(
          entryPoint: singleIsolateEntryPoint,
          args:
              IsolateConfigurations(args: args, sendHandle: remoteSendHandle));
    }
  }
}

void singleIsolateEntryPoint(IsolateConfigurations<BookIsolateArgs> configs) {
  Log.i(configs, onlyDebug: false);
  OneFile.runZoned(BookEventIsolate(
    remoteSendHandle: configs.sendHandle,
    appPath: configs.args.appPath,
    cachePath: configs.args.cachePath,
  ).run);
}

/// single Isolate
///
/// 所有的事件都在同一个隔离中运行
/// 缺点: 随着任务增加，处理消息的速度会变慢
/// 与[SingleRepository]配合使用
class BookEventIsolate extends MultiBookResolveMain
    with
        BookEvent,
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
