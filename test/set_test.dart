import 'package:flutter_test/flutter_test.dart';
import 'package:useful_tools/useful_tools.dart';

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
    await releaseUI;
  });
}

Future<void> _fu() async {
  final f = Future(() {
    print('hello');
  });
  await f;
  print('_fu: ${f.hashCode}');
  return f;
}
