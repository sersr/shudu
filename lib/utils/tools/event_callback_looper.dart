import 'dart:async';
import 'package:flutter/scheduler.dart';

import '../utils.dart';

typedef FutureOrVoidCallback = FutureOr<bool> Function();

typedef WaitCallback = Future<void> Function(
    [FutureOrVoidCallback? closure, String label]);

/// [TaskEntry._run]
typedef EventCallback = Future<void> Function();

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
  Future<void> scheduleEventTask<T>(EventCallback callback) async {
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

        await _eventRun(_t);
      }
    }

    return true;
  }

  static const zoneWait = 'eventWait';
  // 运行任务
  //
  // 提供时间消耗及等待其他任务
  Future<void> _eventRun(TaskEntry task) =>
      eventCallback(task._run, debugLabel: 'eventRun');

  Future<void> eventCallback(EventCallback callback,
      {debugLabel = 'eventCallback'}) async {
    int? start;

    var waitNum = 0;
    var low = 0, high = 0, med = 0;
    Future<void> wait(
        [FutureOrVoidCallback? closure, String label = '']) async {
      start ??= stopwatch;

      final use = (stopwatch - start!) / 1000;

      if (use > 3) {
        high++;
      } else if (use > 1) {
        med++;
      } else if (use > 0.5) {
        low++;
      }

      var loopCount = 0;
      var waitUs = 0;

      /// 回到事件队列，让出资源
      do {
        if (loopCount > 100) break;

        final _start = stopwatch;
        await releaseUI;

        if (closure != null && await closure()) break;

        waitUs = stopwatch - _start;

        loopCount++;
      } while (waitUs >= 2000);

      waitNum += loopCount;

      start = stopwatch;
    }

    await runZoned(callback, zoneValues: {zoneWait: wait});

    Log.i('$debugLabel low: ${getV(low)}, med: ${getV(med)}, '
        'high: ${getV(high)}, wait: $waitNum');
  }

  String getV(int v) => v == 0 ? '' : '$v';

  Future<void> wait([FutureOrVoidCallback? closure, label = '']) async {
    final _w = Zone.current[zoneWait];
    if (_w is WaitCallback) {
      return _w(closure, label);
    }
    if (closure != null) await closure();
    return releaseUI;
  }
}

class TaskEntry<T> {
  TaskEntry(this.callback, this._looper);

  final EventLooper _looper;
  final EventCallback callback;

  final _completer = Completer<void>();

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

Future<void> get releaseUI => Future.delayed(Duration.zero);
Future<void> release(int time) => Future.delayed(Duration(milliseconds: time));
