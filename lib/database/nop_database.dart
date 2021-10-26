import 'dart:async';

import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/database/nop.dart';
import 'package:nop_db/nop_db.dart';
import 'package:nop_db_sqflite/nop_db_sqflite.dart';
import 'package:nop_db_sqlite/nop_db_sqlite.dart';
import 'package:useful_tools/common.dart';

import '../data/data.dart';

part 'nop_database.g.dart';
part 'zhangdu_database.dart';

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

  @NopItem(primaryKey: true)
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

  @NopItem(primaryKey: true)
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

  @NopItem(primaryKey: true)
  int? id;
  int? bookId;
  String? bIndexs;
  int? itemCounts;
  int? cacheItemCounts;
  @override
  Map<String, dynamic> toJson() => _BookIndex_toJson(this);
}

@Nop(tables: [
  BookCache,
  BookContentDb,
  BookIndex,
  ZhangduCache,
  ZhangduContent,
  ZhangduIndex,
])
class BookDatabase extends _GenBookDatabase {
  BookDatabase(this.path, this.useFfi, this.useSqfite3);

  final bool useSqfite3;

  final bool useFfi;

  final String path;

  final int version = 3;

  FutureOr<void> initDb() {
    if (useSqfite3) {
      return _initSqflitedb().then(setDb);
    } else {
      setDb(_initffidb());
    }
  }

  NopDatabase _initffidb() {
    return NopDatabaseImpl.open(path,
        version: version,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade);
  }

  Future<NopDatabase> _initSqflitedb() {
    return NopDatabaseSqflite.openSqfite(path,
        useFfi: useFfi, // sqflite 桌面平台是FFI实现
        version: version,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade);
  }

  @override
  FutureOr<void> onUpgrade(
      NopDatabase db, int oldVersion, int newVersion) async {
        Log.i('version: $oldVersion  | $newVersion');
    if (oldVersion <= 1) {
      final indexTable = bookIndex.table;
      await db.execute(
          'ALTER TABLE $indexTable ADD COLUMN ${bookIndex.itemCounts} INTEGER');
      await db.execute(
          'ALTER TABLE $indexTable ADD COLUMN ${bookIndex.cacheItemCounts} INTEGER');
    }
    if (oldVersion <= 2) {
      await db.execute(zhangduCache.createTable());
      await db.execute(zhangduContent.createTable());
      await db.execute(zhangduIndex.createTable());
    }
  }
}
