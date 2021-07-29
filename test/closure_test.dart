// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('closure', () async {
    _test(() async {
      testPrint;

      /// ??
      return testPrint();
    });
  });
 

  test('futurOr', () async {
    await call(null);
  });
}

FutureOr<String> call(FutureOr<String?> str) {
  print('...');
  return 'hell';
}
 
void _test(Future<void> Function() test) {
  test();
}

Future<void> testPrint() async {
  print('hello');
}
