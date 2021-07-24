import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/utils/utils.dart';

void main() async {
  test('closure', () async {
    _test(() async {
      testPrint;

      /// ??
      return testPrint();
    });
  });

  test('file lock', () async {
    final f = File('filelock.lock');
    flock(f, '1');
    flock(f, '2');
    await release(const Duration(seconds: 5));
  });

  test('futurOr', () async {
    await call(null);
  });
}

FutureOr<String> call(FutureOr<String?> str) {
  print('...');
  return 'hell';
}

void flock(File f, String label) async {
  final o = await f.open(mode: FileMode.write);
  print('wirte start $label.');
  await o.lock();
  await release(const Duration(seconds: 4));
  print('write end $label.');
  await o.unlock();
}

void _test(Future<void> Function() test) {
  test();
}

Future<void> testPrint() async {
  print('hello');
}
