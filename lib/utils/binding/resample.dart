import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class Resample {
  final Queue<PointerEvent> _queuedEvents = Queue<PointerEvent>();
  void addEvent(PointerEvent event) {
    _queuedEvents.add(event);
  }

  PointerEvent _toHoverEvent(
    PointerEvent event,
    Offset position,
    Offset delta,
    Duration timeStamp,
  ) {
    return PointerHoverEvent(
      timeStamp: timeStamp,
      kind: event.kind,
      device: event.device,
      position: position,
      delta: delta,
      buttons: event.buttons,
      obscured: event.obscured,
      pressureMin: event.pressureMin,
      pressureMax: event.pressureMax,
      distance: event.distance,
      distanceMax: event.distanceMax,
      size: event.size,
      radiusMajor: event.radiusMajor,
      radiusMinor: event.radiusMinor,
      radiusMin: event.radiusMin,
      radiusMax: event.radiusMax,
      orientation: event.orientation,
      tilt: event.tilt,
      synthesized: event.synthesized,
      embedderId: event.embedderId,
    );
  }

  PointerEvent _toMoveEvent(
    PointerEvent event,
    Offset position,
    Offset delta,
    int pointerIdentifier,
    Duration timeStamp,
  ) {
    return PointerMoveEvent(
      timeStamp: timeStamp,
      pointer: pointerIdentifier,
      kind: event.kind,
      device: event.device,
      position: position,
      delta: delta,
      buttons: event.buttons,
      obscured: event.obscured,
      pressure: event.pressure,
      pressureMin: event.pressureMin,
      pressureMax: event.pressureMax,
      distanceMax: event.distanceMax,
      size: event.size,
      radiusMajor: event.radiusMajor,
      radiusMinor: event.radiusMinor,
      radiusMin: event.radiusMin,
      radiusMax: event.radiusMax,
      orientation: event.orientation,
      tilt: event.tilt,
      platformData: event.platformData,
      synthesized: event.synthesized,
      embedderId: event.embedderId,
    );
  }

  PointerEvent _toMoveOrHoverEvent(
    PointerEvent event,
    Offset position,
    Offset delta,
    int pointerIdentifier,
    Duration timeStamp,
    bool isDown,
  ) {
    return isDown
        ? _toMoveEvent(event, position, delta, pointerIdentifier, timeStamp)
        : _toHoverEvent(event, position, delta, timeStamp);
  }

  PointerEvent? firstEvent;
  PointerEvent? lastEvent;
  var _position = Offset.zero;

  void _processPointerEvents(Duration vsyncTime) {
    final list = _queuedEvents.toList();
    PointerEvent? _last;
    PointerEvent? _first;
    for (var i = list.length - 1; i >= 0; i--) {
      final event = list.elementAt(i);
      if (event.timeStamp <= vsyncTime) {
        _last = event;
        final _fi = i - 1;
        if (_fi < list.length && _fi >= 0) {
          _first = list.elementAt(_fi);
        }
        _first ??= _last;
        break;
      }
    }
    lastEvent = _last;
    firstEvent = _first ?? _last;
  }

  bool _isTracked = false;
  bool _isDown = false;
  int _pointerIdentifier = 0;

  void resample(Duration vsyncTime, Duration nextTimeStamp,
      HandleEventCallback callback) {
    _processPointerEvents(vsyncTime);

    final sampleTime = vsyncTime - const Duration(milliseconds: 5);
    final _last = lastEvent;
    final _first = firstEvent;

    if (_last == null || _first == null) return;
    final _lastTimeStamp = _last.timeStamp;
    var endTime = _lastTimeStamp;
    // print('diff: ${(vsyncTime - nextTimeStamp).inMicroseconds / 1000} ms');
    final it = _queuedEvents.iterator;

    while (it.moveNext()) {
      final event = it.current;
      if (event.timeStamp > _lastTimeStamp) {
        if (event.timeStamp >= nextTimeStamp) {
          break;
        }
        if (event is PointerUpEvent || event is PointerRemovedEvent) {
          endTime = event.timeStamp;
          continue;
        }

        // Stop if event is not move or hover.
        if (event is! PointerMoveEvent && event is! PointerHoverEvent) {
          break;
        }
      }
    }

    var position = _positionAt(sampleTime);
    // final last = _queuedEvents.last;

    while (_queuedEvents.isNotEmpty) {
      final event = _queuedEvents.first;

      if (event.timeStamp > endTime) {
        break;
      }

      final wasTracked = _isTracked;
      final wasDown = _isDown;

      _isTracked = event is! PointerRemovedEvent;
      _isDown = event.down;

      final pointerIdentifier = event.pointer;
      _pointerIdentifier = pointerIdentifier;

      if (_isTracked && !wasTracked) {
        _position = position;
      }

      if (event is! PointerMoveEvent && event is! PointerHoverEvent) {
        if (position != _position) {
          final delta = position - _position;
          callback(_toMoveOrHoverEvent(
              event, position, delta, _pointerIdentifier, sampleTime, wasDown));
          _position = position;
        }
        callback(event.copyWith(
          position: position,
          delta: Offset.zero,
          pointer: pointerIdentifier,
          timeStamp: sampleTime,
        ));
      }
      _queuedEvents.removeFirst();
    }

    if (position != _position && _isTracked) {
      final delta = position - _position;

      callback(_toMoveOrHoverEvent(
          _last, position, delta, _pointerIdentifier, sampleTime, _isDown));
      _position = position;
    }
  }

  Offset _positionAt(Duration sampleTime) {
    final _last = lastEvent;
    final _first = firstEvent;
    if (_last == null || _first == null) return Offset.zero;
    final _p = _last.position;
    var x = _p.dx;
    var y = _p.dy;

    final touchTimeDiff = _last.timeStamp - _first.timeStamp;
    final touchSampleTimeDiff = sampleTime - _last.timeStamp;

    final diff = touchTimeDiff.inMicroseconds.toDouble();
    final alpha =
        diff == 0 ? 0.0 : touchSampleTimeDiff.inMicroseconds.toDouble() / diff;

    final positonDiff = _last.position - _first.position;
    x += positonDiff.dx * alpha;
    y += positonDiff.dy * alpha;
    return Offset(x, y);
  }

  void stop(HandleEventCallback callback) {
    while (_queuedEvents.isNotEmpty) {
      callback(_queuedEvents.removeFirst());
    }
    _isTracked = false;
    _position = Offset.zero;
  }

  bool get hasPendingEvents => _queuedEvents.isNotEmpty;

  /// Returns `true` if pointer is currently tracked.
  bool get isTracked => _isTracked;

  /// Returns `true` if pointer is currently down.
  bool get isDown => _isDown;
}
