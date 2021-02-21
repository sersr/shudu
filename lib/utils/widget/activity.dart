import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
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
    required this.end,
    this.magnetic = true,
  }) : super(delegate) {
    _controller = AnimationController.unbounded(vsync: vsync)
      ..addListener(_tick)
      ..animateWith(simulation).whenComplete(done);
  }
  bool magnetic;
  double end;
  Simulation simulation;
  late AnimationController _controller;
  void _tick() {
    final p = (_controller.value - end).abs();
    if (p == 0.0) {
      delegate.setPixels(_controller.value);
      done();
      return;
    }
    if (magnetic && p < 1 / ui.window.devicePixelRatio) {
      delegate.setPixels(end);
      done();
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

/// copy from [ScrollDragController]
class PreNextDragController extends Drag {
  PreNextDragController({
    this.cancelCallback,
    this.motionStartDistanceThreshold,
    required this.delegate,
    required DragStartDetails details,
  })   : _lastNonStationaryTimestamp = details.sourceTimeStamp,
        _offsetSinceLastStop = motionStartDistanceThreshold == null ? null : 0.0;

  final ActivityDelegate delegate;
  final VoidCallback? cancelCallback;

  @override
  void update(DragUpdateDetails details) {
    var offset = details.primaryDelta!;
    if (offset != 0.0) {
      _lastNonStationaryTimestamp = details.sourceTimeStamp;
    }
    offset = _adjustForScrollStartThreshold(offset, details.sourceTimeStamp);
    if (offset == 0.0) {
      return;
    }
    delegate.applyUserOffset(offset);
  }

  @override
  void cancel() {
    delegate.goBallistic(0.0);
    super.cancel();
  }

  void dispose() {
    cancelCallback?.call();
  }

  double? _offsetSinceLastStop;

  final double? motionStartDistanceThreshold;

  Duration? _lastNonStationaryTimestamp;

  static const Duration motionStoppedDurationThreshold = Duration(milliseconds: 50);

  static const double _bigThresholdBreakDistance = 24.0;

  double _adjustForScrollStartThreshold(double offset, Duration? timestamp) {
    if (timestamp == null) {
      return offset;
    }
    if (offset == 0.0) {
      if (motionStartDistanceThreshold != null &&
          _offsetSinceLastStop == null &&
          timestamp - _lastNonStationaryTimestamp! > motionStoppedDurationThreshold) {
        _offsetSinceLastStop = 0.0;
      }
      return 0.0;
    } else {
      if (_offsetSinceLastStop == null) {
        return offset;
      } else {
        _offsetSinceLastStop = _offsetSinceLastStop! + offset;
        if (_offsetSinceLastStop!.abs() > motionStartDistanceThreshold!) {
          _offsetSinceLastStop = null;
          if (offset.abs() > _bigThresholdBreakDistance) {
            return offset;
          } else {
            return math.min(
                  motionStartDistanceThreshold! / 3.0,
                  offset.abs(),
                ) *
                offset.sign;
          }
        } else {
          return 0.0;
        }
      }
    }
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
