import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class Activity {
  Activity(this.delegate);
  ActivityDelegate delegate;
  double get velocity;
  void dispose() {}
}

class DragActivity extends Activity {
  DragActivity({required ActivityDelegate delegate, this.controller}) : super(delegate);
  PreNextDragController? controller;

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
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
  HoldActivity(ActivityDelegate delegate, {this.call}) : super(delegate);
  VoidCallback? call;
  @override
  void cancel() {
    delegate.goPageResolve();
  }

  @override
  void dispose() {
    if (call != null) {
      call!();
    }
    super.dispose();
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
    super.dispose();
  }

  @override
  double get velocity => _controller!.velocity;
}

class BallisticActivity extends Activity {
  BallisticActivity({
    required ActivityDelegate delegate,
    required TickerProvider vsync,
    required this.simulation,
    this.end,
    this.magnetic = true,
  }) : super(delegate) {
    _controller = AnimationController.unbounded(vsync: vsync)
      ..addListener(_tick)
      ..animateWith(simulation).whenComplete(done);
  }
  bool magnetic;
  double? end;
  Simulation simulation;
  late AnimationController _controller;
  void _tick() {
    if (magnetic && end != null) {
      if ((_controller.value - end!).abs() < 1) {
        delegate.setPixels(end!);
        done();
      } else {
        delegate.setPixels(_controller.value);
      }
    } else {
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
  PreNextDragController({this.cancelCallback, required this.delegate});
  final ActivityDelegate delegate;
  final VoidCallback? cancelCallback;
  @override
  void update(DragUpdateDetails details) {
    if (details.primaryDelta! == 0.0) return;
    delegate.applyUserOffset(details.primaryDelta!);
  }

  @override
  void cancel() {
    delegate.goBallistic(0.0);
    super.cancel();
  }

  void dispose() {
    if (cancelCallback != null) cancelCallback!();
  }
}

abstract class ActivityDelegate {
  void setPixels(double v);
  void applyUserOffset(double delta);
  void goBallistic(double v);
  void goPageResolve();
  void goIdle();
  // bool isScrollable(double v);
}
