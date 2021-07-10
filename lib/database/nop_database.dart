import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/database/gen_database.dart';
import 'package:nop_db/database/table.dart';
import 'package:nop_db/nop_db.dart';

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
  BookIndex({this.id, this.bookId, this.bIndexs});

  @NopItem(primaryKey: true)
  int? id;
  int? bookId;
  String? bIndexs;

  @override
  Map<String, dynamic> toJson() => _BookIndex_toJson(this);
}

@Nop(tables: [BookCache, BookContentDb, BookIndex])
class BookDatabase extends _GenBookDatabase {
  BookDatabase(this.path, this.version);

  @override
  final String path;
  @override
  int version;
}
