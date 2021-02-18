
import 'package:flutter/material.dart';
import 'bloc/painter_bloc.dart';
import 'pages/app.dart';
import 'utils/debug/log.dart';
import 'utils/widget/shader_warmup.dart';

void main() {
  assert(() {
    // Bloc.observer = SimpleBlocObserver();
    Log.switchToPrint = (stage) {
      if (stage is PainterBloc) return true;
      return false;
    };
    return true;
  }());
  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  runApp(const MulProvider());
}
