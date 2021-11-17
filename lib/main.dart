import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';

import 'event/base/type_adapter.dart';
import 'pages/app.dart';
import 'provider/options_notifier.dart';
import 'utils/time.dart';

void main() async {
  NopWidgetsFlutterBinding.ensureInitialized();
  // RendererBinding.instance!.renderView.automaticSystemUiAdjustment = false;
  // DeferredMain? hot;
  // if (defaultTargetPlatform == TargetPlatform.android) {
  //   hot = DeferredMain(
  //       versionName: versionName,
  //       versionNumber: versionNumber,
  //       baseUrl: 'https://sersr.github.io/shudu/');

  //   /// test: 'http://192.168.1.127:8080/shudu/'
  //   await hot.initState();
  // }

  /// 为了获得更好的体验，在开始第一帧渲染之前先获得[ThemeMode]
  final appDir = await getApplicationDocumentsDirectory().logi;
  hiveInit(join(appDir.path, 'shudu', 'hive'));
  final stop = Stopwatch()..start();
  final mode = await OptionsNotifier.getThemeModeUnSafe().logi;
  Log.i('mode: $mode | use: ${stop.elapsedMicroseconds / 1000} ms',
      onlyDebug: false);

  runApp(MulProvider(hotFix: null, mode: mode));
  uiOverlay(hide: false);

  // final dark = OptionsNotifier.isDarkMode(mode);
  // uiStyle(dark: dark);
}
