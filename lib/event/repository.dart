import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:android_external_storage/android_external_storage.dart';
import 'package:bangs/bangs.dart';
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
import 'package:useful_tools/useful_tools.dart';

import '../provider/options_notifier.dart';
import 'base/book_event.dart';
import 'mixin/complex_mixin.dart';
import 'mixin/database_mixin.dart';
import 'mixin/event_messager_mixin.dart';
import 'mixin/network_mixin.dart';
import 'mixin/zhangdu_mixin.dart';

typedef BoolCallback = void Function(bool visible);

/// 主隔离(native)
class Repository extends BookEventMessagerMain
    with
        SystemInfos,
        ComplexMessager,
        SaveImageMessager,
        SendEventMixin,
        SendIsolateMixin {
  Repository();

  final ValueNotifier<bool> _initStatus = ValueNotifier(false);

  ValueListenable<bool> get initStatus => _initStatus;

  @override
  void notifiyState(bool init) {
    _initStatus.value = init;
  }

  @override
  late final SendEvent sendEvent = this;
  late final BookEvent bookEvent = this;

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= Repository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  @override
  Future<Isolate> onCreateIsolate(SendPort sdPort) async {
    SystemChrome.setSystemUIChangeCallback(_onSystemOverlaysChanges);
    if (defaultTargetPlatform == TargetPlatform.android) {
      Bangs.bangs.setNavigationChangeCallback(_statusState);
    }
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
    _waits.add(getApplicationDocumentsDirectory().then((dir) => appDir = dir));
    _waits.add(OptionsNotifier.sqfliteBox.then((value) => useSqflite3 = value));

    await _waits.wait;

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
        [sdPort, appPath, cachePath, sqfliteFfiEnabled, useSqflite3]);
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final memory = await getMemoryInfo();
      final freeMem = memory.freeMem;
      const size = 1.5 * 1024;
      if (freeMem != null && freeMem < size) {
        CacheBinding.instance!.imageRefCache!.length = 250;
      }
    }
    return newIsolate;
  }
}

/// TODO: 重新添加刘海屏等顶部遮挡高度信息获取
mixin SystemInfos {
  Battery? _battery;

  int level = 50;

  final extenalStorage = ValueNotifier(true);

  DeviceInfoPlugin? deviceInfo;

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

  double _statusHeight = 0;
  double get statusHeight => _statusHeight;

  int _height = 0;
  int get height => _height;
  void _statusState(bool isShow, int height) {
    Log.i('statusHeight: $height');
    _height = height;
  }

  MemoryInfoPlugin? memoryInfoPlugin;

  Future<Memory> getMemoryInfo() {
    memoryInfoPlugin ??= MemoryInfoPlugin();
    return memoryInfoPlugin!.memoryInfo;
  }

  bool _systemOverlaysAreVisible = false;
  bool get systemOverlaysAreVisible => _systemOverlaysAreVisible;

  Future<void> _onSystemOverlaysChanges(bool visible) async {
    _systemOverlaysAreVisible = visible;
    if (_changesListeners.isNotEmpty)
      for (var c in _changesListeners) {
        c(visible);
      }
  }

  /// 弃用
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

// 任务隔离(remote):处理 数据库、网络任务
class BookEventIsolate extends BookEventResolveMain
    with DatabaseMixin, NetworkMixin, ComplexMixin, ZhangduEventMixin {
  BookEventIsolate(this.sp, this.appPath, this.cachePath,
      this.sqfliteFfiEnabled, this.useSqflite3);

  @override
  final SendPort sp;
  @override
  final String appPath;
  @override
  final String cachePath;

  @override
  final bool useSqflite3;
  @override
  final bool sqfliteFfiEnabled;

  Future<void> initState() async {
    final d = netEventInit().logi(false);
    await initDb().logi(false);
    await d;
  }

  @override
  void onError(error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  FutureOr<bool> onClose() async {
    await closeDb();
    await closeNet();
    return true;
  }

  // @override
  // bool remove(key) {
  //   assert(key is! KeyController || Log.w(key));
  //   return super.remove(key);
  // }

  // @override
  // bool resolve(m) {
  //   return super.resolve(m);
  // }
}

/// remote Isolate 入口
void isolateEvent(List args) async {
  final port = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final sqfliteFfiEnabled = args[3];
  final useSqflite3 = args[4];
  final receivePort = ReceivePort();
  Log.i('$appPath | $cachePath | $sqfliteFfiEnabled | $useSqflite3',
      onlyDebug: false);

  final db = BookEventIsolate(
      port, appPath, cachePath, sqfliteFfiEnabled, useSqflite3);
  try {
    await db.initState();
  } catch (e) {
    Log.e('initState error: $e', onlyDebug: false);
  }

  receivePort.listen((m) {
    if (db.resolve(m)) return;
    Log.e('somthing was error: $m');
  });

  port.send(receivePort.sendPort);
}
