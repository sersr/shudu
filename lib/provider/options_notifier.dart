import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:useful_tools/useful_tools.dart';

class ConfigOptions {
  ConfigOptions(
      {this.pageBuilder,
      this.platform,
      this.resample,
      this.resampleOffset,
      this.useImageCache,
      this.useTextCache,
      // this.useMemoryImage,
      this.nopResample,
      this.useSqflite3,
      this.showPerformanceOverlay});
  TargetPlatform? platform;
  PageBuilder? pageBuilder;
  bool? resample;
  int? resampleOffset;
  bool? showPerformanceOverlay;

  bool? useImageCache;

  bool? useTextCache;
  // bool? useMemoryImage;
  bool? useSqflite3;
  bool? nopResample;

  ConfigOptions coveredWith(ConfigOptions o) {
    return o
      ..pageBuilder ??= pageBuilder
      ..platform ??= platform
      ..resample ??= resample
      ..useImageCache ??= useImageCache
      ..useTextCache ??= useTextCache
      ..useSqflite3 ??= useSqflite3
      ..nopResample ??= nopResample
      // ..useMemoryImage ??= useMemoryImage
      ..showPerformanceOverlay ??= showPerformanceOverlay
      ..resampleOffset ??= resampleOffset;
  }

  @override
  bool operator ==(Object? other) {
    return identical(other, this) ||
        other is ConfigOptions &&
            other.platform == platform &&
            other.pageBuilder == pageBuilder &&
            other.resample == resample &&
            other.resampleOffset == resampleOffset &&
            other.useImageCache == useImageCache &&
            other.nopResample == nopResample &&
            other.useSqflite3 == useSqflite3 &&
            // other.useMemoryImage == useMemoryImage &&
            other.useTextCache == useTextCache &&
            other.showPerformanceOverlay == showPerformanceOverlay;
  }

  @override
  String toString() {
    return '$runtimeType: $platform, $pageBuilder, '
        'resample: $resample, resampleOffset: $resampleOffset, nopResample: $nopResample';
  }

  @override
  int get hashCode => hashValues(
      platform,
      pageBuilder,
      resample,
      resampleOffset,
      useImageCache,
      // useMemoryImage,
      useSqflite3,
      useTextCache,
      showPerformanceOverlay);
}

enum PageBuilder {
  zoom,
  openUpwards,
  fadeUpwards,
  fadeThrough,
  cupertino,
  fadeRightWards,
}

// class OptionsState extends Equatable {
//   OptionsState({required this.options});

//   final ConfigOptions options;

//   static PageTransitionsBuilder create([PageBuilder? builder]) {
//     switch (builder) {
//       case PageBuilder.cupertino:
//         return const CupertinoPageTransitionsBuilder();
//       case PageBuilder.fadeThrough:
//         return const FadeThroughPageTransitionsBuilder();
//       case PageBuilder.openUpwards:
//         return const OpenUpwardsPageTransitionsBuilder();
//       case PageBuilder.fadeRightWards:
//         return const ZoomTransition();
//       case PageBuilder.zoom:
//         return const ZoomPageTransitionsBuilder();
//       case PageBuilder.fadeUpwards:
//       default:
//         return const FadeUpwardsPageTransitionsBuilder();
//     }
//   }

//   @override
//   List<Object?> get props => [options];
// }

class OptionsNotifier extends ChangeNotifier {
  OptionsNotifier();

  final routeObserver = RouteObserver<PageRoute>();
  ConfigOptions _options = ConfigOptions(platform: defaultTargetPlatform);
  ConfigOptions get options => _options;
  final _event = EventQueue();

  set options(ConfigOptions o) {
    if (o == options) return;
    _options = _options.coveredWith(o);
    _event.addOneEventTask(() => saveOptions());
    notifyListeners();
  }

  static const _version = 'version';
  static const _versionId = 1.1;
  static const _options_ = 'options';
  static const _platform = 'platform';
  static const _pageBuilder = 'pageBuilder';
  static const _resample = 'resample';
  static const _nopResample = 'nopResample';
  static const _resampleOffset = 'resampleOffset';
  static const _useImageCache = 'useImageCache';
  static const _useTextCache = 'useTextCache';
  // static const _useMemoryImage = 'useMemoryImage';

  static Future<bool> get sqfliteBox async {
    final e = EventQueue.createEventQueue('_');
    return e.addEventTask(() async {
      final box = await Hive.openBox('_sqlfiteBox');
      final result = box.get('_useSqflite3', defaultValue: false);
      await box.close();
      return result;
    });
  }

  static Future<void> setSqfliteBox(bool use) async {
    final e = EventQueue.createEventQueue('_');
    return e.addEventTask(() async {
      final box = await Hive.openBox('_sqlfiteBox');
      await box.put('_useSqflite3', use);
      return box.close();
    });
  }


  Box? box;
  // 简洁
  Box get _box => box!;

  Future<void> init() async {
    if (box != null) return;
    box ??= await Hive.openBox(_options_);

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

    final TargetPlatform platform =
        _box.get(_platform, defaultValue: defaultTargetPlatform);

    final PageBuilder pageBuilder =
        _box.get(_pageBuilder, defaultValue: PageBuilder.zoom);

    final bool resample = _box.get(_resample, defaultValue: true);
    final int resampleOffset = _box.get(_resampleOffset, defaultValue: 0);
    final bool useImageCache = _box.get(_useImageCache, defaultValue: true);
    final bool useTextCache = _box.get(_useTextCache, defaultValue: true);
    // final bool useMemoryImage = _box.get(_useMemoryImage, defaultValue: false);
    final bool nopResample = _box.get(_nopResample, defaultValue: true);

    GestureBinding.instance!
      ..resamplingEnabled = resample
      ..samplingOffset = Duration(milliseconds: resampleOffset);
    NopGestureBinding.instance!.nopResamplingEnabled = nopResample;
    // resample = await listenRate();

    options = ConfigOptions(
        platform: platform,
        pageBuilder: pageBuilder,
        resample: resample,
        useImageCache: useImageCache,
        // useMemoryImage: useMemoryImage,
        nopResample: nopResample,
        useSqflite3: await sqfliteBox,
        useTextCache: useTextCache,
        resampleOffset: resampleOffset);
  }

  Future<void> saveOptions() async {
    assert(box != null);
    final _f = <Future>[];

    final platform = options.platform;
    if (platform != null && _box.get(_platform) != platform)
      _f.add(_box.put(_platform, platform));

    final pageBuilder = options.pageBuilder;
    if (pageBuilder != null && _box.get(_pageBuilder) != pageBuilder)
      _f.add(_box.put(_pageBuilder, pageBuilder));

    final useImageCache = options.useImageCache;
    if (useImageCache != null && _box.get(_useImageCache) != useImageCache)
      _f.add(_box.put(_useImageCache, useImageCache));

    final useSqflite3 = options.useSqflite3;
    if (useSqflite3 != null && await sqfliteBox != useSqflite3)
      _f.add(setSqfliteBox(useSqflite3));

    // final useMemoryImage = options.useMemoryImage;
    // if (useMemoryImage != null && _box.get(_useMemoryImage) != useMemoryImage)
    //   _f.add(_box.put(_useMemoryImage, useMemoryImage));

    final useTextCache = options.useTextCache;
    if (useTextCache != null && _box.get(_useTextCache) != useTextCache)
      _f.add(_box.put(_useTextCache, useTextCache));

    final resample = options.resample;
    if (resample != null && _box.get(_resample) != resample) {
      GestureBinding.instance!.resamplingEnabled = resample;
      _f.add(_box.put(_resample, resample));
    }

    final resampleOffset = options.resampleOffset;
    if (resampleOffset != null && _box.get(_resampleOffset) != resampleOffset) {
      GestureBinding.instance!.samplingOffset =
          Duration(milliseconds: resampleOffset);
      _f.add(_box.put(_resampleOffset, resampleOffset));
    }
    final nopResample = options.nopResample;
    if (nopResample != null && _box.get(_nopResample) != nopResample) {
      NopGestureBinding.instance!.nopResamplingEnabled = nopResample;
      _f.add(_box.put(_nopResample, nopResample));
    }
    await Future.wait(_f);
    assert(Log.i('$options'));
  }
}
