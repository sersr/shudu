import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';

typedef WaitCallback = Future<void> Function([String label]);

/// [TaskEntry._run]
typedef EventCallback = Future<EventStatus?> Function(WaitCallback wait);

typedef WaitGetterCallback<T> = Future<T> Function(WaitCallback wait);

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
  Future<bool> scheduleEventTask<T>(
    EventCallback callback, {
    String debugLabel = '',
  }) async {
    final _task = TaskEntry<T>(callback, this, debugLabel);

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
  Future<bool> _eventRun(TaskEntry task) =>
      eventCallback(task._run, debugLabel: 'eventRun');

  Future<T> eventCallback<T>(WaitGetterCallback<T> callback,
      {debugLabel = 'eventCallback'}) async {
    var start = stopwatch;
    var low = 0;
    var waitNum = 0;

    final result = await callback(([String label = '']) async {
      final use = (stopwatch - start) / 1000;
      var wait = 0;
      var loopCount = 0;

      /// 回到事件队列，让出资源
      /// 等待空闲
      /// 等待时间过长意味着有其他任务正在执行，如：drawFrame，其他事件
      do {
        if (loopCount > 10) break;

        final _s = stopwatch;

        await releaseUI;

        wait = stopwatch - _s;
        loopCount++;
      } while (wait >= 2000);

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
            'wait: ${(wait / 1000).toStringAsFixed(3)}ms low: $low $label');
        low = 0;
      } else {
        low++;
      }
      start = stopwatch;
    });

    Log.i(
        '$debugLabel end: ${((stopwatch - start) / 1000).toStringAsFixed(3)}ms'
        ' low: $low, wait: $waitNum');

    return result;
  }
}

class TaskEntry<T> {
  TaskEntry(this.callback, this._looper, this.debugLabel);

  final EventLooper _looper;
  final EventCallback callback;
  final String debugLabel;

  final _completer = Completer<bool>();

  Future<bool> get future => _completer.future;

  Future<bool> _run(WaitCallback wait) async {
    final result = await callback(wait);

    switch (result) {
      case EventStatus.ignoreAndRemove:
        _completer.complete(false);
        break;
      case EventStatus.done:
      default:
        _completer.complete(true);
        assert(Log.i('done...'));
    }
    _looper._taskLists.remove(this);

    return true;
  }
}

enum EventStatus {
  done,
  ignoreAndRemove,
}

Future<void> get releaseUI => Future.delayed(Duration.zero);
