import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

import 'nop.dart';

mixin BookDatabase {
  // late NopDatabase _db;

  String get path => 'nop_book_database.nopdb';
  String get appPath;

  void initState() {
    final _db = NopDatabase.open(join(appPath, path), version: 1,
        onCreate: (db, version) {
      db.execute(
          'CREATE TABLE  if not exists BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId'
          ' INTEGER, chapterId INTEGER, img TEXT, updateTime TEXT, '
          'lastChapter TEXT, sortKey INTEGER, isTop INTEGER,'
          ' Page INTEGER, isNew INTEGER, isShow INTEGER)');

      db.execute(
          'CREATE TABLE  if not exists BookContent (id INTEGER PRIMARY KEY, bookId INTEGER,'
          ' cid INTEGER, cname TEXT, nid INTEGER, pid INTEGER, content'
          ' TEXT, hasContent INTEGER)');
      db.execute(
          'CREATE TABLE  if not exists BookIndex (id INTEGER PRIMARY KEY, bookId '
          'INTEGER,bIndexs TEXT)');
    });
    execute = _db.execute;

    query = _db.rawQuery;
    update = _db.rawUpdate;
    delete = _db.rawDelete;
    insert = _db.rawInsert;
  }

  late final Execute execute;
  late final List<Row> Function(String sql, [List<Object?> parameters]) query;
  late final ReturnQuery update;
  late final ReturnQuery delete;
  late final ReturnQuery insert;

}
