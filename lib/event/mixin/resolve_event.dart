// 任务隔离(remote):处理 数据库、网络任务
import 'dart:isolate';
import 'dart:math' as math;

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../base/complex_event.dart';
import 'base/complex_mixin.dart';
import 'base/database_mixin.dart';
import 'base/network_mixin.dart';
import 'base/zhangdu_mixin.dart';
import 'multi_repository.dart';
import 'multi_Isolate_repository.dart';
import 'single_repository.dart';

/// 所有的事件都在同一个隔离中运行
/// 缺点: 随着任务增加，处理消息的速度会变慢
/// 与[SingleRepository]配合使用
class BookEventIsolate extends BookEventResolveMain
    with
        ResolveMixin,
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

/// 与 [MultiRepository] 或 [MultiIsolateRepository] 配合使用
/// 任务隔离(remote):处理 数据库、网络任务
/// 接受一个[SendPortOwner]处理数据库消息
class BookEventMultiIsolate
    with
        Resolve,
        ResolveMixin,
        MultiBookEventDefaultOnResumeMixin, // 提供`SendPortName`匹配
        // sender
        SendEventMixin,
        SendCacheMixin,
        MultiDatabaseResolveMixin,
        // ---- 在当前隔离处理 ------
        CustomEventResolve,
        ZhangduNetEventResolve,
        ComplexEventResolve,
        ZhangduComplexEventResolve,
        // -- SendPortOwner 代理----
        ComplexOnDatabaseEventMessager,
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
  void onResolvedFailed(message) {
    Log.e('error: ${getShortString(message)}', onlyDebug: false);
  }

  @override
  void onError(msg, error) {
    Log.e('onError: $msg\n$error', onlyDebug: false);
  }

  @override
  SendPortOwner? getSendPortOwner(key) {
    switch (key.runtimeType) {
      case ComplexOnDatabaseEventMessage:
        return databaseIsolateSendPortOwner;
      default:
        Log.e('error: unImpl $key', onlyDebug: false);
    }
    super.getSendPortOwner(key);
  }

  // @override
  // void send(message) {
  //   // 当前隔离需要处理的任务如网络任务，需要与数据库通信时，会使用此接口
  //   if (message is IsolateSendMessage || message is KeyController) {
  //     switch (message.type.runtimeType) {
  //       case ComplexOnDatabaseEventMessage:
  //         Log.w('type: ${getShortString(message)}');
  //         break;
  //       default:
  //         Log.e('error: ${getShortString(message)}', onlyDebug: false);
  //     }
  //   }

  //   super.send(message);
  // }

  String getShortString(Object source) {
    final msg = source.toString();
    return 'msg: ${msg.substring(0, math.min(84, msg.length))}';
  }
}
