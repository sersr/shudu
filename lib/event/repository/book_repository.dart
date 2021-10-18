import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/common.dart';

import './book_repository_base.dart';

@Deprecated('use BookRepositoryPort instead.')
class BookRepository extends BookRepositoryBase with SendEventMixin {
  ReceivePort? _clientRP;
  SendPort? _clientSP;

  @override
  Future<void> onDone(ReceivePort rcPort) async {
    _getClientSP ??= Completer<void>();

    rcPort.listen(_listen);

    await _getClientSP?.future;
    _getClientSP = null;
    _clientRP = rcPort;
    if (pendingMessages.isNotEmpty) {
      final _pendings = List.of(pendingMessages);
      pendingMessages.clear();
      _pendings.forEach(send);
    }
  }

  final pendingMessages = [];
  @override
  void send(message) {
    if (_clientSP == null) {
      pendingMessages.add(message);
      return;
    }
    _clientSP!.send(message);
  }

  Completer<void>? _getClientSP;

  void _listen(r) {
    if (add(r)) return;

    if (r is SendPort) {
      _getClientSP?.complete();
      _getClientSP = null;
      _clientSP = r;
      return;
    }

    // 所有的消息共用一个端口
    // `Stream`也是，
    assert(Log.e('messager error : $r'));
  }

  @override
  Future<void> onClose() async {
    _clientRP?.close();
    _clientRP = null;
    _clientSP = null;
    dispose();
    pendingMessages.clear();
    return super.onClose();
  }
}
