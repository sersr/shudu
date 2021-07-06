import 'dart:async';
import 'package:flutter/scheduler.dart';

import '../utils.dart';

typedef FutureOrVoidCallback = FutureOr<void> Function();

typedef WaitCallback = Future<void> Function(
    [FutureOrVoidCallback? closure, String label]);

/// [TaskEntry._run]
typedef EventCallback = Future<void> Function();

/// async tasks => sync tasks
///
/// 以队列的形式进行 异步任务。
///
/// 异步的本质：将回调函数注册到下一次事件队列中，在本次循环后调用
/// [await]: 由系统注册  (async/future_impl.dart#_thenAwait)
///
/// 在同一次事件循环中执行上一次的异步任务，如果上一次的异步任务过多有可能导致本次循环
/// 占用过多的 cpu 资源，导致渲染无法及时，造成卡顿。
class EventLooper {
  static EventLooper? _instance;

  static EventLooper get instance {
    _instance ??= EventLooper();
    return _instance!;
  }

  final now = Stopwatch()..start();

  int get stopwatch => now.elapsedMicroseconds;

  SchedulerBinding get scheduler => SchedulerBinding.instance!;

  final _taskLists = <TaskEntry>{};

  /// 安排任务
  ///
  /// 队列模式
  Future<void> addEventTask<T>(EventCallback callback) async {
    final _task = TaskEntry<T>(callback, this);

    _taskLists.add(_task);
    run();
    return _task.future;
  }

  Future? _runner;
  Future? get runner => _runner;

  void run() async {
    if (runner != null || _taskLists.isEmpty) return;

    _runner ??= looper()..whenComplete(() => _runner = null);
  }

  Future<bool> looper() async {
    while (_taskLists.isNotEmpty) {
      final tasks = List.of(_taskLists);

      for (final _t in tasks) {
        await releaseUI;

        await eventRun(_t);
      }
    }

    return true;
  }

  static const zoneWait = 'eventWait';
  static const zoneTask = 'eventTask';
  // 运行任务
  //
  // 提供时间消耗及等待其他任务
  Future<void> eventRun(TaskEntry task) {
    return runZoned(task._run, zoneValues: {zoneWait: _wait, zoneTask: task});
  }

  Future<void> _wait([FutureOrVoidCallback? onLoop, String label = '']) async {
    final _task = currentTask;
    if (_task != null && _task.async) {
      var count = 0;
      while (scheduler.hasScheduledFrame) {
        if (count > 5000) break;

        /// 回到事件队列，让出资源
        await releaseUI;
        onLoop?.call();
        if (!_task.async) break;
        count++;
      }
    }
    await releaseUI;
  }

  Future<void> wait([FutureOrVoidCallback? closure, label = '']) async {
    final _w = Zone.current[zoneWait];
    if (_w is WaitCallback) {
      return _w(closure, label);
    }
    if (closure != null) await closure();
    return releaseUI;
  }

  TaskEntry? get currentTask {
    final _z = Zone.current[zoneTask];
    if (_z is TaskEntry) return _z;
  }

  bool get async {
    final _z = currentTask;
    if (_z is TaskEntry) return _z.async;
    return false;
  }

  set async(bool v) {
    final _z = currentTask;
    if (_z is TaskEntry) _z.async = v;
  }
}

class TaskEntry<T> {
  TaskEntry(this.callback, this._looper);

  final EventLooper _looper;
  final EventCallback callback;

  final _completer = Completer<void>();
  var async = true;
  Future<void> get future => _completer.future;

  Future<void> _run() async {
    await callback();

    _completer.complete();
    _looper._taskLists.remove(this);
  }
}

enum EventStatus {
  done,
  ignoreAndRemove,
}

Future<void> get releaseUI => release(Duration.zero);
Future<void> release(Duration time) => Future.delayed(time);
