import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';

import './book_repository_base.dart';

class BookRepositoryPort extends BookRepositoryBase with SendEventPortMixin {
  SendPort? _clientSP;

  Future<void>? _f;

  @override
  Future<void> get initState async {
    _f ??= _initState()..whenComplete(() => _f = null);
    return _f;
  }

  Future<void> _initState() async {
    if (closeTask != null) await closeTask;

    final rcPort = await initBase();

    if (rcPort != null) {
      _clientSP = await rcPort.first;
      rcPort.close();
    }
  }

  @override
  void send(message) {
    assert(_clientSP != null);
    _clientSP?.send(message);
  }

  @override
  Future<void> dispose() {
    super.dispose();
    return close().then((_) => _clientSP = null);
  }
}
