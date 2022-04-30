// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:nop/utils.dart';
import 'package:shudu/database/database.dart';
import 'package:shudu/event/base/export.dart';

import 'repository_impl.dart';

void main() async {
  final repository = RepositoryImplTest();
  await repository.initRepository;
  final watcher = repository.server.bookEventIsolate.db.watcher;
  BookEvent bookEvent = repository;

  Future<void> _innerTest() async {
    const bookid = 10111;

    /// insertBook
    var x = await bookEvent.insertBook(BookCache(
        bookId: bookid,
        chapterId: 121,
        page: 1,
        name: 'helo 你好',
        lastChapter: 'last',
        isNew: true,
        isTop: false,
        isShow: true,
        img: 'img',
        updateTime: 'updatetime',
        sortKey: 1111));

    expect(x, 1);

    var c1 = bookEvent.watchCurrentCid(bookid).listen((event) {
      print('___c1___: ${event.hashCode}| $event');
    });
    var c2 = bookEvent.watchCurrentCid(bookid).listen((event) {
      print('___c2___: ${event.hashCode}| $event');
    });

    var m1 = bookEvent.watchMainList().listen((event) {
      print('___m1___: $event');
    });
    print('first send');

    x = await bookEvent.updateBook(
        bookid, BookCache(chapterId: 999, page: 101));
    expect(x, 1);

    x = await bookEvent.updateBook(
        bookid, BookCache(chapterId: 999, page: 101));
    expect(x, 1);

    x = await bookEvent.updateBook(bookid, BookCache(chapterId: 777, page: 11));
    expect(x, 1);
    // 异步的行为不可测
    // await wait;
    c2.pause();
    c1.pause();
    x = await bookEvent.updateBook(bookid, BookCache(chapterId: 101, page: 11));
    expect(x, 1);
    Log.i('resume...');
    c1.resume();
    c2.resume();
    await wait;

    expect(watcher.listeners.length, 2);
    await c2.cancel();

    expect(watcher.listeners.length, 2);
    await c1.cancel();

    await wait;

    /// `watchBookCacheCid` 已取消监听
    expect(watcher.listeners.length, 1);

    final m2 = bookEvent.watchMainList().listen((event) {
      print('___m2___: $event');
    });

    await wait;
    expect(watcher.listeners.length, 1);
    await wait;

    await m1.cancel();
    await wait;

    expect(watcher.listeners.length, 1);

    final m3 = bookEvent.watchMainList().listen((event) {
      print('___m3___: $event');
    });

    /// 已经存在 `watchMainBookListDb` 监听
    expect(watcher.listeners.length, 1);
    await m2.cancel();

    // 如果没有等待,`event_sync`测试中`m3`不会接收到数据
    // await wait;
    expect(watcher.listeners.length, 1);
    await m3.cancel();
    await wait;

    /// `watchMainBookListDb` 已取消监听
    expect(watcher.listeners.isEmpty, true);
  }

  test('event', _innerTest);
  test('event_sync; 分别测试每一个测试，否则会报错', () async {
    bookEvent = repository.server.bookEventIsolate;
    await _innerTest();
  });
  test('event content', () async {
    await bookEvent.getContent(326671, 1873701, false);
    await bookEvent.getContent(326671, 1873701, false);
  });
}

Future<void> get wait => Future.delayed(const Duration(milliseconds: 100));
