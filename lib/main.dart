import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:useful_tools/useful_tools.dart';

import 'pages/app.dart';

void main() async {
  // PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  // WidgetsFlutterBinding.ensureInitialized();
  NopWidgetsFlutterBinding.ensureInitialized();
  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;

  // debugProfilePaintsEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfileLayoutsEnabled = true;
  runApp(const MulProvider());
  uiOverlay(hide: false);
  uiStyle();
}
