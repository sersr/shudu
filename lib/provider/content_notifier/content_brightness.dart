import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:useful_tools/useful_tools.dart';

mixin ContentBrightness {
  final brightness = ValueNotifier(0.0);

  double? _lastBrightness;

  // 恢复用户设置亮度
  void brightnessResetUser() {
    if (!follow.value) {
      final _old = _lastBrightness;
      if (_old != null) {
        setBrightness(_old);
      }
    }
  }

  // 恢复系统亮度
  void outResetDefault() {
    if (brightnessSup)
      EventQueue.pushOne(brightness, () async {
        await ScreenBrightness.resetScreenBrightness();

        return reloadBrightnessTask();
      });
  }

  void setBrightness(double v) {
    final _clamp = v.clamp(0.0, 1.0);
    EventQueue.pushOne(brightness, () async {
      brightness.value = _clamp;
      _lastBrightness = _clamp;
      follow.value = false;
      if (brightnessSup) return ScreenBrightness.setScreenBrightness(_clamp);
    });
  }

  final follow = ValueNotifier(true);
  void setFollow(bool? v) {
    if (follow.value == v || v == null) return;
    follow.value = v;
    EventQueue.pushOne(brightness, () async {
      if (v) {
        if (brightnessSup) await ScreenBrightness.resetScreenBrightness();
      } else {
        final _old = _lastBrightness;
        if (_old != null) {
          final _v = _old.clamp(0.0, 1.0);
          brightness.value = _v;
          if (brightnessSup) await ScreenBrightness.setScreenBrightness(_v);
        }
      }
    });
  }

  void reloadBrightness() {
    EventQueue.pushOne(brightness, reloadBrightnessTask);
  }

  Future<void> reloadBrightnessTask() async {
    if (brightnessSup) brightness.value = await ScreenBrightness.current;
  }

  final bool brightnessSup = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
