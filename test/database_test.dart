// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/nop_database.dart';

import '_database_impl.dart';

void dashed() => print('---------------');

void main() async {
  final db = Database();
  db.watcher.sync = true;

  final table = db.bookCache;

  var listenCount = 0;
  var listenCount2 = 0;

  test('query_watch', () async {
    dashed();

    var query = table.query.bookId;
    expect(query.updateItems.length, 1);
    expect(query.updateItems.first, '${table.table}.${table.bookId}');

    print(query);

    query.watchToTable.listen((event) {
      listenCount2++;
      print(
          'query_listen_02 listenCount2: $listenCount2: $event ,${db.watcher.listeners.length}');
    });
    await Future.delayed(Duration.zero);
    final query2 = table.query.all;
    query2.watchToTable.listen((event) {
      listenCount++;
      print(
          'qu3ry_listen_01 listenCount: $listenCount: $event ${db.watcher.listeners.length}');
    });
    await awi;

    query2.watchToTable.listen((event) {
      print('qu3ry_listen_01_1 listenCount: ${db.watcher.listeners.length}');
    });
  });

  var test_insert = false;

  void _test_insert() async {
    dashed();

    test_insert = true;
    final _insertItem = BookCache(
        bookId: 100,
        name: '测试 test',
        isNew: false,
        isShow: false,
        isTop: false,
        chapterId: 111,
        img: '一',
        lastChapter: '第一章',
        sortKey: DateTime.now().millisecondsSinceEpoch,
        page: 10,
        updateTime: DateTime.now().toString());

    final insert = table.insert..insertTable(_insertItem);

    print(insert);
    var i = insert.go;
    expect(i, 1);
  }

  test('insert', _test_insert);

  test('update', () async {
    if (!test_insert) _test_insert();
    dashed();

    // isNew 0, page: 10
    final update = table.update
      ..isNew.page
      ..withArgs([1, 1]);
    // current: bookid 100, chapterId 111, lastChapter '第一章'
    update.where
      ..bookId.lessThan(101).or
      ..chapterId.greateThanOrEqualTo(11).and
      ..lastChapter.like('第%');

    // start---------
    var q = update.go;
    expect(q, 1, reason: update.toString());
    await awi;

    //true:           y,  y                     y, or n, and  n
    update.coverWith([0, 2]).where.coverWith([10000, 151, '第']);

    q = update.go;
    await awi;

    // change
    expect(q, 1, reason: update.toString());

    //false:          n, y,                   n,   n,   n
    update.coverWith([0, 3]).where.coverWith([99, 151, '第']);

    q = update.go;
    await awi;

    expect(q, 0, reason: update.toString());

    //false:          y, y,                   n or  y and   n
    update.coverWith([1, 4]).where.coverWith([99, 110, '第']);

    q = update.go;
    await awi;
    expect(q, 0, reason: update.toString());

    //ture:          n, n,                   y or  y and   n
    update.coverWith([0, 2]).where.coverWith([101, 110, '第']);

    q = update.go;
    await awi;
    // update but no send
    expect(q, 1, reason: update.toString());

    final _insertItem2 = BookCache(
        bookId: 10001,
        name: '第二 测试 test',
        isNew: true,
        isShow: false,
        isTop: true,
        chapterId: 9999,
        img: '二',
        lastChapter: '第二章',
        sortKey: DateTime.now().millisecondsSinceEpoch,
        page: 88,
        updateTime: DateTime.now().toString());
    table.insert.insertTable(_insertItem2).go;
  });

  test('query_go', () {
    if (!test_insert) _test_insert();
    dashed();

    var query = table.query.bookId;
    print(query);
    var x = query.goToTable;
    print(x);

    query = table.query.all;
    print(query);
    var xx = query.go;
    print(xx);
  });

  test('delete', () async {
    dashed();
    final only = !test_insert;
    if (!test_insert) _test_insert();

    final delete = table.delete..where.bookId.lessThan(52000);
    final d = delete.go;
    expect(d, only ? 1 : 2, reason: delete.toString());

    print(delete);
  });
}

Future<void> get awi => Future.delayed(Duration.zero);
