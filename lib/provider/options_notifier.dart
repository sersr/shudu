import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

class ConfigOptions {
  ConfigOptions(
      {this.pageBuilder,
      this.platform,
      this.resample,
      this.useImageCache,
      this.useTextCache,
      this.nopResample,
      this.useSqflite,
      this.updateOnStart,
      this.themeMode,
      this.extenalStorage,
      this.showPerformanceOverlay});

  TargetPlatform? platform;
  PageBuilder? pageBuilder;
  bool? resample;
  bool? showPerformanceOverlay;
  bool? useImageCache;
  bool? useTextCache;
  bool? useSqflite;
  bool? nopResample;
  bool? updateOnStart;
  ThemeMode? themeMode;
  bool? extenalStorage;

  ConfigOptions coveredWith(ConfigOptions o) {
    return o
      ..pageBuilder ??= pageBuilder
      ..platform ??= platform
      ..resample ??= resample
      ..useImageCache ??= useImageCache
      ..useTextCache ??= useTextCache
      ..useSqflite ??= useSqflite
      ..nopResample ??= nopResample
      ..updateOnStart ??= updateOnStart
      ..themeMode ??= themeMode
      ..extenalStorage ??= extenalStorage
      ..showPerformanceOverlay ??= showPerformanceOverlay;
  }

  @override
  bool operator ==(Object? other) {
    return identical(other, this) ||
        other is ConfigOptions &&
            other.platform == platform &&
            other.pageBuilder == pageBuilder &&
            other.resample == resample &&
            other.updateOnStart == updateOnStart &&
            other.themeMode == themeMode &&
            other.extenalStorage == extenalStorage &&
            other.useImageCache == useImageCache &&
            other.nopResample == nopResample &&
            other.useSqflite == useSqflite &&
            other.useTextCache == useTextCache &&
            other.showPerformanceOverlay == showPerformanceOverlay;
  }

  @override
  String toString() {
    return '$runtimeType: $platform, $pageBuilder, '
        'resample: $resample, nopResample: $nopResample';
  }

  @override
  int get hashCode => hashValues(
      platform,
      pageBuilder,
      resample,
      updateOnStart,
      themeMode,
      extenalStorage,
      useImageCache,
      useSqflite,
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

class OptionsNotifier extends ChangeNotifier {
  OptionsNotifier();

  final routeObserver = RouteObserver<PageRoute>();
  ConfigOptions _options = ConfigOptions(platform: defaultTargetPlatform);
  ConfigOptions get options => _options;

  set options(ConfigOptions o) {
    if (o == options) return;
    _options = _options.coveredWith(o);
    if (_initDone) EventQueue.runOneTaskOnQueue(OptionsNotifier, saveOptions);
    notifyListeners();
  }

  static const _version = 'version';
  static const _versionId = 1.1;
  static const _options_ = 'options';
  static const _platform = 'platform';
  static const _pageBuilder = 'pageBuilder';
  static const _resample = 'resample';
  static const _nopResample = 'nopResample';
  static const _useImageCache = 'useImageCache';
  static const _useTextCache = 'useTextCache';
  static const _updateOnStart = 'updateOnStart';
  // static const _followSystem = 'followSystem';
  static const _themeMode = 'themeMode';
  static ThemeMode mode = ThemeMode.system;

  static void autoSetStatus(BuildContext context) {
    final mode = context.read<OptionsNotifier>().options.themeMode;

    uiStyle(dark: isDarkMode(mode));
  }

  static bool isDarkMode(ThemeMode? mode) {
    var dark = false;
    if (mode == ThemeMode.system) {
      dark = window.platformBrightness == Brightness.dark;
    } else {
      dark = mode == ThemeMode.dark;
    }
    return dark;
  }

  static Future<bool> get extenalStorage async {
    return EventQueue.runTaskOnQueue(setextenalStorage, () async {
      final box = await Hive.openBox('setextenalStorage');
      final result = box.get('extenalStorage', defaultValue: true);
      await box.close();
      return result;
    });
  }

  static Future<void> setextenalStorage(bool use) async {
    return EventQueue.runTaskOnQueue(setextenalStorage, () async {
      final box = await Hive.openBox('setextenalStorage');
      await box.put('extenalStorage', use);
      return box.close();
    });
  }

  static Future<bool> get sqfliteBox async {
    return EventQueue.runTaskOnQueue(setSqfliteBox, () async {
      final box = await Hive.openBox('_sqfliteBox');
      final result = box.get('_useSqflite', defaultValue: false);
      await box.close();
      return result;
    });
  }

  static Future<void> setSqfliteBox(bool use) async {
    return EventQueue.runTaskOnQueue(setSqfliteBox, () async {
      final box = await Hive.openBox('_sqfliteBox');
      await box.put('_useSqflite', use);
      return box.close();
    });
  }

  static Future<ThemeMode> getThemeMode() async {
    return EventQueue.runTaskOnQueue(OptionsNotifier, () async {
      final box = await Hive.openBox(_options_);
      final mode = box.get(_themeMode, defaultValue: ThemeMode.system);
      await box.close();
      return mode;
    });
  }

  final eventQueueKey = Object();

  Future<void> init() => EventQueue.runTaskOnQueue(OptionsNotifier, _init);
  bool _initDone = false;
  Future<void> _init() async {
    if (_initDone) return;
    final box = await Hive.openBox(_options_);

    // 版本适配
    final _v = box.get(_version, defaultValue: -1);

    if (_v < _versionId) {
      final _p = box.get(_platform);

      if (_p != null) {
        if (_p is int && _p < TargetPlatform.values.length) {
          await box.put(_platform, TargetPlatform.values[_p]);
        } else {
          await box.delete(_platform);
        }
      }

      final _page = box.get(_pageBuilder);

      if (_page != null) {
        if (_page is int && _page < PageBuilder.values.length) {
          await box.put(_pageBuilder, PageBuilder.values[_page]);
        } else {
          await box.delete(_pageBuilder);
        }
      }
      await box.put(_version, _versionId);
    }

    final TargetPlatform platform =
        box.get(_platform, defaultValue: defaultTargetPlatform);

    final PageBuilder pageBuilder =
        box.get(_pageBuilder, defaultValue: PageBuilder.zoom);

    final bool resample = box.get(_resample, defaultValue: false);
    final bool useImageCache = box.get(_useImageCache, defaultValue: true);
    final bool useTextCache = box.get(_useTextCache, defaultValue: true);
    final bool nopResample = box.get(_nopResample, defaultValue: true);
    final bool updateOnStart = box.get(_updateOnStart, defaultValue: true);
    // final bool followSystem = box.get(_followSystem, defaultValue: true);
    final ThemeMode themeMode =
        box.get(_themeMode, defaultValue: ThemeMode.system);
    GestureBinding.instance!.resamplingEnabled = resample;
    NopGestureBinding.instance!.nopResamplingEnabled = nopResample;
    await box.close();

    options = ConfigOptions(
      platform: platform,
      pageBuilder: pageBuilder,
      resample: resample,
      useImageCache: useImageCache,
      nopResample: nopResample,
      useSqflite: await sqfliteBox,
      useTextCache: useTextCache,
      updateOnStart: updateOnStart,
      themeMode: themeMode,
      extenalStorage: await extenalStorage,
    );

    _initDone = true;
  }

  Future<void> saveOptions() async {
    assert(_initDone);
    final box = await Hive.openBox(_options_);

    final any = FutureAny();

    final useSqflite3 = options.useSqflite;
    final extenalStorage = options.extenalStorage;

    if (useSqflite3 != null) any.add(setSqfliteBox(useSqflite3));
    if (extenalStorage != null) any.add(setextenalStorage(extenalStorage));

    _updateOptions(box, any, _platform, options.platform);
    _updateOptions(box, any, _pageBuilder, options.pageBuilder);
    _updateOptions(box, any, _useTextCache, options.useTextCache);
    _updateOptions(box, any, _useImageCache, options.useImageCache);
    _updateOptions(box, any, _updateOnStart, options.updateOnStart);

    _updateOptions(box, any, _themeMode, options.themeMode);

    if (_updateOptions(box, any, _resample, options.resample))
      GestureBinding.instance!.resamplingEnabled = options.resample!;

    if (_updateOptions(box, any, _nopResample, options.nopResample))
      NopGestureBinding.instance!.nopResamplingEnabled = options.nopResample!;

    await any.wait;
    await box.close();
    assert(any.isEmpty);
    assert(Log.i('$options'));
  }

  bool _updateOptions(
      Box box, FutureAny any, String updatItem, Object? updateValue) {
    if (updateValue != null && box.get(updatItem) != updateValue) {
      any.add(box.put(updatItem, updateValue));
      return true;
    }
    return false;
  }
}
