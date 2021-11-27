import 'package:flutter/material.dart';

class TextStyleData {
  const TextStyleData({
    required this.bigTitle1,
    required this.body1,
    required this.body2,
    required this.body3,
    required this.small1,
    required this.title2,
    required this.title3,
  });
  final TextStyle bigTitle1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle body1;
  final TextStyle body2;
  final TextStyle body3;
  final TextStyle small1;
  static const TextStyleData normal = TextStyleData(
    bigTitle1: TextStyleConfig.bigTitle1,
    body1: TextStyleConfig.body1,
    body2: TextStyleConfig.body2,
    body3: TextStyleConfig.body3,
    small1: TextStyleConfig.small1,
    title2: TextStyleConfig.title2,
    title3: TextStyleConfig.title3,
  );
  static TextStyleData dark = TextStyleData(
    bigTitle1: TextStyleConfig.bigTitle1.blackColor9,
    body1: TextStyleConfig.body1.blackColor8,
    body2: TextStyleConfig.body2.blackColor6,
    body3: TextStyleConfig.body3.blackColor5,
    small1: TextStyleConfig.small1.blackColor5,
    title2: TextStyleConfig.title2.blackColor7,
    title3: TextStyleConfig.title3.blackColor8,
  );
}

class TextStyleConfig extends ChangeNotifier {
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

  static const TextStyle bigTitle1 = TextStyle(
    fontSize: 18,
    color: blackColor1,
    inherit: false,
  );
  static const TextStyle title2 = TextStyle(
    fontSize: 14,
    color: blackColor3,
    inherit: false,
  );
  static const TextStyle title3 = TextStyle(
    fontSize: 14,
    color: blackColor5,
    inherit: false,
  );
  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    color: blackColor2,
    inherit: false,
  );
  static const TextStyle body2 = TextStyle(
    fontSize: 13,
    color: blackColor4,
    inherit: false,
  );
  static const TextStyle body3 = TextStyle(
    fontSize: 12,
    color: blackColor6,
    inherit: false,
  );
  static const TextStyle small1 = TextStyle(
    fontSize: 10,
    color: blackColor6,
    inherit: false,
  );
  static const whiteColor1 = Color.fromARGB(255, 245, 245, 245);
  static const whiteColor2 = Color.fromARGB(255, 240, 240, 240);
  static const whiteColor3 = Color.fromARGB(255, 228, 228, 228);
  static const whiteColor4 = Color.fromARGB(255, 221, 221, 221);
  static const whiteColor5 = Color.fromARGB(255, 185, 185, 185);
  static const blackColor1 = Color(0xff202020);
  static const blackColor2 = Color(0xff2a2a2a);
  static const blackColor3 = Color(0xff383838);
  static const blackColor4 = Color.fromARGB(255, 87, 87, 87);
  static const blackColor5 = Color.fromARGB(255, 112, 112, 112);
  static const blackColor6 = Color.fromARGB(255, 139, 139, 139);
  static const blackColor7 = Color.fromARGB(255, 158, 158, 158);
  static const blackColor8 = Color.fromARGB(255, 192, 192, 192);
  static const blackColor9 = Color.fromARGB(255, 197, 197, 197);
  static const blackColor10 = Color.fromARGB(255, 219, 219, 219);
}

extension TextStyleExt on TextStyle {
  TextStyle get blackColor1 {
    return copyWith(color: TextStyleConfig.blackColor1);
  }

  TextStyle get blackColor2 {
    return copyWith(color: TextStyleConfig.blackColor2);
  }

  TextStyle get blackColor3 {
    return copyWith(color: TextStyleConfig.blackColor3);
  }

  TextStyle get blackColor4 {
    return copyWith(color: TextStyleConfig.blackColor4);
  }

  TextStyle get blackColor5 {
    return copyWith(color: TextStyleConfig.blackColor5);
  }

  TextStyle get blackColor6 {
    return copyWith(color: TextStyleConfig.blackColor6);
  }

  TextStyle get blackColor7 {
    return copyWith(color: TextStyleConfig.blackColor7);
  }

  TextStyle get blackColor8 {
    return copyWith(color: TextStyleConfig.blackColor8);
  }

  TextStyle get blackColor9 {
    return copyWith(color: TextStyleConfig.blackColor9);
  }

  TextStyle get blackColor10 {
    return copyWith(color: TextStyleConfig.blackColor10);
  }

  TextStyle get whiteColor1 {
    return copyWith(color: TextStyleConfig.whiteColor1);
  }

  TextStyle get whiteColor2 {
    return copyWith(color: TextStyleConfig.whiteColor2);
  }

  TextStyle get whiteColor3 {
    return copyWith(color: TextStyleConfig.whiteColor3);
  }

  TextStyle get whiteColor4 {
    return copyWith(color: TextStyleConfig.whiteColor4);
  }

  TextStyle get whiteColor5 {
    return copyWith(color: TextStyleConfig.whiteColor5);
  }
}
