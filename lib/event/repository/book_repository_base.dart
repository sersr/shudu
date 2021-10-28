import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:android_external_storage/android_external_storage.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memory_info/memory_info.dart';
import 'package:nop_db/nop_db.dart';
import 'package:nop_db_sqflite/nop_db_sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:useful_tools/binding.dart';
import 'package:useful_tools/common.dart';

import '../../provider/options_notifier.dart';
import '../base/book_event.dart';
import '../event.dart';

abstract class BookRepositoryBase extends Repository implements SendEvent {
  Battery? _battery;

  @override
  final extenalStorage = ValueNotifier(true);

  @override
  late BookEvent bookEvent = BookEventMain(this);

  DeviceInfoPlugin? deviceInfo;
  @override
  Future<int> get getBatteryLevel async {
    _battery ??= Battery();

    deviceInfo ??= DeviceInfoPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
      // var androidInfo = await deviceInfo.androidInfo;
      level = await _battery!.batteryLevel;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      var iosInfo = await deviceInfo!.iosInfo;

      if (!iosInfo.isPhysicalDevice) return level;

      level = await _battery!.batteryLevel;
    }

    return level;
  }

  MemoryInfoPlugin? memoryInfoPlugin;

  @override
  Future<Memory> getMemoryInfo() {
    memoryInfoPlugin ??= MemoryInfoPlugin();
    return memoryInfoPlugin!.memoryInfo;
  }

  bool _systemOverlaysAreVisible = false;
  @override
  bool get systemOverlaysAreVisible => _systemOverlaysAreVisible;

  Future<void> _onSystemOverlaysChanges(bool visible) async {
    _systemOverlaysAreVisible = visible;
    if (_changesListeners.isNotEmpty)
      for (var c in _changesListeners) {
        c(visible);
      }
  }

  final _changesListeners = <BoolCallback>{};
  @override
  void addSystemOverlaysListener(BoolCallback callback) {
    if (!_changesListeners.contains(callback)) {
      _changesListeners.add(callback);
    }
  }

  @override
  void removeSystemOverlaysListener(BoolCallback callback) {
    _changesListeners.remove(callback);
  }

  bool hasBottomNavbar = false;
  double height = 0;

  Isolate? _isolate;

  set isolate(Isolate? n) {
    if (_isolate != n && _isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
    }
    _isolate = n;
    _init.value = _isolate != null;
  }

  Future<void> onDone(ReceivePort rcPort);
  Future<void> onInit() async {
    if (_isolate != null) {
      assert(_init.value);
      return;
    }
    SystemChrome.setSystemUIChangeCallback(_onSystemOverlaysChanges);
    final _waits = FutureAny();

    String? appDirExt;
    List<Directory>? cacheDirs;

    _waits
      ..add(setOrientation(true))
      ..add(getBatteryLevel);

    if (Platform.isAndroid) {
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
          appDirExt = '$appPath/shudu';
        }
        _waits
          ..add(getExternalCacheDirectories().then((dirs) => cacheDirs = dirs))
          ..add(Permission.manageExternalStorage.status.then((status) {
            if (status.isDenied) {
              return OptionsNotifier.extenalStorage.then((request) {
                return OptionsNotifier.setextenalStorage(false)
                    .whenComplete(() {
                  if (request) {
                    return Permission.manageExternalStorage
                        .request()
                        .then((status) {
                      if (status.isDenied) appDirExt = null;
                    });
                  } else {
                    appDirExt = null;
                  }
                });
              });
            }
          }));
      }));
    }

    late Directory appDir;
    bool useSqflite3 = false;
    _waits.add(getApplicationDocumentsDirectory().then((dir) {
      appDir = dir;
    }));
    _waits.add(OptionsNotifier.sqfliteBox.then((value) => useSqflite3 = value));

    await _waits.wait;

    final appPath = appDirExt ?? appDir.path;

    const fs = LocalFileSystem();
    final dir = fs.currentDirectory.childDirectory(appPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final cachePath = cacheDirs?.isNotEmpty == true
        ? cacheDirs!.first.path
        : join(appPath, 'cache');

    final rcPort = ReceivePort();
    bool sqfliteFfiEnabled = false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        sqfliteFfiEnabled = true;
        break;
      default:
    }
    Log.w('useSqflite3: $useSqflite3', onlyDebug: false);
    if (!sqfliteFfiEnabled && useSqflite3) {
      SqfliteMainIsolate.initMainDb();
    }

    /// Isolate event
    final newIsolate = await Isolate.spawn(isolateEvent,
        [rcPort.sendPort, appPath, cachePath, sqfliteFfiEnabled, useSqflite3]);
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final memory = await getMemoryInfo();
      final freeMem = memory.freeMem;
      const size = 1.5 * 1024;
      if (freeMem != null && freeMem < size) {
        CacheBinding.instance!.imageRefCache!.length = 250;
      }
    }
    await onDone(rcPort);

    /// 完成时再设置
    isolate = newIsolate;
  }

  @override
  Future<void> get initState {
    return EventQueue.runTaskOnQueue(runtimeType, onInit);
  }

  final ValueNotifier<bool> _init = ValueNotifier(false);

  @override
  ValueListenable<bool> get init {
    assert(_init.value == (_isolate != null));
    return _init;
  }

  @mustCallSuper
  Future<void> onClose() async {
    isolate = null;
  }

  @override
  Future<void> close() {
    return EventQueue.runOneTaskOnQueue(runtimeType, onClose);
  }
}
