import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 小型的手势行为，没有发送监听事件
abstract class Activity {
  Activity(this.delegate);
  ActivityDelegate delegate;
  double get velocity;
  void dispose() {}
}

class DragActivity extends Activity {
  DragActivity({required ActivityDelegate delegate, this.controller}) : super(delegate);
  Drag? controller;

  @override
  void dispose() {
    controller = null;
  }

  @override
  double get velocity => 0.0;
}

class IdleActivity extends Activity {
  IdleActivity(ActivityDelegate delegate) : super(delegate);

  @override
  double get velocity => 0.0;
}

class HoldActivity extends Activity implements ScrollHoldController {
  HoldActivity(ActivityDelegate delegate, {this.cancelCallback}) : super(delegate);
  VoidCallback? cancelCallback;
  @override
  void cancel() {
    delegate.goBallisticResolveWithLastActivity();
  }

  @override
  void dispose() {
    cancelCallback?.call();
  }

  @override
  double get velocity => 0.0;
}

class DrivenAcitvity extends Activity {
  DrivenAcitvity({
    required ActivityDelegate delegate,
    required TickerProvider vsync,
    required double from,
    required double to,
    Duration? duration,
    required Curve curve,
  }) : super(delegate) {
    _controller = AnimationController.unbounded(vsync: vsync, value: from)
      ..addListener(_tick)
      ..animateTo(to, duration: duration, curve: curve).whenComplete(end);
  }

  AnimationController? _controller;
  void _tick() {
    delegate.setPixels(_controller!.value);
  }

  void end() {
    delegate.goIdle();
  }

  @override
  void dispose() {
    _controller?.dispose();
  }

  @override
  double get velocity => _controller!.velocity;
}

class BallisticActivity extends Activity {
  BallisticActivity({
    required ActivityDelegate delegate,
    required TickerProvider vsync,
    required this.simulation,
    required this.end,
    this.swipeDown,
  }) : super(delegate) {
    _controller = AnimationController.unbounded(vsync: vsync)
      ..addListener(_tick)
      ..animateWith(simulation).whenComplete(done);
  }
  bool? swipeDown;
  double Function() end;
  Simulation simulation;
  late AnimationController _controller;
  void _tick() {
    final _end = end();

    if (swipeDown != null) {
      if (swipeDown!) {
        if (_controller.value >= _end) {
          delegate.setPixels(_controller.value);
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) => done());
          return;
        }
      } else {
        if (_controller.value <= _end) {
          delegate.setPixels(_controller.value);
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) => done());
          return;
        }
      }
      delegate.setPixels(_controller.value);
    } else {
      final p = (_controller.value - _end).abs();
      if (p < 1 / ui.window.devicePixelRatio) {
        delegate.setPixels(_end);
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) => done());
        return;
      }
      delegate.setPixels(_controller.value);
    }
  }

  @override
  double get velocity => _controller.velocity;

  void done() {
    delegate.goIdle();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PreNextDragController extends Drag {
  PreNextDragController({
    this.cancelCallback,
    required this.delegate,
  });

  final ActivityDelegate delegate;
  final VoidCallback? cancelCallback;

  @override
  void update(DragUpdateDetails details) {
    delegate.applyUserOffset(details.primaryDelta!);
  }

  @override
  void end(DragEndDetails details) {
    delegate.goBallistic(-details.primaryVelocity!);
  }

  @override
  void cancel() {
    delegate.goBallistic(0.0);
  }

  void dispose() {
    cancelCallback?.call();
  }
}

abstract class ActivityDelegate {
  void setPixels(double v);
  void applyUserOffset(double delta);
  void goBallistic(double v);
  void goBallisticResolveWithLastActivity();
  void goIdle();
  double get pixels;
}
