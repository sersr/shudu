// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('class', () {
    final t = PrintImpl();
    final ta = re(t);
    t.println();
    ta.println();
  });
}

abstract class Base {
  void println() {
    print('hlello');
  }
}

Base re(PrintImpl i) {
  return i;
}

class PrintImpl extends Base {
  @override
  void println() {
    print('impl');
  }
}
