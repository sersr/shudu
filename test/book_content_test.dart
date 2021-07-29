// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/database/database.dart';

import '_database_impl.dart';

void main() {
  final db = Database();

  test('query_watch', () async {
    final query = db.watchCacheContentsCidDb(12);
    query.listen((event) {
      print('event: $event');
    });

    final _itable = BookContentDb(
        bookId: 12,
        cid: 1,
        cname: 'hello',
        nid: 1,
        pid: 0,
        content: 'content',
        hasContent: true);

    db.insertOrUpdateContent(BookContentDb(bookId: 12, cid: 1010));
    db.insertOrUpdateContent(_itable);
    // final insert = table.insert.insertTable(_itable);
    // insert.go;
    // print(query.go);
    await Future.delayed(Duration(milliseconds: 1000));
  });
}
