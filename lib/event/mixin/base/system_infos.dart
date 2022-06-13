import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:android_external_storage/android_external_storage.dart';
import 'package:bangs/bangs.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memory_info/memory_info.dart';
import 'package:nop/nop.dart';
import 'package:nop_db_sqflite/nop_db_sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../modules/setting/setting.dart';

class BookIsolateArgs {
  final String appPath;
  final String cachePath;
  BookIsolateArgs(this.appPath, this.cachePath);

  @override
  String toString() {
    return 'appPath: $appPath | cachePath: $cachePath';
  }
}

/// [Repository]需要的信息
mixin SystemInfos {
  Future<BookIsolateArgs> initStartArgs() async {
    SystemChrome.setSystemUIChangeCallback(_onSystemOverlaysChanges);
    if (defaultTargetPlatform == TargetPlatform.android) {
      Bangs.bangs.setNavigationChangeCallback(_navState);
    }

    if (kIsWeb) {
      final root = windows.current;
      final appPath = join(root, 'shudu');
      final cachePath = join(appPath, 'cache');
      return BookIsolateArgs(appPath, cachePath);
    }
    final _waits = FutureAny();

    String? appDirExt;
    List<Directory>? cacheDirs;

    _waits
      ..add(setOrientation(true))
      ..add(getBatteryLevel);
    bool externalDir = true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        SqfliteMainIsolate.initMainDb();
        break;
      default:
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 存储在外部，避免重新安装时数据丢失
      _waits.add(getExternalStorageDirectories().then((f) async {
        if (f != null && f.isNotEmpty) {
          String? extPath;
          try {
            extPath =
                await AndroidExternalStorage.getExternalStorageDirectory();
          } catch (e) {
            Log.i(e);
          }
          final appPath = extPath ?? '/storage/emulated/0';
          appDirExt = appPath;
        }

        _waits
          ..add(getExternalCacheDirectories().then((dirs) => cacheDirs = dirs))
          ..add(Bangs.safePadding
              .then((value) => _statusHeight = value.padding.top))
          ..add(Permission.manageExternalStorage.status.then((status) {
            if (status.isDenied) {
              return OptionsNotifier.extenalStorage.then((request) {
                return OptionsNotifier.setextenalStorage(false)
                    .whenComplete(() {
                  if (request) {
                    return Permission.manageExternalStorage
                        .request()
                        .then((status) {
                      if (status.isDenied) externalDir = false;
                    });
                  } else {
                    externalDir = false;
                  }
                });
              });
            }
          }));
      }));
    }

    late Directory appDir;

    _waits.add(getApplicationDocumentsDirectory().then((dir) => appDir = dir));

    await _waits.wait;
    if (!externalDir) appDirExt = null;

    final _appPath = appDirExt ?? appDir.path;
    final appPath = join(_appPath, 'shudu');

    const fs = LocalFileSystem();
    final dir = fs.currentDirectory.childDirectory(appPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final cachePath = cacheDirs?.isNotEmpty == true
        ? cacheDirs!.first.path
        : join(appPath, 'cache');

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final memory = await getMemoryInfo();
      final freeMem = memory.freeMem;
      const size = 1.5 * 1024;
      if (freeMem != null && freeMem < size) {
        CacheBinding.instance!.imageRefCache!.length = 250;
      }
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      getMemoryInfo().then((memory) {
        final freeMem = memory.freeMem;
        const size = 1.5 * 1024;
        if (freeMem != null && freeMem < size) {
          CacheBinding.instance!.imageRefCache!.length = 250;
        }
      });
    }

    return BookIsolateArgs(appPath, cachePath);
  }

  Battery? _battery;

  int level = 50;

  final extenalStorage = ValueNotifier(true);

  DeviceInfoPlugin? deviceInfo;

  Future<int> get getBatteryLevel async {
    _battery ??= Battery();

    deviceInfo ??= DeviceInfoPlugin();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      var iosInfo = await deviceInfo!.iosInfo;

      if (!iosInfo.isPhysicalDevice) return level;
    }
    if (Platform.isWindows || Platform.isMacOS) {
      return level;
    }
    level = await _battery!.batteryLevel;

    return level;
  }

  // 状态栏遮挡占用的高度
  double _statusHeight = 0;
  double get statusHeight => _statusHeight;

  // 底部导航栏高度
  double _height = 0;
  double get height => _height;
  void _navState(bool isShow, int height) {
    assert(Log.i('navHeight: $height | $isShow'));
    _height = height / ui.window.devicePixelRatio;
  }

  MemoryInfoPlugin? memoryInfoPlugin;

  Future<Memory> getMemoryInfo() {
    memoryInfoPlugin ??= MemoryInfoPlugin();
    return memoryInfoPlugin!.memoryInfo;
  }

  /// 系统UI
  bool _systemOverlaysAreVisible = true;
  bool get systemOverlaysAreVisible => _systemOverlaysAreVisible;

  Future<void> _onSystemOverlaysChanges(bool visible) async {
    _systemOverlaysAreVisible = visible;
    if (_changesListeners.isNotEmpty)
      for (var c in _changesListeners) {
        c(visible);
      }
  }

  final _changesListeners = <BoolCallback>{};

  void addSystemOverlaysListener(BoolCallback callback) {
    if (!_changesListeners.contains(callback)) {
      _changesListeners.add(callback);
    }
  }

  void removeSystemOverlaysListener(BoolCallback callback) {
    _changesListeners.remove(callback);
  }
}
typedef BoolCallback = void Function(bool visible);
