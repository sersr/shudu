import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

typedef FutureOrVoidCallback = FutureOr<void> Function();

typedef WaitCallback = Future<void> Function(
    [FutureOrVoidCallback? closure, String label]);

/// [_TaskEntry._run]
typedef EventCallback<T> = FutureOr<T> Function();

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
  EventLooper({this.parallels = 1});
  static EventLooper get instance {
    _instance ??= EventLooper();
    return _instance!;
  }

  final int parallels;
  final now = Stopwatch()..start();

  int get stopwatch => now.elapsedMicroseconds;

  SchedulerBinding get scheduler => SchedulerBinding.instance!;

  final _taskLists = <_TaskKey, _TaskEntry>{};

  Future<T> _addEventTask<T>(EventCallback<T> callback,
      {bool onlyLastOne = false}) {
    var _task = _TaskEntry<T>(callback, this, onlyLastOne: onlyLastOne);
    final key = _task.key;

    if (!_taskLists.containsKey(key)) {
      _taskLists[key] = _task;
    } else {
      _task = _taskLists[key]! as _TaskEntry<T>;
    }

    run();
    return _task.future;
  }

  /// 安排任务
  ///
  /// 队列模式
  Future<T> addEventTask<T>(EventCallback<T> callback) =>
      _addEventTask<T>(callback);

  /// [onlyLastOne] 模式
  /// 由于此模式下，可能会丢弃任务，因此无返回值
  Future<void> addOneEventTask(EventCallback<void> callback) =>
      _addEventTask<void>(callback, onlyLastOne: true);

  Future<void>? _runner;
  Future<void>? get runner => _runner;

  void run() {
    _runner ??= looper()..whenComplete(() => _runner = null);
  }

  @protected
  Future<void> looper() async {
    final _f = <_TaskKey, Future>{};
    // 由于之前操作都在 `同步` 中执行
    // 在下一次事件循环时处理任务
    await releaseUI;

    while (_taskLists.isNotEmpty) {
      final tasks = List.of(_taskLists.values);
      final last = tasks.last;

      for (final _t in tasks) {
        if (!_t.onlyLastOne || _t == last) {
          if (parallels > 1) {
            _f.putIfAbsent(_t.key, () {
              // 转移管理权
              _taskLists.remove(_t.key);
              // 已完成的任务会自动移除
              return eventRun(_t)..whenComplete(() => _f.remove(_t.key));
            });

            // 达到 parallels 数        ||   最后一个
            if (_f.length >= parallels || _t == last) {
              // 未达到 parallels 数并且是最后一个，
              // 还有任务待刷新，加入队列

              if (_t == last &&
                  _f.length < parallels &&
                  _taskLists.isNotEmpty) {
                break;
              }

              await Future.wait(_f.values);
              _f.clear();
              await releaseUI;

              // 完成一次 ‘并行’ 任务，刷新当前任务
              break;
            }
          } else {
            await eventRun(_t);
            await releaseUI;
          }
        } else {
          _t.completed();
        }
      }
    }
    assert(_f.isEmpty);
  }

  static const _zoneWait = 'eventWait';
  static const _zoneTask = 'eventTask';
  // 运行任务
  //
  // 提供时间消耗及等待其他任务
  Future<void> eventRun(_TaskEntry task) {
    return runZoned(task._run, zoneValues: {_zoneWait: _wait, _zoneTask: task});
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
    final _w = Zone.current[_zoneWait];
    if (_w is WaitCallback) {
      return _w(closure, label);
    }
    if (closure != null) await closure();
    return releaseUI;
  }

  _TaskEntry? get currentTask {
    final _z = Zone.current[_zoneTask];
    if (_z is _TaskEntry) return _z;
  }

  bool get async {
    final _z = currentTask;
    if (_z is _TaskEntry) return _z.async;
    return false;
  }

  set async(bool v) {
    final _z = currentTask;
    if (_z is _TaskEntry) _z.async = v;
  }
}

class _TaskEntry<T> {
  _TaskEntry(this.callback, this._looper, {this.onlyLastOne = false});

  final EventLooper _looper;
  final EventCallback<T> callback;
  Object? ident;
  final bool onlyLastOne;
  late final key = _TaskKey<T>(_looper, callback, onlyLastOne);

  final _completer = Completer<T>();
  var async = true;
  Future<T> get future => _completer.future;

  Future<void> _run() async {
    final result = await callback();
    completed(result);
  }

  void completed([T? result]) {
    _completer.complete(result);
    _looper._taskLists.remove(key);
  }
}

class _TaskKey<T> {
  _TaskKey(this._looper, this.callback, this.onlyLastOne);
  final EventLooper _looper;
  final EventCallback callback;
  final bool onlyLastOne;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TaskKey<T> &&
            callback == other.callback &&
            _looper == other._looper &&
            onlyLastOne == other.onlyLastOne;
  }

  @override
  int get hashCode => hashValues(callback, _looper, onlyLastOne, T);
}

enum EventStatus {
  done,
  ignoreAndRemove,
}

Future<void> get releaseUI => release(Duration.zero);
Future<void> release(Duration time) => Future.delayed(time);
