// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/database.dart';

import '_database_impl.dart';

void main() async {
  final db = Database();
  await db.db.initDb();
  db.watcher.sync = true;
  final table = db.bookCache;
  test('bookContent test', () async {
    db.watchMainBookListDb().listen((event) {
      print('1: ${event.length}');
    });

    final xa = table.query
      ..watchToTable.listen((event) {
        print('2: ${event.length}');
      });
    print(xa);
    await db.insertBook(BookCache(
        bookId: 101,
        chapterId: 1010,
        img: 'img,',
        page: 1,
        name: 'helo 你好',
        lastChapter: 'last',
        isNew: true,
        isTop: false,
        isShow: true,
        updateTime: 'updatetime',
        sortKey: 1111));
   await db.insertBook(BookCache(
        bookId: 1021,
        chapterId: 1010,
        img: 'img,',
        page: 1,
        name: 'helo 你好',
        lastChapter: 'last',
        isNew: true,
        isTop: false,
        isShow: true,
        updateTime: 'updatetime',
        sortKey: 1111));

    final x = await db.insertBook(BookCache(
        bookId: 1021,
        chapterId: 1010,
        img: 'img,',
        page: 1,
        name: 'helo 你好',
        lastChapter: 'last',
        isNew: true,
        isTop: false,
        isShow: true,
        updateTime: 'updatetime',
        sortKey: 1111));
    expect(x, 0);

    table.insert
        .insertTable(BookCache(
            bookId: 10101,
            chapterId: 011,
            img: ',,',
            isNew: false,
            page: 1,
            name: 'helo 你好',
            lastChapter: 'last',
            isTop: false,
            isShow: true,
            updateTime: 'updatetime',
            sortKey: 1111))
        .go;
    table.insert
        .insertTable(BookCache(
            bookId: 10101,
            chapterId: 011,
            img: ',,',
            isNew: false,
            page: 1,
            name: 'helo 你好',
            lastChapter: 'last',
            isTop: false,
            isShow: true,
            updateTime: 'updatetime',
            sortKey: 1111))
        .go;
    print((await table.query.goToTable).length);
  });
}
