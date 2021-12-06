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
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) async {
    final args = await initStartArgs();

    // [remoteSendPort, appPath, cachePath, useSqflite3]
    final newIsolate =
        await Isolate.spawn(singleIsolateEntryPoint, [remoteSendPort, ...args]);

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final memory = await getMemoryInfo();
      final freeMem = memory.freeMem;
      const size = 1.5 * 1024;
      if (freeMem != null && freeMem < size) {
        CacheBinding.instance!.imageRefCache!.length = 250;
      }
    }
    return newIsolate;
  }
}

void singleIsolateEntryPoint(List args) async {
  final remoteSendPort = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final useSqflite3 = args[3];

  Log.i('$appPath | $cachePath | $useSqflite3', onlyDebug: false);

  BookEventIsolate(
    remoteSendPort: remoteSendPort,
    appPath: appPath,
    cachePath: cachePath,
    useSqflite3: useSqflite3,
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
    required this.useSqflite3,
  });

  @override
  final SendPort remoteSendPort;
  @override
  final String appPath;
  @override
  final String cachePath;

  @override
  final bool useSqflite3;

  @override
  void onError(msg, error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', onlyDebug: false);
  }
}
