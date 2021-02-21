import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TextStylesEvent extends Equatable {
  const TextStylesEvent();
  @override
  List<Object> get props => [];
}

class TextStylesState {
  TextStyle? bold1;
  TextStyle? title;
  TextStyle? title2;
  TextStyle? body1;
  TextStyle? body2;
  TextStyle? body3;
  TextStyle? small1;
  static final _greyColor = Color.fromRGBO(120, 120, 120, 1);
  static final _blackColor = Color.fromRGBO(10, 10, 10, 1);

  // static final _smallColor = Colors.grey[500];

  TextStylesState([this.bold1, this.title, this.body1, this.body2, this.body3, this.small1]) {
    bold1 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: _greyColor,
      inherit: false,
    );
    title ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: _blackColor,
      inherit: false,
    );
    title2 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: _blackColor,
      inherit: false,
    );
    body1 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: _greyColor,
      inherit: false,
    );
    body2 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: _greyColor,
      inherit: false,
    );
    body3 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 12,
      color: _greyColor,
      inherit: false,
    );
    small1 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: _greyColor,
      inherit: false,
    );
  }
}

class TextStylesBloc extends Bloc<TextStylesEvent, TextStylesState> {
  TextStylesBloc() : super(TextStylesState());

  @override
  Stream<TextStylesState> mapEventToState(TextStylesEvent event) async* {}
}
