import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('test hashList', () {
    final a = [
      ['slsls', 'aaaafs'],
      ['sfsfs', 'aaa']
    ];
    final d = [
      ['slsls', 'aaaafs'],
      ['sfsfs', 'aaa']
    ];

    expect(hashList(a.expand((e) => e)), hashList(d.expand((e) => e)));
  });
}
