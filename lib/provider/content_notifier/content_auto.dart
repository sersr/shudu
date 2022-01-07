import 'dart:async';

import 'package:flutter/Material.dart';
import 'package:flutter/scheduler.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:wakelock/wakelock.dart';

import 'content_base.dart';
import 'content_task.dart';

/// 自动滚动阅读实现
mixin ContentAuto on ContentDataBase, ContentTasks {
  Duration lastStamp = Duration.zero;

  late final autoRun = AutoRun(_autoTick, () => lastStamp = Duration.zero);

  void auto() {
    if (config.value.axis == Axis.vertical) {
      _auto();
      return;
    }
    setPrefs(config.value.copyWith(axis: Axis.vertical));
    if (controller != null && controller!.axis == Axis.vertical) {
      _auto();
      return;
    }
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (controller != null && controller!.axis == Axis.vertical) {
        timer.cancel();
        _auto();
      }
      if (initQueue.actived) return;

      if (timer.tick > 5) timer.cancel();
    });
  }

  void _auto() {
    if (config.value.axis == Axis.horizontal) return;
    autoRun.value = !autoRun.value;
    if (autoRun.value) {
      controller?.setPixels(controller!.pixels + 0.1);
      scheduleTask();
      EventQueue.pushOne(_auto, autoRun.start);
    } else {
      EventQueue.pushOne(_auto, autoRun.stopTicked);
    }
  }

  void _autoTick(Duration timeStamp) {
    if (controller == null ||
        controller!.atEdge ||
        !inBook ||
        !autoRun.value ||
        initQueue.actived ||
        config.value.axis == Axis.horizontal) {
      autoRun.stopTicked();
      return;
    }

    final _start = controller!.pixels;

    final _e = timeStamp - lastStamp;
    lastStamp = timeStamp;

    final alpha = (_e.inMicroseconds / mic);

    controller!.setPixels(_start + autoValue.value * alpha);

    if (timeStamp > const Duration(minutes: 1) && !autoRun._wait) {
      final wait = autoRun.wait();
      if (wait) {
        Timer(const Duration(milliseconds: 100), autoRun.waitRun);
      }
    }
  }
}

class AutoRun {
  AutoRun(this.onTick, this.reset);
  final VoidCallback reset;
  final void Function(Duration) onTick;

  final isActive = ValueNotifier(false);

  bool get value => isActive.value;
  set value(bool v) {
    isActive.value = v;
    EventQueue.run('autoRun_wake', () => Wakelock.toggle(enable: v));
  }

  Ticker? _ticker;
  bool _ignore = false;
  void start() {
    assert(_ticker == null || !_ticker!.isActive);
    stopTicked();
    value = true;
    _ticker = Ticker((timeStamp) {
      if (_ignore) {
        _ignore = false;
        return;
      }
      _ignore = true;
      onTick(timeStamp);
    }, debugLabel: 'autoRun')
      ..start();
  }

  void stopTicked() {
    _ticker?.dispose();
    _ticker = null;
    reset();
    _wait = false;
    value = false;
  }

  bool get _running => _ticker?.isActive == true;
  bool get _stop => _ticker?.isActive == false;

  bool _wait = false;
  bool wait() {
    if (_running) {
      _ticker?.stop();
      reset();
      _wait = true;
      return true;
    }
    return false;
  }

  void waitRun() {
    if (value && _wait && _stop) {
      _ticker?.start();
      _wait = false;
    }
  }

  bool _lastActive = false;
  void stopSave() {
    if (isActive.value) {
      _lastActive = true;
      stopTicked();
    }
  }

  void stopAutoRun() {
    if (_lastActive) {
      start();
      _lastActive = false;
    }
  }
}
