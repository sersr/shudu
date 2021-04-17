import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> uiOverlay({bool hide = true}) async {
  return SystemChrome.setEnabledSystemUIOverlays(hide ? const [] : SystemUiOverlay.values);
}

void uiStyle({bool dark = true}) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: dark ? Brightness.dark : Brightness.light));
}

Future<void> orientation(bool portrait) async {
  if (portrait) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
