// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('future SynchronousFuture async', () async {
    var index = 0;
    print('start');
    syncFuture().then((value) {
      expect(index, 3); // 最后执行
      print(value);
    });
    index++;
    syncFutureNo().then((value) async {
      expect(index, 1); // 确定同步
      print(value);
      final newValue = await syncFutureNo();
      expect(index, 1); // 说明`then`和`await`一样，都是立即执行，`await`语法是根据`then`实现的
      print('await: $newValue');
    });
    index++;
    print('end');
    expect(index, 2);
    index++;
  });
}

/// 不在生成新的[Future]对象
Future syncFutureNo() {
  return SynchronousFuture('hello world NO');
}

/// `async`标记会生成一个新的[Future]对象
Future syncFuture() async {
  return SynchronousFuture('hello world');
}
