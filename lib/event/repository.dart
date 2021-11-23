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
import 'mixin/entry_point.dart';

typedef BoolCallback = void Function(bool visible);

abstract class RepositoryBase extends BookEventMessagerMain
    with SendEventMixin, SendIsolateMixin, SendCacheMixin, SendInitCloseMixin {}

/// 主隔离: 处理数据库任务
class DatabaseRepository extends RepositoryBase {
  DatabaseRepository();
  List? args;
  @override
  SendEvent get sendEvent => this;

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) {
    Log.w(args);
    return Isolate.spawn(dataBaseEntryPoint, [remoteSendPort, ...?args]);
  }
}

/// 主隔离: 网络，数据库([DatabaseRepository]代理)
class Repository extends RepositoryBase with SystemInfos {
  Repository();

  final ValueNotifier<bool> _initStatus = ValueNotifier(false);

  ValueListenable<bool> get initStatus => _initStatus;

  @override
  void notifiyState(bool init) {
    _initStatus.value = init;
  }

  final DatabaseRepository databaseRepository = DatabaseRepository();
  @override
  SendEvent get bookCacheEventSendEvent => databaseRepository;
  @override
  SendEvent get bookContentEventSendEvent => databaseRepository;
  @override
  SendEvent get zhangduDatabaseEventSendEvent => databaseRepository;

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
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) {
    return initWork(remoteSendPort);
  }

  @override
  Future<Isolate> createIsolate(SendPort remoteSendPort, List args) async {
    databaseRepository.args = args;

    /// Isolate event
    ///  [remoteSendPort, appPath, cachePath,sqfliteFfiEnabled,useSqflite3]
    final newIsolate =
        Isolate.spawn(multiIsolateEvent, [remoteSendPort, ...args]);
    await databaseRepository.init();

    return newIsolate;
  }

  @override
  void onResume() {
    assert(sendPortOwner != null);
    sendPortOwner!.localSendPort.send(ResolveName(
        'database', databaseRepository.sendPortOwner!.localSendPort));
    super.onResume();
  }

  @override
  FutureOr<void> onCloseStart() async {
    await super.onCloseStart();
    return databaseRepository.close();
  }
}

/// 一个 隔离
/// 主隔离(native)
class SingleRepository extends RepositoryBase with SystemInfos {
  SingleRepository();

  final ValueNotifier<bool> _initStatus = ValueNotifier(false);

  ValueListenable<bool> get initStatus => _initStatus;

  @override
  void notifiyState(bool init) {
    _initStatus.value = init;
  }

  @override
  late final SendEvent sendEvent = this;
  late final BookEvent bookEvent = this;

  static SingleRepository? _instance;

  factory SingleRepository.create() {
    _instance ??= SingleRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(SingleRepository repository) {
    _instance ??= repository;
  }

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) {
    return initWork(remoteSendPort);
  }

  @override
  Future<Isolate> createIsolate(SendPort remoteSendPort, List args) async {
    /// Isolate event
    /// [remoteSendPort, appPath, cachePath, useSqflite3]
    return Isolate.spawn(singleIsolateEvent, [remoteSendPort, ...args]);
  }
}

/// [Repository]需要的信息
mixin SystemInfos {
  Future<Isolate> createIsolate(SendPort remoteSendPort, List args);
  Future<Isolate> initWork(SendPort remoteSendPort) async {
    SystemChrome.setSystemUIChangeCallback(_onSystemOverlaysChanges);
    if (defaultTargetPlatform == TargetPlatform.android) {
      Bangs.bangs.setNavigationChangeCallback(_navState);
    }
    final _waits = FutureAny();

    String? appDirExt;
    List<Directory>? cacheDirs;

    _waits
      ..add(setOrientation(true))
      ..add(getBatteryLevel);
    bool externalDir = true;
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
    bool useSqflite3 = false;
    _waits.add(getApplicationDocumentsDirectory().then((dir) => appDir = dir));
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        break;
      default:
        _waits.add(
            OptionsNotifier.sqfliteBox.then((value) => useSqflite3 = value));
    }

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

    Log.w('useSqflite3: $useSqflite3', onlyDebug: false);
    if (useSqflite3) {
      await SqfliteMainIsolate.initMainDb();
    }

    final newIsolate =
        await createIsolate(remoteSendPort, [appPath, cachePath, useSqflite3]);

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

  // 状态栏遮挡占用的高度
  double _statusHeight = 0;
  double get statusHeight => _statusHeight;

  // 底部导航栏高度
  int _height = 0;
  int get height => _height;
  void _navState(bool isShow, int height) {
    Log.i('navHeight: $height | $isShow');
    _height = height;
  }

  MemoryInfoPlugin? memoryInfoPlugin;

  Future<Memory> getMemoryInfo() {
    memoryInfoPlugin ??= MemoryInfoPlugin();
    return memoryInfoPlugin!.memoryInfo;
  }

  /// 系统UI
  bool _systemOverlaysAreVisible = false;
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
