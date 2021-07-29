// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('controller sync', () async {
    final controller = StreamController.broadcast(sync: true);

    final c2 = StreamController(sync: true);
    late StreamController c3;
    void _l() {
      print('.s.s${c3.hasListener}');
      c3.add('hello world');
      c3.addStream(controller.stream);
    }

    c3 = StreamController(sync: true, onListen: _l);

    c2.stream.listen((event) {
      print(' event22: $event');
    });
    c2.add('hello world');
    c2.addStream(controller.stream);

    controller.add('lalaaf');

    final s = c3.stream.listen((event) {
      print(' event33: $event');
    });

    controller.add('nihao');
    controller.add('12');
    controller.add('ww');
    controller.add('aa');
    s.cancel();
  });

  test('cancel on listen', () async {
    late StreamController c;
    c = StreamController.broadcast(
        sync: true,
        onListen: () {
          // c.close();
          // if (!c.isClosed) c.add('aaaxx');
          print('aaa');
        },
        onCancel: () => print('oncancel.'));

    final l = c.stream.listen((event) {
      print('s.s');
    }, onDone: () => print('done'));
    l.pause();

    print(c.hasListener);
  });

  test('stream', () async {
    late StreamController c;
    final a = StreamController.broadcast(onListen: () {
      print('onListen.');
    });
    c = StreamController(onListen: () {
      print('on...c');
      c.addStream(a.stream).then((_) {
        print('......');
        c.close();
      });
    });
    a.stream.listen((event) {
      print('a....listen');
    });
    a.add('add');
    await a.close();
    c.stream.listen((event) {
      print('...');
    });

    await c.close();
  });
}
