import 'dart:async';

import 'package:animations/animations.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class OptionsEvent extends Equatable {
  OptionsEvent({this.platform, this.showPerformmanceOverlay, this.pageBuilder});
  final TargetPlatform? platform;
  final bool? showPerformmanceOverlay;
  final PageBuilder? pageBuilder;
  @override
  List<Object?> get props => [platform, showPerformmanceOverlay];
}

class OptionsInitEvent extends OptionsEvent {
  OptionsInitEvent({TargetPlatform? platform, bool? showPerformmanceOverlay, PageBuilder? pageBuilder})
      : super(platform: platform, showPerformmanceOverlay: showPerformmanceOverlay, pageBuilder: pageBuilder);
}

enum PageBuilder {
  zoom,
  openUpwards,
  fadeUpwards,
  fadeThrough,
  cupertino,
}

class OptionsState extends Equatable {
  OptionsState({this.platform, this.showPerformmanceOverlay, this.pageTransitionsBuilder});

  final TargetPlatform? platform;
  final bool? showPerformmanceOverlay;
  final PageBuilder? pageTransitionsBuilder;

  OptionsState translate(OptionsEvent event) {
    return OptionsState(
        platform: event.platform ?? platform,
        showPerformmanceOverlay: event.showPerformmanceOverlay ?? showPerformmanceOverlay,
        pageTransitionsBuilder: event.pageBuilder ?? pageTransitionsBuilder);
  }

  static PageTransitionsBuilder create([PageBuilder? builder]) {
    switch (builder) {
      case PageBuilder.cupertino:
        return const CupertinoPageTransitionsBuilder();
      case PageBuilder.fadeThrough:
        return const FadeThroughPageTransitionsBuilder();
      case PageBuilder.openUpwards:
        return const OpenUpwardsPageTransitionsBuilder();
      case PageBuilder.zoom:
        return const ZoomPageTransitionsBuilder();
      case PageBuilder.fadeUpwards:
      default:
        return const FadeUpwardsPageTransitionsBuilder();
    }
  }

  @override
  List<Object?> get props => [platform, showPerformmanceOverlay, pageTransitionsBuilder];
}

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  OptionsBloc() : super(OptionsState(platform: defaultTargetPlatform));

  final routeObserver = RouteObserver<PageRoute>();

  @override
  Stream<OptionsState> mapEventToState(OptionsEvent event) async* {
    final _state = state.translate(event);
    yield _state;
    if (event is! OptionsInitEvent) {
      await saveOptions(_state);
    }
  }

  Box? box;
  Future<void> init() async {
    box ??= await Hive.openBox('options');
    final platform = box!.get('platform') ?? defaultTargetPlatform.index;
    final pageBuilder = box!.get('pageBuilder') ?? PageBuilder.fadeUpwards.index;
    add(OptionsInitEvent(platform: TargetPlatform.values[platform], pageBuilder: PageBuilder.values[pageBuilder]));
  }

  Future<void> saveOptions(OptionsState state) async {
    assert(box != null);
    final mBox = box!;
    if (state.platform != null && mBox.get('platform') != state.platform!.index)
      await mBox.put('platform', state.platform!.index);
    if (state.pageTransitionsBuilder != null && mBox.get('pageBuilder') != state.pageTransitionsBuilder!.index) {
      await mBox.put('pageBuilder', state.pageTransitionsBuilder!.index);
    }
  }
}
