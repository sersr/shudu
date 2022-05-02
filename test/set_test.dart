// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:nop/event_queue.dart';

void main() {
  test('set string', () {
    final s = <String>{};
    s.add('hello');
    s.add('hello');
    expect(s.length, 1);
    expect(identical('hello', 'hello'), true);
  });

  test('future', () async {
    final rf = _fu();
    rf.then((_) => print('rf: ...'));
    print(rf.hashCode);
    await idleWait;
  });

  test('impl', () {
    final impl = Impl();
    impl.mixinPrint();
  });

  test('dynamic type', () {
    bool t<T>() {
      return T == dynamic;
    }

    expect(t(), true);
    expect(t<int>(), false);
    expect(t<String>(), false);
  });
}

abstract class Base {
  void dprint();
}

/// 虽然[DefMixin]在最后，但在[Def]有[defPrint]的实现
/// 不过缺点是IDE不好识别，
class Impl with Def, DefMixin {}
// class Impl with Base, DefMixin, Def {}

/// `implements`: [Base]作为抽象接口，本身包含基类
mixin Def implements Base {
  @override
  void dprint() {
    print('hello');
  }

  /// 实现
  void defPrint() {
    print('defPrint');
  }
}

/// `on`: 在使用mixin时，在此之前基类要有[Base]
mixin DefMixin on Base {
  // void defPrint() {
  //   print('defmixin');
  // }
  // 抽象方法不会覆盖
  // `with` 中的顺序并不会影响，非抽象方法会被最后一个实现覆盖
  void defPrint();

  void mixinPrint() {
    defPrint();
  }
}

Future<void> _fu() async {
  final f = Future(() {
    print('hello');
  });
  await f;
  print('_fu: ${f.hashCode}');
  return f;
}
