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
    bigTitle1: TextStyleData.bigTitle1Default,
    body1: TextStyleData.body1Default,
    body2: TextStyleData.body2Default,
    body3: TextStyleData.body3Default,
    small1: TextStyleData.small1Default,
    title2: TextStyleData.title2Default,
    title3: TextStyleData.title3Default,
  );
  static TextStyleData dark = TextStyleData(
    bigTitle1: TextStyleData.bigTitle1Default.blackColor9,
    body1: TextStyleData.body1Default.blackColor8,
    body2: TextStyleData.body2Default.blackColor6,
    body3: TextStyleData.body3Default.blackColor5,
    small1: TextStyleData.small1Default.blackColor5,
    title2: TextStyleData.title2Default.blackColor7,
    title3: TextStyleData.title3Default.blackColor8,
  );

  static const TextStyle bigTitle1Default = TextStyle(
    fontSize: 18,
    color: blackColor1,
    inherit: false,
  );
  static const TextStyle title2Default = TextStyle(
    fontSize: 14,
    color: blackColor3,
    inherit: false,
  );
  static const TextStyle title3Default = TextStyle(
    fontSize: 14,
    color: blackColor5,
    inherit: false,
  );
  static const TextStyle body1Default = TextStyle(
    fontSize: 14,
    color: blackColor2,
    inherit: false,
  );
  static const TextStyle body2Default = TextStyle(
    fontSize: 13,
    color: blackColor4,
    inherit: false,
  );
  static const TextStyle body3Default = TextStyle(
    fontSize: 12,
    color: blackColor6,
    inherit: false,
  );
  static const TextStyle small1Default = TextStyle(
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
    return copyWith(color: TextStyleData.blackColor1);
  }

  TextStyle get blackColor2 {
    return copyWith(color: TextStyleData.blackColor2);
  }

  TextStyle get blackColor3 {
    return copyWith(color: TextStyleData.blackColor3);
  }

  TextStyle get blackColor4 {
    return copyWith(color: TextStyleData.blackColor4);
  }

  TextStyle get blackColor5 {
    return copyWith(color: TextStyleData.blackColor5);
  }

  TextStyle get blackColor6 {
    return copyWith(color: TextStyleData.blackColor6);
  }

  TextStyle get blackColor7 {
    return copyWith(color: TextStyleData.blackColor7);
  }

  TextStyle get blackColor8 {
    return copyWith(color: TextStyleData.blackColor8);
  }

  TextStyle get blackColor9 {
    return copyWith(color: TextStyleData.blackColor9);
  }

  TextStyle get blackColor10 {
    return copyWith(color: TextStyleData.blackColor10);
  }

  TextStyle get whiteColor1 {
    return copyWith(color: TextStyleData.whiteColor1);
  }

  TextStyle get whiteColor2 {
    return copyWith(color: TextStyleData.whiteColor2);
  }

  TextStyle get whiteColor3 {
    return copyWith(color: TextStyleData.whiteColor3);
  }

  TextStyle get whiteColor4 {
    return copyWith(color: TextStyleData.whiteColor4);
  }

  TextStyle get whiteColor5 {
    return copyWith(color: TextStyleData.whiteColor5);
  }
}
