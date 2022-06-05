import 'package:flutter/material.dart';
import 'package:useful_tools/change_notifier.dart';

import '../models/text_style.dart';

class TextStyleConfig extends ChangeNotifierBase {
  TextStyleConfig();
  var _brightness = Brightness.light;
  TextStyleData _data = TextStyleData.normal;
  TextStyleData get data => _data;
  Brightness get brightness => _brightness;

  void notify(Brightness brightness) {
    if (_brightness == brightness) return;
    _brightness = brightness;
    _data = identical(_brightness, Brightness.light)
        ? TextStyleData.normal
        : TextStyleData.dark;
    notifyListeners();
  }
}
