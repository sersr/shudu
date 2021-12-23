// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/database.dart';
import 'package:shudu/database/nop_database.dart';
import 'package:shudu/provider/provider.dart';
import 'package:utils/utils.dart';

void main() async {
  test('regexp', () {
    final _e = RegExp(r'(?:(\n|<br/>)[\u3000 ]*)*(?:\n|<br/>)');
    final _e2 = RegExp('[(<br/>\n]');
    final _e3 = RegExp('(?:<br/>)');
    final _ei = RegExp('https?://');
    const s = '<br/> <br/>   ';
    const s2 = '(< sfw > b / sff<>\n';
    const s3 = 'http:// hello ,,, https:// nihao ';

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
    _c
      ..add('hello')
      ..add('world');
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
  test('table function', () {
    final b = BookContentDb(
        cid: 11,
        pid: 1,
        nid: 2,
        bookId: 11111,
        cname: 'cname',
        content: 'hello',
        hasContent: false);
    print(b.toJson());
    expect(b.hasNull, true, reason: 'id == null');
    expect(b.notNullIgnores(['id']), true, reason: 'id == null');
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

  test('closure', () {
    void Function()? save;
    void hlell() {
      void inner() {}

      if (save != null) {
        print(save == inner);
      }
      save = inner;
    }

    hlell();
    hlell();
  });

  test('unicode', () {
    final s = '\u4e00'.codeUnits.first;
    final e = '\u9FA5'.codeUnits.first;
    final i = List.generate(e - s, (index) => s + index);
    print(String.fromCharCodes(i));
  });

  test('BookContentDb', () {
    final _db = BookContentDb();
    _db.bookId = 111;
    print(_db);
  });

  test('eventLooper', () async {
    ///
    final loop = EventQueue();
    for (var i = 0; i < 10; i++) {
      loop.addEventTask(() => print('.....$i'));
    }
    await loop.runner;

    for (var i = 0; i < 10; i++) {
      loop.addOneEventTask(() async {
        await releaseUI;
        print('2:.....$i');
      });
    }
    await loop.runner;
    void _print() {
      print('....');
    }

    final list = [];
    for (var i = 0; i < 10; i++) {
      list.add(loop.awaitOne(_print));
    }
    for (final i in list) {
      print(i.hashCode);
    }
    await loop.runner;
  });
  test('dart event looper', () async {
    print('0');
    Timer.run(() => print('1'));
    print(2);
  });

  test('content boundary', () {
    expect(ContentBoundary.hasLeft(ContentBoundary.empty), false);
    expect(ContentBoundary.hasRight(ContentBoundary.empty), false);
  });

  test('await null', () async {
    Future<void> wait() async {
      print('wait');
      await null;
      print('wait end');
    }

    print('start');
    scheduleMicrotask(() {
      print('schedule');
    });
    Timer.run(() {
      print('timer.');
    });
    wait();
    print('end');
  });
}
