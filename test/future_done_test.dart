import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('future SynchronousFuture', () async {
    print('start');
    syncFuture().then((value) => print(value));
    syncFutureNo().then((value) => print(value));
    print('end');
  });
}

Future syncFutureNo() {
  return SynchronousFuture('hello world NO');
}

Future syncFuture() async {
  return SynchronousFuture('hello world');
}
