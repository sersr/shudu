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
  TextStyle? body1;
  TextStyle? body2;
  TextStyle? body3;
  TextStyle? small1;
  static final _boldColor = Colors.grey[800];
  static final _smallColor = Colors.grey[600];

  TextStylesState([this.bold1, this.title, this.body1, this.body2, this.body3, this.small1]) {
    bold1 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: _boldColor,
      inherit: false,
    );
    title ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: _boldColor,
      inherit: false,
    );
    body1 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: _boldColor,
      inherit: false,
    );
    body2 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: _smallColor,
      inherit: false,
    );
    body3 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 12,
      color: _smallColor,
      inherit: false,
    );
    small1 ??= TextStyle(
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: _smallColor,
      inherit: false,
    );
  }
}

class TextStylesBloc extends Bloc<TextStylesEvent, TextStylesState> {
  TextStylesBloc() : super(TextStylesState());

  @override
  Stream<TextStylesState> mapEventToState(TextStylesEvent event) async* {}
}
