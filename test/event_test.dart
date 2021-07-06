import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/database.dart';

import 'repository_impl.dart';

void main() async {
  final repository = RepositoryImplTest();
  repository.initState;
  repository.server.bookEventIsolate.db.watcher.sync = true;
  final bookEvent = repository.bookEvent;
  test('event', () async {
    final bookid = 10111;

    /// insertBook
    var x = await bookEvent.insertBook(BookCache(
        bookId: bookid,
        chapterId: 121,
        page: 1,
        name: 'helo 你好',
        isNew: true,
        isTop: false,
        isShow: true));

    expect(x, 1);

    var q = bookEvent.watchBookCacheCid(bookid).listen((event) {
      print('watchBookCacheCid: ${event.hashCode}| $event');
    });
    var qa = bookEvent.watchBookCacheCid(bookid).listen((event) {
      print('watchBookCacheCid_2: ${event.hashCode}| $event');
    });

    var qal = bookEvent.watchMainBookListDb().listen((event) {
      print('watchMainBookListDb: $event');
    });
    print('first send');
    // await wait;
    x = await bookEvent.updateBookStatusCustom(bookid, 999, 101);
    expect(x, 1);

    x = await bookEvent.updateBookStatusCustom(bookid, 999, 101);
    expect(x, 1);

    x = await bookEvent.updateBookStatusCustom(bookid, 777, 11);
    expect(x, 1);
    qa.pause();
    q.pause();
    x = await bookEvent.updateBookStatusCustom(bookid, 101, 11);
    expect(x, 1);
    qa.resume();
    await wait;
    await qa.cancel();
    await q.cancel();
    final d1 = bookEvent.watchMainBookListDb().listen((event) {
      print('watchMainBookListDb22131: $event');
    });
    await qal.cancel();
    final d2 = bookEvent.watchMainBookListDb().listen((event) {
      print('watchMainBookListDdadadb: $event');
    });
    await d1.cancel();
    await d2.cancel();
  });
  test('event content', () async {
    await bookEvent.getContent(598958, 3530092, false);
    await bookEvent.getContent(598958, 3530092, false);
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
