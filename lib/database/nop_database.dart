import 'dart:async';

import 'package:nop/nop.dart';
import 'package:nop_db_sqflite/nop_db_sqflite.dart';
// ignore: unused_import
import 'package:nop_db_sqlite/sqlite.dart' as nop;

import '../data/data.dart';

part 'nop_database.g.dart';

class BookCache extends Table {
  BookCache({
    this.id,
    this.name,
    this.img,
    this.updateTime,
    this.lastChapter,
    this.chapterId,
    this.bookId,
    this.page,
    this.sortKey,
    this.isTop,
    this.isNew,
    this.isShow,
  });

  @NopDbItem(primaryKey: true)
  int? id;
  String? name;
  String? img;
  String? updateTime;
  String? lastChapter;
  int? chapterId;
  int? bookId;
  int? page;
  int? sortKey;
  bool? isTop;
  bool? isNew;
  bool? isShow;

  @override
  Map<String, dynamic> toJson() => _BookCache_toJson(this);
}

int get sortKey => DateTime.now().microsecondsSinceEpoch;

class BookContentDb extends Table {
  BookContentDb({
    this.id,
    this.bookId,
    this.cid,
    this.cname,
    this.nid,
    this.pid,
    this.content,
    this.hasContent,
  });

  factory BookContentDb.fromBookContent(BookContent content) {
    return BookContentDb(
        id: null,
        bookId: content.id,
        cid: content.cid,
        cname: content.cname,
        nid: content.nid,
        pid: content.pid,
        content: content.content,
        hasContent: Table.intToBool(content.hasContent));
  }

  @NopDbItem(primaryKey: true)
  int? id;
  int? bookId;
  int? cid;
  String? cname;
  int? nid;
  int? pid;
  String? content;
  bool? hasContent;

  @override
  Map<String, dynamic> toJson() => _BookContentDb_toJson(this);
}

class BookIndex extends Table {
  BookIndex({
    this.id,
    this.bookId,
    this.bIndexs,
    this.itemCounts,
    this.cacheItemCounts,
  });

  @NopDbItem(primaryKey: true)
  int? id;
  int? bookId;
  String? bIndexs;
  int? itemCounts;
  int? cacheItemCounts;
  @override
  Map<String, dynamic> toJson() => _BookIndex_toJson(this);
}

@NopDb(tables: [
  BookCache,
  BookContentDb,
  BookIndex,
])
class BookDatabase extends _GenBookDatabase {
  BookDatabase(this.path);

  final String path;

  final int version = 3;
  final String index = 'book_content_index';

  FutureOr<void> initDb() {
    return _initDb().whenComplete(() {
      return db.rawQuery(
          'select count(*) from sqlite_master where type = ? and name = ?',
          ['index', index]).then((value) {
        if (value.first.values.first == 0) {
          return db.execute(
              'CREATE INDEX $index on ${bookContentDb.table}(${bookContentDb.cid})');
        }
      });
    });
  }

  FutureOr<void> _initDb() {
    return NopDatabaseSqflite.openSqfite(
      path,
      version: version,
      onCreate: onCreate,
      onDowngrade: onDowngrade,
      onUpgrade: onUpgrade,
    ).then(setDb);
    // return nop
    //     .open(path,
    //         version: version,
    //         onCreate: onCreate,
    //         onUpgrade: onUpgrade,
    //         onDowngrade: onDowngrade)
    //     .then(setDb);
  }

  @override
  FutureOr<void> onUpgrade(
      NopDatabase db, int oldVersion, int newVersion) async {
    if (oldVersion <= 1) {
      try {
        final indexTable = bookIndex.table;
        await db.execute(
            'ALTER TABLE $indexTable ADD COLUMN ${bookIndex.itemCounts} INTEGER');
        await db.execute(
            'ALTER TABLE $indexTable ADD COLUMN ${bookIndex.cacheItemCounts} INTEGER');
      } catch (e) {
        Log.i('error: $e', onlyDebug: false);
      }
    }
    // if (oldVersion <= 2) {
    //   await db.execute(zhangduCache.createTable());
    //   await db.execute(zhangduContent.createTable());
    //   await db.execute(zhangduIndex.createTable());
    // }
  }
}
