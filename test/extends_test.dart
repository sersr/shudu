// ignore_for_file: avoid_print, overridden_fields
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('final', () {
    final f = Base();
    // *final b*
    // b is final
    f.b = 'hhh';
    expect(f.a, null);
    print(f);
    expect(f is _EBase, true);
    final fe = f as _EBase;
    fe.b = '11';
    print(fe.b);
    final _e = _EBase(b: '..');
    _e.a = 'ebase';
    _e.b = 'ss';
    _e.b;
    print(_e);
  });
}

abstract class Base {
  Base._({this.a});
  factory Base({String? a}) = _EBase;

  final String? a;

  // String? _b;
  // String? get b => _b;
  // set b(String? v) {
  //  _b = v;
  // }
  String? b;

  Map<String, dynamic> toJson();
  @override
  String toString() {
    return '${toJson()}, base: $a, $b';
  }
}

class _EBase extends Base {
  _EBase({this.a, this.b}) : super._();
  @override
  String? a;

  // *final*
  // equal
  // String? _b;
  // String? get b => _b;
  // setter: use Base
  //
  // 初始化之后，无法再设置b
  // 即使setter有效，不过是使用Base.b.setter
  // 相当于
  // set b(String? v) {
  //  // none
  // }
  @override
  final String? b;

  @override
  Map<String, dynamic> toJson() {
    return {'a': a, 'b': b};
  }
}
