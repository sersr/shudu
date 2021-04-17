import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ViewInsets {
  const ViewInsets({required this.padding, required this.size});
  final EdgeInsets padding;
  final Size size;
  static const zero = ViewInsets(padding: EdgeInsets.zero, size: Size.zero);
}

class Bangs {
  static const MethodChannel _channel = MethodChannel('bangs');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<ViewInsets> get safePadding async {
    final map = await _channel.invokeMethod('safePadding');
    if (map is! Map) {
      throw Exception('error');
    }
    final uiSize = ui.window.physicalSize;
    final top = map['top'] ?? 0.0;
    final left = map['left'] ?? 0.0;
    final right = map['right'] ?? 0.0;
    final botom = map['bottom'] ?? 0.0;
    final height = map['height'] ?? uiSize.height;
    final width = map['width'] ?? uiSize.width;
    final _padding = EdgeInsets.only(top: top, left: left, right: right, bottom: botom) / ui.window.devicePixelRatio;
    assert(() {
      print('$_padding');
      return true;
    }());
    final viewInsets = ViewInsets(padding: _padding, size: Size(width, height) / ui.window.devicePixelRatio);
    return viewInsets;
  }

  static Future<int> get bottomHeight async {
    final height = await _channel.invokeMethod('bottomHeight');
    return height;
  }

  static const rate90 = 90.0;
  static const rate60 = 60.0;

  // static Future<double> setRate(double rate) async {
  //   final success = await _channel.invokeMethod('setRefreshRate', rate);
  //   return success;
  // }
}
