import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'pages/app.dart';
import 'utils/debug/log.dart';
import 'utils/widget/shader_warmup.dart';
void main() {
  assert(() {
    // Bloc.observer = SimpleBlocObserver();
    Log.enablePrint = (stage) {
      return true;
    };
    return true;
  }());
  WidgetsFlutterBinding.ensureInitialized();

  /// 使滑动更加舒适
  GestureBinding.instance!.resamplingEnabled = true;

  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  runApp(const MulProvider());
}
