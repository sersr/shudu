import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';

typedef WaitCallback = Future<void> Function();

/// [TaskEntry._run]
typedef ResultTimeCallback = Future<EventStatus?> Function(WaitCallback wait, TaskEntry task);

/// 判断 [EventStatus]
typedef BoolTimeOutCallback = bool Function(WaitCallback);

class EventLooper {
  static EventLooper? _instance;

  static EventLooper get instance {
    _instance ??= EventLooper();
    return _instance!;
  }

  var _frameId = 0;

  final now = Stopwatch()..start();

  int get stopwatch => now.elapsedMicroseconds;

  SchedulerBinding get scheduler => SchedulerBinding.instance!;

  bool _addPersistent = false;

  set addPersistent(bool v) {
    if (_addPersistent) return;
    _addPersistent = v;
    if (_addPersistent) {
      WidgetsFlutterBinding.ensureInitialized();

      scheduler.addPersistentFrameCallback((_) {
        if (_frameId > 10000) _frameId = 0;
        _frameId++;
      });
    }
  }

  final _taskLists = <TaskEntry>{};

  /// 安排任务，任务消耗时间查询
  ///
  /// 添加一个任务到轮询任务中
  Future<bool> scheduleEventTask<T>(ResultTimeCallback callback,
      {bool eventOnly = false, double frameThreshold = 2, String debugLabel = ''}) async {
    final _task = TaskEntry<T>(callback, eventOnly, this, frameThreshold, debugLabel);

    _taskLists.add(_task);
    run();
    return _task.future;
  }

  Future? _runner;
  Future? get runner => _runner;

  void run() async {
    if (runner != null || _taskLists.isEmpty) return;

    _runner ??= looper()
      ..whenComplete(() {
        _runner = null;
        Log.i('runner done...');
      });
  }

  Future<bool> looper() async {
    while (_taskLists.isNotEmpty) {
      final tasks = List.of(_taskLists);

      for (final _t in tasks) {
        await releaseUI;

        await _eventRun(_t);
      }
    }

    return true;
  }

  // 运行任务
  //
  // 提供时间消耗及等待其他任务
  Future<bool> _eventRun(TaskEntry task) => eventCallback(task._run, label: 'eventRun');

  Future<T> eventCallback<T>(FutureOr<T> Function(WaitCallback wait) callback, {label = 'eventCallback'}) async {
    var start = stopwatch;
    var low = 0;
    final result = await callback(() async {
      final use = (stopwatch - start) / 1000;
      start = stopwatch;
      // 回到事件队列，让出资源
      await releaseUI;

      /// 等待时间过长意味着有其他任务正在执行，如：drawFrame，其他事件
      final wait = (stopwatch - start) / 1000;
      // 耗时过小不打印
      if (use > 0.5) {
        var i = Log.info;

        if (use > 3) {
          i = Log.error;
        } else if (use > 1) {
          i = Log.warn;
        }
        Log.log(i, '$label use: ${use.toStringAsFixed(3)}ms wait: ${wait.toStringAsFixed(3)}ms low: $low');
        low = 0;
      } else {
        low++;
      }
      start = stopwatch;
    });

    Log.i('$label end: ${((stopwatch - start) / 1000).toStringAsFixed(3)}ms low: $low');

    return result;
  }

//   Future<bool> frameCallback(TaskEntry task) async {
//     final completer = Completer<bool>();
//     var threshold = task.frameThreshold;
//     assert(() {
//       // debug 模式下，耗时会比较大
//       threshold = 6.0;
//       return true;
//     }());
//     final debugLabel = task.debugLabel;

//     scheduler.scheduleFrameCallback((_) {
//       if (stop) {
//         completer.complete(false);
//         return;
//       }
//       var start = stopwatch;
//       scheduler.addPostFrameCallback((timeStamp) async {
//         final at = stopwatch;
//         final drawframe = (at - start) / 1000;
//         if (drawframe > threshold || stop) {
//           completer.complete(false);
//           // assert(
//           Log.w('Id: |$_frameId| $debugLabel: drawFrame: ${drawframe.toStringAsFixed(3)}ms : failed'
//               // )
//               );
//           return;
//         }

//         final success = await eventRun(task, label: 'frameCallback');

//         completer.complete(success);
//         // assert(
//         // Log.log(
//         //     success ? Log.info : Log.warn,
//         //     'Id: |$_frameId| $debugLabel: drawFrame: ${drawframe.toStringAsFixed(3)}ms,'
//         //     ' use: ${((now.elapsedMicroseconds - at) / 1000).toStringAsFixed(3)}ms~'
//         // )
//         // );
//       });
//     });
//     return completer.future;
//   }
}

class TaskEntry<T> {
  TaskEntry(this.callback, this.eventOnly, this._looper, this.frameThreshold, this.debugLabel);

  final EventLooper _looper;
  final ResultTimeCallback callback;
  final String debugLabel;
  final double frameThreshold;
  bool eventOnly;
  final _completer = Completer<bool>();

  T? data;

  int? _start;

  Future<bool> get future => _completer.future;

  Future<bool> _run(WaitCallback wait) async {
    final result = await callback(wait, this);

    switch (result) {
      case EventStatus.ignoreAndRemove:
        _completer.complete(false);
        _looper._taskLists.remove(this);
        break;

      case EventStatus.timeout:
        // 超时，退出循环
        return false;

      case EventStatus.done:
      default:
        _completer.complete(true);
        _looper._taskLists.remove(this);
        assert(Log.i('done...'));
    }

    return true;
  }
}

enum EventStatus {
  done,
  ignoreAndRemove,
  timeout,
}

Future<void> get releaseUI => Future.delayed(Duration.zero);
