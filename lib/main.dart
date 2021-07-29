import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/app.dart';
import 'package:useful_tools/useful_tools.dart';
void main() async {
  // PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  // WidgetsFlutterBinding.ensureInitialized();
  NopWidgetsFlutterBinding.ensureInitialized();
  await uiOverlay(hide: false);
  uiStyle();
  // debugProfilePaintsEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfileLayoutsEnabled = true;
  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;
  runApp(const MulProvider());
}
