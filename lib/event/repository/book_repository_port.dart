import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';

import './book_repository_base.dart';

class BookRepositoryPort extends BookRepositoryBase with SendEventPortMixin {
  SendPort? _clientSP;

  @override
  Future<void> get initState async {
    initBase();
    await runner;
  }

  @override
  Future<void> onDone(ReceivePort rcPort) async {
    _clientSP = await rcPort.first;
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

  @override
  Future<void> onClose() {
    // 关闭连接
    _clientSP == null;
    dispose();
    pendingMessages.clear();
    return super.onClose();
  }
}
