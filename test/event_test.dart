import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/database.dart';

import 'repository_impl.dart';

void main() async {
  final repository = RepositoryImplTest();
  repository.initState;
  final watcher = repository.server.bookEventIsolate.db.watcher;
  watcher.sync = true;
  final bookEvent = repository.bookEvent;
  test('event', () async {
    final bookid = 10111;

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

    var c1 = bookEvent.watchBookCacheCid(bookid).listen((event) {
      print('watchBookCacheCid: ${event.hashCode}| $event');
    });
    var c2 = bookEvent.watchBookCacheCid(bookid).listen((event) {
      print('watchBookCacheCid_2: ${event.hashCode}| $event');
    });

    var m1 = bookEvent.watchMainBookListDb().listen((event) {
      print('watchMainBookListDb: $event');
    });
    print('first send');
    // await wait;
    x = await bookEvent.updateBook(
        bookid, BookCache(chapterId: 999, page: 101));
    expect(x, 1);

    x = await bookEvent.updateBook(
        bookid, BookCache(chapterId: 999, page: 101));
    expect(x, 1);

    x = await bookEvent.updateBook(bookid, BookCache(chapterId: 777, page: 11));
    expect(x, 1);
    c2.pause();
    c1.pause();
    x = await bookEvent.updateBook(bookid, BookCache(chapterId: 101, page: 11));
    expect(x, 1);
    c2.resume();
    await wait;

    expect(watcher.listeners.length, 2);
    await c2.cancel();

    expect(watcher.listeners.length, 2);
    await c1.cancel();

    /// `watchBookCacheCid` 已取消监听
    expect(watcher.listeners.length, 1);

    final m2 = bookEvent.watchMainBookListDb().listen((event) {
      print('watchMainBookListDb22131: $event');
    });

    expect(watcher.listeners.length, 1);

    await m1.cancel();
    expect(watcher.listeners.length, 1);

    final m3 = bookEvent.watchMainBookListDb().listen((event) {
      print('watchMainBookListDdadadb: $event');
    });

    /// 已经存在 `watchMainBookListDb` 监听
    expect(watcher.listeners.length, 1);
    await m2.cancel();

    expect(watcher.listeners.length, 1);
    await m3.cancel();

    /// `watchMainBookListDb` 已取消监听
    expect(watcher.listeners.isEmpty, true);
  });
  test('event content', () async {
    await bookEvent.getContent(326671, 1873701, false);
    await bookEvent.getContent(326671, 1873701, false);
  });

  test('sub cancel', () async {
    final sub = Stream.empty().listen((event) {
      print('...');
    });
    await sub.cancel();
    await wait;
    print(sub.isPaused);
  });
}

Future<void> get wait => Future.delayed(const Duration(milliseconds: 600));
