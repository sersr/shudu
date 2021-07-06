import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/app.dart';
import 'utils/binding/widget_binding.dart';
import 'utils/utils.dart';
import 'utils/widget/shader_warmup.dart';

void main() {
  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  // WidgetsFlutterBinding.ensureInitialized();
  NopWidgetsFlutterBinding.ensureInitialized();
  uiOverlay(hide: false);
  uiStyle();
  // debugProfilePaintsEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfileLayoutsEnabled = true;
  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;
  runApp(const MulProvider());
}
