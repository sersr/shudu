import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('closure', () async {
    _test(() async {
      testPrint;

      /// ??
      return testPrint();
    });
  });
}

void _test(Future<void> Function() test) {
  test();
}

Future<void> testPrint() async {
  print('hello');
}
