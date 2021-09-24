import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:hot_fix/hot_fix.dart';
import 'pages/app.dart';
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
  runApp(MulProvider(hotFix: hot));
  uiOverlay(hide: false);
  uiStyle();
}
