import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nop/nop.dart';

class Uint8ListType with TransferTypeMapData<Uint8List?> {
  Uint8ListType(this.list);
  Uint8ListType.wrap(this.list);
  Uint8List? list;
  @override
  FutureOr<Uint8List?> tranDecode() {
    final buffer = getData('list');
    if (buffer != null) {
      final data = buffer.materialize();
      return data.asUint8List();
    } else if (list != null) {
      return list;
    }
    return null;
  }

  @override
  FutureOr<void> tranEncode() {
    if (list != null) {
      final data = list!;
      if (!kIsWeb) {
        list = null;
        final typeData = TransferableTypedData.fromList([data]);
        push('list', typeData);
      }
    }
  }
}

class RawContentLines {
  RawContentLines(
      {this.source = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.hasContent});

  final List<String> source;

  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final bool? hasContent;

  bool get isEmpty =>
      source.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      hasContent == null;

  static RawContentLines none = RawContentLines();

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;

  @override
  String toString() {
    return '$runtimeType: $cid, $pid, $nid, $hasContent, $cname, $source';
  }
}
