import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive/hive.dart';
import 'package:nop_db/nop_db.dart';
import 'package:path_provider/path_provider.dart';

import './book_repository_base.dart';
import '../../utils/utils.dart';
import '../base/book_event.dart';
import '../base/type_adapter.dart';
import '../event.dart';

class BookRepository extends BookRepositoryBase with SendEventMixin {
  final _initCallbacks = <Future<void> Function()>[];
  @override
  void addInitCallback(Future<void> Function() callback) {
    if (_initCallbacks.contains(callback)) return;
    _initCallbacks.add(callback);
  }

  @override
  late BookEvent bookEvent = BookEventMain(this);
  late ReceivePort clientRP;
  late SendPort clientSP;
  late Isolate _isolate;

  Future<void>? _f;

  @override
  Future<void> get initState async {
    _f ??= _initState()..whenComplete(() => _f = null);
    return _f;
  }

  Future<void> _initState() async {
    final _futures = <Future>{};
    _futures.add(orientation(true));

    if (Platform.isAndroid)
      _futures.add(FlutterDisplayMode.setHighRefreshRate());

    _futures.add(Future(() async {
      final _secF = <Future>{};

      final appPath = (await getApplicationDocumentsDirectory()).path;
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapter(AxisAdapter())
        ..registerAdapter(TargetPlatformAdapter())
        ..registerAdapter(PageBuilderAdapter());

      Hive.init('$appPath/shudu/hive');

      final _minitCallbacks = List.of(_initCallbacks);
      _initCallbacks.clear();
      _minitCallbacks.forEach((callback) => _secF.add(callback()));

      _secF.add(Future<void>(() async {
        clientRP = ReceivePort();
        _isolate =
            await Isolate.spawn(_isolateEvent, [clientRP.sendPort, appPath]);

        _clientF ??= Completer<void>();

        clientRP.listen(_listen);

        await _clientF?.future;
        _clientF = null;
      }));

      await Future.wait(_secF);
    }));

    _futures.add(getBatteryLevel);
    _futures.add(getViewInsets());

    await Future.wait(_futures);
  }

  Completer<void>? _clientF;

  void _listen(r) {
    if (add(r)) return;

    if (r is SendPort) {
      _clientF?.complete();
      _clientF = null;
      clientSP = r;
      return;
    }

    /// [SenderStreamController] 在本地取消时，隔离端可能未及时关闭
    /// 由于异步的各种原因，还可能通过此端口接受数据，但本地以关闭，无法确认接受
    /// 此端口是共享端口
    /// 
    /// [BookRepositoryPort]: 提供独立端口
    assert(Log.e('messager error : $r'));
  }

  @override
  void dispose() {
    clientRP.close();
    _isolate.kill(priority: Isolate.immediate);
    super.dispose();
  }

  @override
  void send(message) {
    clientSP.send(message);
  }
}

void _isolateEvent(List args) async {
  final port = args[0];
  final appPath = args[1];
  final receivePort = ReceivePort();

  final db = BookEventIsolate(appPath, port);
  await db.initState();

  receivePort.listen((m) {
    if (db.resolve(m)) return;
  });

  port.send(receivePort.sendPort);
}
