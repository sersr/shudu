import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/app.dart';
import 'utils/utils.dart';
import 'utils/widget/shader_warmup.dart';

void main() {
  assert(() {
    // Bloc.observer = SimpleBlocObserver();
    Log.enablePrint = (stage) {
      return true;
    };
    return true;
  }());

  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  WidgetsFlutterBinding.ensureInitialized();
  uiOverlay(hide: false);
  uiStyle();
  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;

  runApp(const MulProvider());
}
