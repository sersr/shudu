import 'dart:async';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/database.dart';
import 'package:shudu/database/nop_database.dart';

void main() async {
  test('future', () {
    final f = Completer();
    f.future._resultResolve('sss').then(print);
    // f.future.catchError((_) => null).then(print);
    // f.completeError('error');
    f.complete(null);
    ca()._resultResolve('aaa').then(print);
  });

  test('regexp', () {
    final _e = RegExp(r'(?:(\n|<br/>)[\u3000 ]*)*(?:\n|<br/>)');
    final _e2 = RegExp('[(<br/>\n]');
    final _e3 = RegExp('(?:<br/>)');
    final _ei = RegExp('https?://');
    final s = '<br/> <br/>   ';
    final s2 = '(< sfw > b / sff<>\n';
    final s3 = 'http:// hello ,,, https:// nihao ';

    final r3 = s3.replaceAll(_ei, 'ccc');
    expect(r3, 'ccc hello ,,, ccc nihao ', reason: r3);

    final r2 = s2.replaceAll(_e2, 'ss');
    expect(r2, 'ssss sfw ss ss ss sffssssss', reason: r2);

    final r21 = s2.replaceAll(_e3, 'ss');
    expect(r21, '(< sfw > b / sff<>\n', reason: r21);

    final r = s.replaceAll(_e, 'hello');
    expect(r, 'hello   ', reason: r);
    final r_1 = s.replaceAllMapped(_e, (match) {
      expect(match.groupCount, 1);
      print(match.groupCount);
      final buffer = StringBuffer();
      for (var i = 1; i <= match.groupCount; i++) {
        buffer.write(match[i]);
        print(match[i]! + 'a');
      }
      return buffer.toString();
    });
    print(r_1 + '...');
  });

  test('stream', () {
    final _c = StreamController.broadcast(sync: true);
    final _l1 = _c.stream.listen((event) {
      print('object: $event');
    });
    final _l2 = _c.stream.listen((event) {
      print('object2: $event');
    });
    _c.onCancel = () {
      print('cancel');
    };
    _c..add('hello')..add('world');
    _l1.cancel();
    _c..add('111');
    _l2.cancel();
  });

  test('streamController', () {
    final controller = StreamController.broadcast(sync: true);
    controller.onListen = () {
      print('....listen');
    };
    controller.onCancel = () => print('...oncancel');
    final l1 = controller.stream.listen((event) {
      print('event: $event');
    });
    controller.add('elllee');
    final l2 = controller.stream.listen((e) => print('event2: $e'));
    controller.add('add...');
    l1.cancel();
    l2.cancel();
  });
  test('enum', () {
    print(Enum.first.index);
    final b = BookContentDb(id: 1010, cid: 11);
    print(b.allItems);
  });

  test('try catch', () {
    dynamic count;
    try {
      throw '';
    } catch (e) {
      count = 1001;
      return;
    } finally {
      print(count.runtimeType);
    }
  });

  test('stream pause', () async {
    final c = StreamController(sync: true);
    final ca = StreamController.broadcast(sync: true);
    c.addStream(ca.stream);
    c.onPause = () {
      print('...');
    };
    c.onResume = () {
      print('onresume..');
    };

    c.onCancel = () {
      print('onCancel');
    };
    final sub = c.stream.listen((event) {
      print('lisntn event.');
    });
    ca.add('hello');
    sub.pause();
    sub.resume();
    await ca.close();
    // await c.close();
  });
  test('isolate', () async {
    final rec = ReceivePort();
    print(rec.sendPort.hashCode);
    Isolate.spawn(_is, rec.sendPort);
    print((await rec.first).hashCode);
  });
}

void _is(args) {
  print('hellol');
  print(args.hashCode);
  final sp = args as SendPort;
  final my = Capability();
  print(my.hashCode);
  sp.send(my);
}

class May {}

enum Enum { first }

Future? ca() {
  return null;
}

extension _ResultResolve<T> on Future<T>? {
  Future<T> _resultResolve(T error) async {
    final x =
        await this?.catchError((_) => error).then((value) => value ?? error);
    return x ?? error;
  }
}
