import 'dart:async';

import 'package:useful_tools/common.dart';

class Time {
  Time();
  static final defaultTime = Time();
  final _stop = Stopwatch();
  int get currentMicroseconds {
    if (!_stop.isRunning) {
      _stop.start();
    }
    return _stop.elapsedMicroseconds;
  }

  double useTimeMs(int lastTime) {
    return (currentMicroseconds - lastTime) / 1000;
  }
}

Time get stopTime => Time.defaultTime;

extension UseTimeMs on int {
  double get useTimeMs {
    return stopTime.useTimeMs(this);
  }
}

extension UseTime<T> on Future<T> {
  /// 从正式开始异步开始计算
  /// 前面同步块区域是没有计算其中
  Future<T> useTimeMs(void Function(T current, double useTime) end) {
    return onWait<int>(() => stopTime.currentMicroseconds,
        (current, use) => end(current, use.useTimeMs));
  }

  Future<T> get logi => log(Log.info);
  Future<T> get logw => log(Log.warn);
  Future<T> get loge => log(Log.error);

  Future<T> log(int level) {
    return useTimeMs((current, useTime) {
      Log.i('use: $useTime ms', onlyDebug: false);
    });
  }

  Future<T> onWait<D>(D Function() start, void Function(T current, D end) end) {
    final d = start();
    then((v) => end(v, d));
    return this;
  }
}
