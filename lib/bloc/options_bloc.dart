import 'dart:async';

import 'package:animations/animations.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../utils/utils.dart';

class ConfigOptions {
  ConfigOptions({this.pageBuilder, this.platform, this.resample, this.showPerformmanceOverlay, this.resampleOffset});
  TargetPlatform? platform;
  bool? showPerformmanceOverlay;
  PageBuilder? pageBuilder;
  bool? resample;
  int? resampleOffset;

  ConfigOptions coveredWith(ConfigOptions o) {
    return o
      ..pageBuilder ??= pageBuilder
      ..platform ??= platform
      ..showPerformmanceOverlay ??= showPerformmanceOverlay
      ..resample ??= resample
      ..resampleOffset ??= resampleOffset;
  }

  @override
  bool operator ==(Object? other) {
    return identical(other, this) ||
        other is ConfigOptions &&
            other.platform == platform &&
            other.showPerformmanceOverlay == showPerformmanceOverlay &&
            other.pageBuilder == pageBuilder &&
            other.resample == resample &&
            other.resampleOffset == resampleOffset;
  }

  @override
  String toString() {
    return '$runtimeType: $platform, $pageBuilder, showPerformmanceOverlay：$showPerformmanceOverlay,'
        'resample: $resample, resampleOffset: $resampleOffset';
  }
}

class OptionsEvent extends Equatable {
  OptionsEvent(this.options);
  final ConfigOptions options;
  @override
  List<Object?> get props => [options];
}

class OptionsInitEvent extends OptionsEvent {
  OptionsInitEvent(ConfigOptions options) : super(options);
}

enum PageBuilder {
  zoom,
  openUpwards,
  fadeUpwards,
  fadeThrough,
  cupertino,
}

class OptionsState extends Equatable {
  OptionsState({required this.options});

  final ConfigOptions options;

  OptionsState transform(OptionsEvent event) {
    return OptionsState(options: options.coveredWith(event.options));
  }

  /// 使用编译时常量，避免再次分配
  static PageTransitionsBuilder create([PageBuilder? builder]) {
    switch (builder) {
      case PageBuilder.cupertino:
        return const CupertinoPageTransitionsBuilder();
      case PageBuilder.fadeThrough:
        return const FadeThroughPageTransitionsBuilder();
      case PageBuilder.zoom:
        return const ZoomPageTransitionsBuilder();
      case PageBuilder.openUpwards:
        return const OpenUpwardsPageTransitionsBuilder();
      case PageBuilder.fadeUpwards:
      default:
        return const FadeUpwardsPageTransitionsBuilder();
    }
  }

  @override
  List<Object?> get props => [options];
}

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  OptionsBloc() : super(OptionsState(options: ConfigOptions(platform: defaultTargetPlatform)));

  final routeObserver = RouteObserver<PageRoute>();

  @override
  Stream<OptionsState> mapEventToState(OptionsEvent event) async* {
    final _state = state.transform(event);
    yield _state;
    await saveOptions(_state);
  }

  static const _version = 'version';
  static const _versionId = 1.1;
  static const _options = 'options';
  static const _platform = 'platform';
  static const _pageBuilder = 'pageBuilder';
  static const _resample = 'resample';
  static const _resampleOffset = 'resampleOffset';

  Box? box;
  // 简洁
  Box get _box => box!;

  Future<void> init() async {
    box ??= await Hive.openBox(_options);

    // 版本适配
    final _v = _box.get(_version, defaultValue: -1);

    if (_v < _versionId) {
      final _p = _box.get(_platform);

      if (_p != null) {
        if (_p is int && _p < TargetPlatform.values.length) {
          await _box.put(_platform, TargetPlatform.values[_p]);
        } else {
          await _box.delete(_platform);
        }
      }

      final _page = _box.get(_pageBuilder);

      if (_page != null) {
        if (_page is int && _page < PageBuilder.values.length) {
          await _box.put(_pageBuilder, PageBuilder.values[_page]);
        } else {
          await _box.delete(_pageBuilder);
        }
      }
      await _box.put(_version, _versionId);
    }

    final platform = _box.get(_platform, defaultValue: defaultTargetPlatform);
    final pageBuilder = _box.get(_pageBuilder, defaultValue: PageBuilder.fadeUpwards);
    final resample = _box.get(_resample, defaultValue: true);
    final resampleOffset = _box.get(_resampleOffset, defaultValue: -38);

    GestureBinding.instance!
      ..resamplingEnabled = resample
      ..samplingOffset = Duration(milliseconds: resampleOffset!);

    add(OptionsInitEvent(ConfigOptions(
      platform: platform,
      pageBuilder: pageBuilder,
      resample: resample,
      resampleOffset: resampleOffset,
    )));
  }

  Future<void> saveOptions(OptionsState state) async {
    assert(box != null);
    final options = state.options;
    if (options.platform.isNotNull && _box.get(_platform) != options.platform!)
      await _box.put(_platform, options.platform!);

    if (options.pageBuilder.isNotNull && _box.get(_pageBuilder) != options.pageBuilder!) {
      await _box.put(_pageBuilder, options.pageBuilder!);
    }
    if (options.resample.isNotNull && _box.get(_resample) != options.resample!) {
      GestureBinding.instance!.resamplingEnabled = options.resample!;
      await _box.put(_resample, options.resample!);
    }
    if (options.resampleOffset.isNotNull && _box.get(_resampleOffset) != options.resampleOffset!) {
      GestureBinding.instance!.samplingOffset = Duration(milliseconds: options.resampleOffset!);
      await _box.put(_resampleOffset, options.resampleOffset!);
    }
    assert(Log.i('$options', stage: this, name: 'saveOptions'));
  }
}
