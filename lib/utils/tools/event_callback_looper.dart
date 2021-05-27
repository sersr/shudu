import 'dart:async';
import 'package:flutter/scheduler.dart';

import '../utils.dart';

typedef FutureOrVoidCallback = FutureOr<void> Function();

typedef WaitCallback = Future<void> Function(
    [FutureOrVoidCallback? closure, String label]);

/// [TaskEntry._run]
typedef EventCallback = Future<void> Function();

// typedef RunCallback<T> = Future<T> Function();

class EventLooper {
  static EventLooper? _instance;

  static EventLooper get instance {
    _instance ??= EventLooper();
    return _instance!;
  }

  // var _frameId = 0;

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

  static const zoneWait = 'eventWait';
  // 运行任务
  //
  // 提供时间消耗及等待其他任务
  Future<void> _eventRun(TaskEntry task) =>
      eventCallback(task._run, debugLabel: 'eventRun');

  Future<void> eventCallback(EventCallback callback,
      {debugLabel = 'eventCallback'}) async {
    int? start;
    var low = 0;
    var waitNum = 0;

    Future<void> wait(
        [FutureOrVoidCallback? closure, String label = '']) async {
      start ??= stopwatch;

      if (closure != null) closure();

      final use = (stopwatch - start!) / 1000;
      var waitUs = 0;
      var loopCount = 0;

      /// 回到事件队列，让出资源
      /// 等待空闲
      /// 等待时间过长意味着有其他任务正在执行，如：drawFrame，其他事件
      do {
        if (loopCount > 1000) break;

        final _s = stopwatch;

        await releaseUI;

        waitUs = stopwatch - _s;
        loopCount++;
      } while (waitUs >= 1000);

      waitNum += loopCount;

      // 耗时过小不打印
      if (use > 0.5) {
        var i = Log.info;

        if (use > 3) {
          i = Log.error;
        } else if (use > 1) {
          i = Log.warn;
        }
        Log.log(
            i,
            '$debugLabel use: ${use.toStringAsFixed(3)}ms '
            'wait: ${(waitUs / 1000).toStringAsFixed(3)}ms low: $low |$label',
            showPath: false);
        low = 0;
      } else {
        low++;
      }
      start = stopwatch;
    }

    ;

    await runZoned(callback, zoneValues: {zoneWait: wait});

    Log.i(
        '$debugLabel end: ${((stopwatch - (start ?? 0)) / 1000).toStringAsFixed(3)}ms'
        ' low: $low, wait: $waitNum');

    // return result;
  }

  Future<void> wait([FutureOrVoidCallback? closure, label = '']) {
    final _w = Zone.current[EventLooper.zoneWait];
    if (_w is WaitCallback) {
      return _w(closure, label);
    }
    if (closure != null) closure();
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
