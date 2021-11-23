// 任务隔离(remote):处理 数据库、网络任务
import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../base/complex_event.dart';
import 'complex_mixin.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';
import 'zhangdu_mixin.dart';

/// 所有的事件都在同一个隔离中运行
/// 缺点: 随着任务增加，处理消息的速度会变慢
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

/// 任务隔离(remote):处理 数据库、网络任务
/// 接受一个[SendPortOwner]处理数据库消息
class BookEventMultiIsolate
    with
        Resolve,
        ResolveMixin,
        // sender
        SendEventMixin,
        SendCacheMixin,
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

  SendPortOwner? sendPortOwner;

  @override
  bool listenResolve(message) {
    // 处理返回的消息/数据
    if (add(message)) return true;
    // 默认，分发事件
    return super.listenResolve(message);
  }

  @override
  void onResolvedFailed(message) {
    final msg = message.toString();
    Log.e('error: ${msg.substring(100, msg.length)}', onlyDebug: false);
  }

  @override
  void onResolveReceivedSendPort(ResolveName resolveName) {
    if (resolveName.name == 'database') {
      Log.w('received sendPort: ${resolveName.name}', onlyDebug: false);
      sendPortOwner = SendPortOwner(
          localSendPort: resolveName.sendPort, remoteSendPort: localSendPort);
      onResume();
      return;
    }
    super.onResolveReceivedSendPort(resolveName);
  }

  @override
  void onError(msg, error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  FutureOr<bool> onClose() async {
    sendPortOwner = null;
    return super.onClose();
  }

  @override
  SendEvent get sendEvent => this;

  @override
  SendPortOwner? getSendPortOwner(key) {
    switch (key.runtimeType) {
      case ComplexOnDatabaseEventMessage:
        return sendPortOwner;
      default:
    }
  }

  @override
  void send(message) {
    // 当前隔离需要处理的任务如网络任务，需要与数据库通信时，会使用此接口
    if (message is IsolateSendMessage || message is KeyController) {
      switch (message.type.runtimeType) {
        case ComplexOnDatabaseEventMessage:
          Log.w('type: ${getShortString(message)}');
          break;
        default:
          Log.e('error: ${getShortString(message)}', onlyDebug: false);
      }
    }

    super.send(message);
  }

  String getShortString(Object source) {
    final msg = source.toString();
    return 'msg: ${msg.substring(0, math.min(84, msg.length))}';
  }
}

/// 只处理数据库相关操作
class DatabaseImpl
    with
        Resolve,
        ResolveMixin,
        DatabaseMixin,
        ZhangduDatabaseMixin,
        ComplexOnDatabaseMixin,
        ZhangduComplexOnDatabaseMixin,
        BookCacheEventResolve, // 1
        BookContentEventResolve, // 2
        ZhangduDatabaseEventResolve, // 3
        ComplexOnDatabaseEventResolve // 4
{
  DatabaseImpl({
    required this.appPath,
    required this.useSqflite3,
    required this.remoteSendPort,
  });
  @override
  final SendPort remoteSendPort;

  @override
  final String appPath;
  @override
  final bool useSqflite3;

  @override
  void onResolvedFailed(message) {
    Log.e('error: $message', onlyDebug: false);
  }
}
