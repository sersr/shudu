import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nop_db/nop_db.dart';

void onRemove(Sender sender) {
  if (sender is SenderStreamController) {
    print('sender: $sender,, ${_list.containsKey(sender.mapKey)}');
    _list.remove(sender.mapKey);
  }
}

void send(key) {
  print(key);
}

final _list = <MessageStreamKey, SenderStreamController>{};

void main() async {
  test('sender_stream_controller', () async {
    final key1 = MessageStreamKey(['key']);
    final key2 = MessageStreamKey(['key']);
    expect(key2, key1);
    final s = SenderStreamController<String>(onRemove, send);
    _list[key1] = s;
    expect(_list.containsKey(key2), true);
    final l1 = s.stream.listen((event) {
      print('event01: $event');
    }, onDone: () {
      print('l1: done.');
    });

    final l2 = s.stream.listen((event) {
      print('event02: $event');
    }, onDone: () {
      print('l2: done.');
    });
    s.add('hello');

    // await Future.delayed(Duration(microseconds: 1));
    // s.add('world');

    // s.add('hello world');

    // s.add('l1.cancel');

    // s.add('l2.cancel');
    print(s.listenConsumers.length);
    s.cancel();
    // l1.cancel();
    // l2.cancel();

    // final l3 = s.stream.listen((event) {
    //   print('s.sf #3n');
    // }, onDone: () => print('l3: done.'));
    // l3.cancel();
    // 确保能够接受event
    // await Future.delayed(Duration(microseconds: 1));
    // if (_list.containsKey(key2)) {
    //   print('contains keys');
    //   final sender = _list[key2] as SenderStreamController<String>;
    //   final keya = sender.stream.listen((event) {
    //     print('key2: event :$event');
    //   });
    //   // sender.add('sender key2');
    //   // sender.cancel();
    //   keya.cancel();
    // } else {
    //   print('not.....');
    // }
    // final saa = SenderStreamController(onRemove, key2);
  });

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

    final s2 = c2.stream.listen((event) {
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
    // await c.close();
    // await l.cancel();
    // if (!c.isClosed) c.add('sflsfls');
    // print('ss');
    // if (c.hasListener) await c.close();
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
