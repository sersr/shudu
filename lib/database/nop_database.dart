import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/database/gen_database.dart';
import 'package:nop_db/database/table.dart';
import 'package:nop_db/nop_db.dart';

import '../data/data.dart';

part 'nop_database.g.dart';

abstract class BookCache extends Table {
  BookCache._();
  factory BookCache({
    int? id,
    String? name,
    String? img,
    String? updateTime,
    String? lastChapter,
    int? chapterId,
    int? bookId,
    int? page,
    int? sortKey,
    bool? isTop,
    bool? isNew,
    bool? isShow,
  }) = _BookCache;

  @NopItem(primaryKey: true)
  int? get id;
  String? get name;
  String? get img;
  String? get updateTime;
  String? get lastChapter;
  int? get chapterId;
  int? get bookId;
  int? get page;
  int? get sortKey;
  bool? get isTop;
  bool? get isNew;
  bool? get isShow;
}

abstract class BookContentDb extends Table {
  BookContentDb._();
  factory BookContentDb({
    int? id,
    int? bookId,
    int? cid,
    String? cname,
    int? nid,
    int? pid,
    String? content,
    bool? hasContent,
  }) = _BookContentDb;

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
  int? get id;
  int? get bookId;
  int? get cid;
  String? get cname;
  int? get nid;
  int? get pid;
  String? get content;
  bool? get hasContent;
}

abstract class BookIndex extends Table {
  BookIndex._();

  factory BookIndex({int? id, int? bookId, String? bIndexs}) = _BookIndex;
  @NopItem(primaryKey: true)
  int? get id;
  int? get bookId;
  String? get bIndexs;
}

@Nop(tables: [BookCache, BookContentDb, BookIndex])
class BookDatabase extends _GenBookDatabase {
  BookDatabase(this.path, this.version);

  @override
  final String path;
  @override
  int version;
}
