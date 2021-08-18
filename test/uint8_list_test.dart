// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('Uin8List', () {
    final _ul = Uint8List.fromList([1, 2, 3, 5]);
    final list = [..._ul, ..._ul, ..._ul];
    final com = Uint8List.fromList(list);
    final u2 = Uint8List.fromList(list);
    print(u2 == com);
    print(com);
  });
}
