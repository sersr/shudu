import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'event/base/type_adapter.dart';
import 'pages/app.dart';
import 'package:useful_tools/useful_tools.dart';

void main() async {
  // PaintingBinding.shaderWarmUp = const MyShaderWarmUp();
  // WidgetsFlutterBinding.ensureInitialized();
  NopWidgetsFlutterBinding.ensureInitialized();
  // 在app开始就初始化
  final appDir = await getApplicationDocumentsDirectory();
  hiveInit(join(appDir.path, 'shudu', 'hive'));

  await uiOverlay(hide: false);
  uiStyle();
  // debugProfilePaintsEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfileLayoutsEnabled = true;
  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;
  runApp(const MulProvider());
}
