import 'dart:isolate';
import 'package:nop_db/isolate_event.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../base/book_event.dart';
import '../base/complex_mixin.dart';
import '../base/database_mixin.dart';
import '../base/network_mixin.dart';
import '../base/zhangdu_mixin.dart';

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
