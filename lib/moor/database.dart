import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class BookInfos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('body')();
  IntColumn get bookId => integer()();
  IntColumn get chapterId => integer()();
  TextColumn get img => text()();
  TextColumn get updateTime => text()();
  TextColumn get lastChapter => text()();
  IntColumn get sortKey => integer()();
  IntColumn get page => integer()();
  BoolColumn get isTop => boolean()();
  BoolColumn get isNew => boolean()();
  BoolColumn get isShow => boolean()();
}

class BookContents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  TextColumn get cname => text()();
  IntColumn get cid => integer()();
  IntColumn get nid => integer()();
  IntColumn get pid => integer()();
  TextColumn get content => text()();
  BoolColumn get hasContent => boolean()();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [BookInfos, BookContents])
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Stream<BookContent> watchUserWithId(int id) {
  //   return (select(bookContents)..where((u) => u.id.equals(id))).watchSingle();
  // }
}
