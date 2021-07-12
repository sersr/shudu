// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';

import 'resample.dart';

// import './resampler.dart' as re;

typedef _HandleSampleTimeChangedCallback = void Function();

// Class that handles resampling of touch events for multiple pointer
// devices.
//
// SchedulerBinding's `currentSystemFrameTimeStamp` is used to determine
// sample time.
// class _Resampler {
//   _Resampler(this._handlePointerEvent, this._handleSampleTimeChanged);

//   // Resamplers used to filter incoming pointer events.
//   final Map<int, PointerEventResampler> _resamplers =
//       <int, PointerEventResampler>{};
//   final Map<int, Resample> _myresampler = <int, Resample>{};

//   // Flag to track if a frame callback has been scheduled.
//   bool _frameCallbackScheduled = false;

//   // Current frame time for resampling.
//   Duration _frameTime = Duration.zero;

//   // Last sample time and time stamp of last event.
//   //
//   // Only used for debugPrint of resampling margin.
//   Duration _lastSampleTime = Duration.zero;
//   Duration _lastEventTime = Duration.zero;

//   // Callback used to handle pointer events.
//   final HandleEventCallback _handlePointerEvent;

//   // Callback used to handle sample time changes.
//   final _HandleSampleTimeChangedCallback _handleSampleTimeChanged;

//   // Add `event` for resampling or dispatch it directly if
//   // not a touch event.
//   void addOrDispatch(PointerEvent event) {
//     final scheduler = SchedulerBinding.instance;
//     assert(scheduler != null);
//     // Add touch event to resampler or dispatch pointer event directly.
//     if (event.kind == PointerDeviceKind.touch) {
//       // Save last event time for debugPrint of resampling margin.
//       _lastEventTime = event.timeStamp;

//       final resampler = _resamplers.putIfAbsent(
//         event.device,
//         () => PointerEventResampler(),
//       );
//       final _my = _myresampler.putIfAbsent(
//         event.device,
//         () => Resample(),
//       );
//       resampler.addEvent(event);
//       _my.addEvent(event);
//     } else {
//       _handlePointerEvent(event);
//     }
//   }

//   // Sample and dispatch events.
//   //
//   // `samplingOffset` is relative to the current frame time, which
//   // can be in the past when we're not actively resampling.
//   // `samplingInterval` is used to determine the approximate next
//   // time for resampling.
//   // `currentSystemFrameTimeStamp` is used to determine the current
//   // frame time.
//   void sample(Duration samplingOffset, Duration samplingInterval) {
//     final scheduler = SchedulerBinding.instance;
//     assert(scheduler != null);

//     // Determine sample time by adding the offset to the current
//     // frame time. This is expected to be in the past and not
//     // result in any dispatched events unless we're actively
//     // resampling events.
//     final sampleTime = _frameTime + samplingOffset;

//     // Determine next sample time by adding the sampling interval
//     // to the current sample time.
//     final nextSampleTime = sampleTime + samplingInterval;

//     // Iterate over active resamplers and sample pointer events for
//     // current sample time.

//     for (final resampler in _resamplers.values) {
//       resampler.sample(sampleTime, nextSampleTime, _handlePointerEvent);
//     }
//     for (final m in _myresampler.values) {
//       m.resample(sampleTime);
//     }

//     // Remove inactive resamplers.
//     _resamplers.removeWhere((int key, PointerEventResampler resampler) {
//       return !resampler.hasPendingEvents && !resampler.isDown;
//     });

//     // Save last sample time for debugPrint of resampling margin.
//     _lastSampleTime = sampleTime;

//     // Schedule a frame callback if another call to `sample` is needed.
//     if (!_frameCallbackScheduled && _resamplers.isNotEmpty) {
//       _frameCallbackScheduled = true;
//       scheduler?.scheduleFrameCallback((_) {
//         _frameCallbackScheduled = false;
//         // We use `currentSystemFrameTimeStamp` here as it's critical that
//         // sample time is in the same clock as the event time stamps, and
//         // never adjusted or scaled like `currentFrameTimeStamp`.
//         _frameTime = scheduler.currentSystemFrameTimeStamp;
//         assert(() {
//           if (debugPrintResamplingMargin) {
//             final resamplingMargin = _lastEventTime - _lastSampleTime;
//             debugPrint('$resamplingMargin');
//           }
//           return true;
//         }());
//         _handleSampleTimeChanged();
//       });
//     }
//   }

//   // Stop all resampling and dispatched any queued events.
//   void stop() {
//     for (final resampler in _resamplers.values) {
//       resampler.stop(_handlePointerEvent);
//     }
//     _resamplers.clear();
//   }
// }

class _Resampler {
  _Resampler(this._handlePointerEvent, this._handleSampleTimeChanged,
      this._samplingInterval);

  // Resamplers used to filter incoming pointer events.
  final Map<int, PointerEventResampler> _resamplers =
      <int, PointerEventResampler>{};
  final Map<int, Resample> _myresampler = <int, Resample>{};
  // Flag to track if a frame callback has been scheduled.
  bool _frameCallbackScheduled = false;

  // Last frame time for resampling.
  Duration _frameTime = Duration.zero;
  Duration _lastFrameTime = Duration.zero;
  Duration _llf = Duration.zero;

  // Time since `_frameTime` was updated.

  // Last sample time and time stamp of last event.
  //
  // Only used for debugPrint of resampling margin.
  Duration _lastSampleTime = Duration.zero;
  Duration _lastEventTime = Duration.zero;

  // Callback used to handle pointer events.
  final HandleEventCallback _handlePointerEvent;

  // Callback used to handle sample time changes.
  final _HandleSampleTimeChangedCallback _handleSampleTimeChanged;

  // Interval used for sampling.
  final Duration _samplingInterval;

  // Add `event` for resampling or dispatch it directly if
  // not a touch event.
  void addOrDispatch(PointerEvent event) {
    final scheduler = SchedulerBinding.instance;
    assert(scheduler != null);
    // Add touch event to resampler or dispatch pointer event directly.
    if (event.kind == PointerDeviceKind.touch) {
      // Save last event time for debugPrint of resampling margin.
      _lastEventTime = event.timeStamp;

      // final resampler = _resamplers.putIfAbsent(
      //   event.device,
      //   () => PointerEventResampler(),
      // );
      // resampler.addEvent(event);
      final _my = _myresampler.putIfAbsent(
        event.device,
        () => Resample(),
      );

      _my.addEvent(event);
    } else {
      _handlePointerEvent(event);
    }
  }

  // Sample and dispatch events.
  //
  // The `samplingOffset` is relative to the current frame time, which
  // can be in the past when we're not actively resampling.
  // The `samplingClock` is the clock used to determine frame time age.
  void sample(Duration samplingOffset) {
    final scheduler = SchedulerBinding.instance;
    assert(scheduler != null);

    // Determine sample time by adding the offset to the current
    // frame time. This is expected to be in the past and not
    // result in any dispatched events unless we're actively
    // resampling events.
    // final sampleTime = _frameTime + samplingOffset;
    final sampleTime = _llf + samplingOffset;

    // Determine next sample time by adding the sampling interval
    // to the current sample time.
    final nextSampleTime = _lastFrameTime + samplingOffset;

    // Iterate over active resamplers and sample pointer events for
    // current sample time.
    // for (final resampler in _resamplers.values) {
    //   resampler.sample(sampleTime, nextSampleTime, _handlePointerEvent);
    // }

    // // Remove inactive resamplers.
    // _resamplers.removeWhere((key, resampler) {
    //   return !resampler.hasPendingEvents && !resampler.isDown;
    // });
    // final isNotEmpty = _resamplers.isNotEmpty;

    for (final resampler in _myresampler.values) {
      resampler.resample(sampleTime, nextSampleTime, _handlePointerEvent);
    }

    // Remove inactive resamplers.
    _myresampler.removeWhere((int key, Resample resampler) {
      return !resampler.hasPendingEvents && !resampler.isDown;
    });
    final isNotEmpty = _myresampler.isNotEmpty;
    // Save last sample time for debugPrint of resampling margin.
    _lastSampleTime = sampleTime;

    // Schedule a frame callback if another call to `sample` is needed.
    if (!_frameCallbackScheduled && isNotEmpty) {
      _frameCallbackScheduled = true;
      scheduler?.scheduleFrameCallback((_) {
        _frameCallbackScheduled = false;
        // We use `currentSystemFrameTimeStamp` here as it's critical that
        // sample time is in the same clock as the event time stamps, and
        // never adjusted or scaled like `currentFrameTimeStamp`.
        _llf = _lastFrameTime;
        _lastFrameTime = _frameTime;
        _frameTime = scheduler.currentSystemFrameTimeStamp;
        assert(() {
          if (debugPrintResamplingMargin) {
            final resamplingMargin = _lastEventTime - _lastSampleTime;
            debugPrint('$resamplingMargin');
          }
          return true;
        }());
        _handleSampleTimeChanged();
      });
    }
  }

  // Stop all resampling and dispatched any queued events.
  void stop() {
    for (final resampler in _resamplers.values) {
      resampler.stop(_handlePointerEvent);
    }
    for (final my in _myresampler.values) {
      my.stop(_handlePointerEvent);
    }
    _myresampler.clear();
    _resamplers.clear();
    _frameTime = Duration.zero;
  }

  // void _onSampleTimeChanged() {
  //   assert(() {
  //     if (debugPrintResamplingMargin) {
  //       final resamplingMargin = _lastEventTime - _lastSampleTime;
  //       debugPrint('$resamplingMargin');
  //     }
  //     return true;
  //   }());
  //   _handleSampleTimeChanged();
  // }
}

const Duration _samplingInterval = Duration(microseconds: 16667);
final scheduler = SchedulerBinding.instance;

// version: stable 2.0.6
mixin NopGestureBinding on GestureBinding {
  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};

  /// Dispatch an event to the targets found by a hit test on its position.
  ///
  /// This method sends the given event to [dispatchEvent] based on event types:
  ///
  ///  * [PointerDownEvent]s and [PointerSignalEvent]s are dispatched to the
  ///    result of a new [hitTest].
  ///  * [PointerUpEvent]s and [PointerMoveEvent]s are dispatched to the result of hit test of the
  ///    preceding [PointerDownEvent]s.
  ///  * [PointerHoverEvent]s, [PointerAddedEvent]s, and [PointerRemovedEvent]s
  ///    are dispatched without a hit test result.
  @override
  void handlePointerEvent(PointerEvent event) {
    assert(!locked);

    if (resamplingEnabled) {
      _resampler.addOrDispatch(event);

      _resampler.sample(samplingOffset);
      return;
    }

    // Stop resampler if resampling is not enabled. This is a no-op if
    // resampling was never enabled.
    _resampler.stop();
    _handlePointerEventImmediately(event);
  }

  // SamplingClock get _samplingClock {
  //   var value = SamplingClock();
  //   assert(() {
  //     final debugValue = debugSamplingClock;
  //     if (debugValue != null) value = debugValue;
  //     return true;
  //   }());
  //   return value;
  // }

  void _handlePointerEventImmediately(PointerEvent event) {
    HitTestResult? hitTestResult;
    if (event is PointerDownEvent ||
        event is PointerSignalEvent ||
        event is PointerHoverEvent) {
      assert(!_hitTests.containsKey(event.pointer));
      hitTestResult = HitTestResult();
      hitTest(hitTestResult, event.position);
      if (event is PointerDownEvent) {
        _hitTests[event.pointer] = hitTestResult;
      }
      assert(() {
        if (debugPrintHitTestResults) debugPrint('$event: $hitTestResult');
        return true;
      }());
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      hitTestResult = _hitTests.remove(event.pointer);
    } else if (event.down) {
      // Because events that occur with the pointer down (like
      // [PointerMoveEvent]s) should be dispatched to the same place that their
      // initial PointerDownEvent was, we want to re-use the path we found when
      // the pointer went down, rather than do hit detection each time we get
      // such an event.
      hitTestResult = _hitTests[event.pointer];
    }
    assert(() {
      if (debugPrintMouseHoverEvents && event is PointerHoverEvent)
        debugPrint('$event');
      return true;
    }());
    if (hitTestResult != null ||
        event is PointerAddedEvent ||
        event is PointerRemovedEvent) {
      dispatchEvent(event, hitTestResult);
    }
  }

  void _handleSampleTimeChanged() {
    if (!locked) {
      if (resamplingEnabled) {
        _resampler.sample(samplingOffset);
      } else {
        _resampler.stop();
      }
    }
  }

  // Resampler used to filter incoming pointer events when resampling
  // is enabled.
  late final _Resampler _resampler = _Resampler(
    _handlePointerEventImmediately,
    _handleSampleTimeChanged,
    _samplingInterval,
  );
}
