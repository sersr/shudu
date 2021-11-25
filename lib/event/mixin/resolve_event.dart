// 任务隔离(remote):处理 数据库、网络任务
import 'dart:isolate';
import 'dart:math' as math;

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import 'base/complex_mixin.dart';
import 'base/network_mixin.dart';
import 'base/zhangdu_mixin.dart';
import 'multi_Isolate_repository.dart';

/// 与 [MultiIsolateRepository] 配合使用
/// 任务隔离(remote):处理 数据库、网络任务
/// 接受一个[SendPortOwner]处理数据库消息
class BookEventMultiIsolate
    with
        Resolve,
        ResolveMixin,
        // sender
        SendEventMixin,
        // SendEventPortMixin,
        SendCacheMixin,
        MultiBookEventDefaultResolveMixin,
        // ---- 在当前隔离处理 ------
        CustomEventResolve,
        ZhangduNetEventResolve,
        ComplexEventResolve,
        ZhangduComplexEventResolve,
        MultiBookEventDefaultOnResumeMixin, // 初始化：Resolve协议验证
        // -- SendPortOwner 代理----
        ComplexOnDatabaseEventMessager, // 初始化：Messager协议验证
        MultiDatabaseOwnerMixin, // 需要一个 `Database`的协议发送消息
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
  SendPortOwner? getSendPortOwner(key) {
    final owner = super.getSendPortOwner(key);
    if (owner == null) {
      Log.e('owner == null,需要与$key匹配的`SendPortOwner`发送消息', onlyDebug: false);
    }
    return owner;
  }

  @override
  void onResolvedFailed(message) {
    Log.e('error: ${getShortString(message)}', onlyDebug: false);
  }

  @override
  void onError(msg, error) {
    Log.e('onError: $msg\n$error', onlyDebug: false);
  }

  String getShortString(Object source) {
    final msg = source.toString();
    return 'msg: ${msg.substring(0, math.min(84, msg.length))}';
  }
}
