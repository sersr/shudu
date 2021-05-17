import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/app.dart';
import 'utils/tools/frame_callback_looper.dart' as looper;
import 'utils/utils.dart';
import 'utils/widget/shader_warmup.dart';

void main() {
  PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  WidgetsFlutterBinding.ensureInitialized();

  looper.EventLooper.instance.addPersistent = true;
  uiOverlay(hide: false);
  uiStyle();
  // debugProfilePaintsEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfileLayoutsEnabled = true;

  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;

  runApp(const MulProvider());
}
