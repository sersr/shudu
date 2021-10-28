

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:hot_fix/hot_fix.dart';
import 'event/base/type_adapter.dart';
import 'pages/app.dart';
import 'provider/options_notifier.dart';
import 'versions_gen.dart';

void main() async {
  NopWidgetsFlutterBinding.ensureInitialized();
  RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;
  DeferredMain? hot;
  if (defaultTargetPlatform == TargetPlatform.android) {
    hot = DeferredMain(
        versionName: versionName,
        versionNumber: versionNumber,
        baseUrl: 'https://sersr.github.io/shudu/');

    /// test: 'http://192.168.1.127:8080/shudu/'
    await hot.initState();
  }

  /// 为了获得更好的体验，在开始第一帧渲染之前先获得[ThemeMode]
  final appDir = await getApplicationDocumentsDirectory();
  hiveInit(join(appDir.path, 'shudu', 'hive'));
  final mode = await OptionsNotifier.getThemeMode();
  Log.i('mode: $mode');
  runApp(MulProvider(hotFix: hot, mode: mode));
  uiOverlay(hide: false);

  final dark = OptionsNotifier.isDarkMode(mode);
  uiStyle(dark: dark);
}
