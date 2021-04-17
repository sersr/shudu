import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TextStylesEvent extends Equatable {
  const TextStylesEvent();
  @override
  List<Object> get props => [];
}

class TextStylesState {

  TextStylesState() {
    // bold1 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontWeight: FontWeight.bold,
    //   fontSize: 15,
    //   color: greyColor2,
    //   inherit: false,
    // );
    // bigTitle ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 17,
    //   color: greyColor4,
    //   inherit: false,
    // );
    // title1 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 16,
    //   color: greyColor4,
    //   inherit: false,
    // );
    // title2 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 14,
    //   color: greyColor4,
    //   inherit: false,
    // );
    // title3 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 14,
    //   color: greyColor3,
    //   inherit: false,
    // );
    // body1 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 14,
    //   color: greyColor2,
    //   inherit: false,
    // );
    // body2 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 13,
    //   color: greyColor2,
    //   inherit: false,
    // );
    // body3 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 12,
    //   color: greyColor1,
    //   inherit: false,
    // );
    // small1 ??= TextStyle(
    //   // fontFamily: 'NotoSansSC',
    //   fontSize: 10,
    //   color: greyColor3,
    //   inherit: false,
    // );
  }
}

class TextStylesBloc extends Bloc<TextStylesEvent, TextStylesState> {
  TextStylesBloc() : super(TextStylesState());
  // TextStyle bold1 = TextStyle(
  //   // fontFamily: 'NotoSansSC',
  //   fontWeight: FontWeight.bold,
  //   fontSize: 15,
  //   color: greyColor2,
  //   inherit: false,
  // );
  // TextStyle bigTitle = TextStyle(
  //   // fontFamily: 'NotoSansSC',
  //   fontSize: 17,
  //   color: blackColor2,
  //   inherit: false,
  // );
  // TextStyle title1 = TextStyle(
  //   // fontFamily: 'NotoSansSC',
  //   fontSize: 16,
  //   color: blackColor3,
  //   inherit: false,
  // );
  TextStyle title2 = TextStyle(
    // fontFamily: 'NotoSansSC',
    fontSize: 14,
    color: blackColor3,
    inherit: false,
  );
  TextStyle title3 = TextStyle(
    // fontFamily: 'NotoSansSC',
    fontSize: 14,
    color: blackColor5,
    inherit: false,
  );
  TextStyle body1 = TextStyle(
    // fontFamily: 'NotoSansSC',
    fontSize: 14,
    color: blackColor2,
    inherit: false,
  );
  TextStyle body2 = TextStyle(
    // fontFamily: 'NotoSansSC',
    fontSize: 13,
    color: blackColor6,
    inherit: false,
  );
  TextStyle body3 = TextStyle(
    // fontFamily: 'NotoSansSC',
    fontSize: 12,
    color: blackColor10,
    inherit: false,
  );
  TextStyle small1 = TextStyle(
    // fontFamily: 'NotoSansSC',
    fontSize: 10,
    color: blackColor7,
    inherit: false,
  );
  // static const whiteColor1 = Color(0xffefefef);
  // static const whiteColor2 = Color(0xffafafaf);
  // static const whiteColor3 = Color(0xff8f8f8f);
  // static const whiteColor4 = Color(0xff5f5f5f);
  // static const whiteColor5 = Color(0xff333333);
  static const blackColor1 = Color(0xff202020);
  static const blackColor2 = Color(0xff2a2a2a);
  static const blackColor3 = Color(0xff383838);
  static const blackColor4 = Color(0xff414141);
  static const blackColor5 = Color(0xff585858);
  static const blackColor6 = Color(0xff6a6a6a);
  static const blackColor7 = Color(0xff747474);
  static const blackColor8 = Color(0xff7c7c7c);
  static const blackColor9 = Color(0xff858585);
  static const blackColor10 = Color(0xff8b8b8b);

  @override
  Stream<TextStylesState> mapEventToState(TextStylesEvent event) async* {}
}
