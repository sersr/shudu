import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OptionsEvent extends Equatable {
  OptionsEvent(this.platform);
  final TargetPlatform platform;
  @override
  List<Object> get props => [platform];
}

class OptionsState extends Equatable {
  OptionsState(this.platform);
  final TargetPlatform platform;

  @override
  List<Object> get props => [platform];
}

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  OptionsBloc(TargetPlatform platform) : super(OptionsState(platform));
  final routeObserver = RouteObserver<PageRoute>();
  @override
  Stream<OptionsState> mapEventToState(OptionsEvent event) async* {
    yield OptionsState(event.platform);
  }
}
