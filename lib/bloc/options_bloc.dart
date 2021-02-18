import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OptionsEvent extends Equatable {
  OptionsEvent({this.platform, this.showPerformmanceOverlay});
  final TargetPlatform? platform;
  final bool? showPerformmanceOverlay;
  @override
  List<Object?> get props => [platform, showPerformmanceOverlay];
}

class OptionsState extends Equatable {
  OptionsState({this.platform, this.showPerformmanceOverlay});
  final TargetPlatform? platform;
  final bool? showPerformmanceOverlay;
  @override
  List<Object?> get props => [platform, showPerformmanceOverlay];
}

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  OptionsBloc(TargetPlatform platform) : super(OptionsState(platform: platform));
  final routeObserver = RouteObserver<PageRoute>();
  bool showPerformmanceOverlay = false;
  TargetPlatform? platform;
  @override
  Stream<OptionsState> mapEventToState(OptionsEvent event) async* {
    if (event.platform != null) {
      platform = event.platform;
    }
    if (event.showPerformmanceOverlay != null) {
      showPerformmanceOverlay = event.showPerformmanceOverlay!;
    }
    yield OptionsState(platform: platform, showPerformmanceOverlay: showPerformmanceOverlay);
  }
}
