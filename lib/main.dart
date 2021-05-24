import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/app.dart';
import 'utils/utils.dart';
import 'utils/widget/shader_warmup.dart';

void main() {
  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  WidgetsFlutterBinding.ensureInitialized();

  EventLooper.instance.addPersistent = true;
  uiOverlay(hide: false);
  uiStyle();
  // debugProfilePaintsEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfileLayoutsEnabled = true;

  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;
  runApp(const MulProvider());
}
