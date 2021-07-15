import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';

import './book_repository_base.dart';
import '../../utils/utils.dart';

class BookRepository extends BookRepositoryBase with SendEventMixin {
  ReceivePort? _clientRP;
  SendPort? _clientSP;

  Future<void>? _f;

  @override
  Future<void> get initState async {
    _f ??= _initState()..whenComplete(() => _f = null);
    return _f;
  }

  Future<void> _initState() async {
    // if (init) return;
    if (closeTask != null) await closeTask;

    final rcPort = await initBase();

    if (rcPort != null) {
      _clientF ??= Completer<void>();

      rcPort.listen(_listen);

      await _clientF?.future;
      _clientF = null;
      _clientRP = rcPort;
    }
  }

  Completer<void>? _clientF;

  void _listen(r) {
    if (add(r)) return;

    if (r is SendPort) {
      _clientF?.complete();
      _clientF = null;
      _clientSP = r;
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
  Future<void> dispose() {
    super.dispose();
    return close().then((_) {
      _clientRP?.close();
      dispose();
    });
  }

  @override
  void send(message) {
    _clientSP?.send(message);
  }
}
