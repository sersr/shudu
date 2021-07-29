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

    final _e = _EBase();
    _e.a = 'ebase';
    print(_e);
  });
}

abstract class Base {
  Base._({this.a});
  factory Base({String? a}) = _EBase;

  final String? a;

  // String? get b;
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
  @override
  final String? b;

  @override
  Map<String, dynamic> toJson() {
    return {'a': a, 'b': b};
  }
}
