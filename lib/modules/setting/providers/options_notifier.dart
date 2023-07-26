import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:hive/hive.dart';
import 'package:nop/nop.dart';

import '../../../event/repository.dart';

class ConfigOptions {
  ConfigOptions(
      {this.pageBuilder,
      this.platform,
      this.useTextCache,
      // this.useSqflite,
      this.updateOnStart,
      this.themeMode,
      this.extenalStorage,
      this.showPerformanceOverlay});

  TargetPlatform? platform;
  PageBuilder? pageBuilder;
  bool? showPerformanceOverlay;
  bool? useTextCache;
  // bool? useSqflite;
  bool? updateOnStart;
  ThemeMode? themeMode;
  bool? extenalStorage;

  ConfigOptions coveredWith(ConfigOptions o) {
    return o
      ..pageBuilder ??= pageBuilder
      ..platform ??= platform
      ..useTextCache ??= useTextCache
      // ..useSqflite ??= useSqflite
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
            other.updateOnStart == updateOnStart &&
            other.themeMode == themeMode &&
            other.extenalStorage == extenalStorage &&
            // other.useSqflite == useSqflite &&
            other.useTextCache == useTextCache &&
            other.showPerformanceOverlay == showPerformanceOverlay;
  }

  @override
  String toString() {
    return '$runtimeType: $platform, $pageBuilder, ';
  }

  @override
  int get hashCode => Object.hash(
      platform,
      pageBuilder,
      updateOnStart,
      themeMode,
      extenalStorage,
      // useSqflite,
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

class OptionsNotifier extends ChangeNotifierBase with NopLifecycle {
  OptionsNotifier();
  late final Repository repository = getType();

  ConfigOptions _options = ConfigOptions(platform: defaultTargetPlatform);
  ConfigOptions get options => _options;

  set options(ConfigOptions o) {
    if (o == options) return;
    _options = _options.coveredWith(o);
    if (_initDone) EventQueue.pushOne(this, saveOptions);
    notifyListeners();
  }

  static const _version = 'version';
  static const _versionId = 1.1;
  static const _options_ = 'options';
  static const _platform = 'platform';
  static const _pageBuilder = 'pageBuilder';
  static const _useTextCache = 'useTextCache';
  static const _updateOnStart = 'updateOnStart';

  static const _themeMode = 'themeMode';

  static Future<bool> get extenalStorage async {
    return EventQueue.run(setextenalStorage, () async {
      final box = await Hive.openBox('setextenalStorage');
      final result = box.get('extenalStorage', defaultValue: true);
      await box.close();
      return result;
    });
  }

  static Future<void> setextenalStorage(bool use) async {
    return EventQueue.run(setextenalStorage, () async {
      final box = await Hive.openBox('setextenalStorage');
      await box.put('extenalStorage', use);
      return box.close();
    });
  }

  static Future<ThemeMode> getThemeModeUnSafe() async {
    final box = await Hive.openBox(_options_);
    return box.get(_themeMode, defaultValue: ThemeMode.system);
  }

  final eventQueueKey = Object();

  @override
  Future<void> nopInit() {
    super.nopInit();
    return EventQueue.run(this, _init);
  }

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

    final bool useTextCache = box.get(_useTextCache, defaultValue: !kDartIsWeb);
    final bool updateOnStart = box.get(_updateOnStart, defaultValue: true);
    // final bool followSystem = box.get(_followSystem, defaultValue: true);
    final ThemeMode themeMode =
        box.get(_themeMode, defaultValue: ThemeMode.system);
    await box.close();

    options = ConfigOptions(
      platform: platform,
      pageBuilder: pageBuilder,
      // useSqflite: await sqfliteBox,
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
    final extenalStorage = options.extenalStorage;

    if (extenalStorage != null) any.add(setextenalStorage(extenalStorage));

    _updateOptions(box, any, _platform, options.platform);
    _updateOptions(box, any, _pageBuilder, options.pageBuilder);
    _updateOptions(box, any, _useTextCache, options.useTextCache);
    // _updateOptions(box, any, _useImageCache, options.useImageCache);
    _updateOptions(box, any, _updateOnStart, options.updateOnStart);

    _updateOptions(box, any, _themeMode, options.themeMode);

    await any.wait;
    if (kDebugMode) await release(const Duration(milliseconds: 200));
    final ignore = EventQueue.currentTask?.canDiscard ?? false;
    if (!ignore) await box.close();

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
