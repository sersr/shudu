import 'package:flutter/material.dart';
import 'pages/app.dart';
import 'utils/debug/log.dart';
import 'utils/widget/shader_warmup.dart';

void main() {
  assert(() {
    // Bloc.observer = SimpleBlocObserver();
    Log.switchToPrint = (stage) {
      return true;
    };
    return true;
  }());
  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  runApp(const MulProvider());
}
