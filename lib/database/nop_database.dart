import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/database/gen_database.dart';
import 'package:nop_db/database/table.dart';
import 'package:nop_db/nop_db.dart';

import '../data/data.dart';

part 'nop_database.g.dart';

class BookCache extends Table {
  BookCache({
    this.id,
    this.chapterId,
    this.img,
    this.lastChapter,
    this.name,
    this.updateTime,
    this.bookId,
    this.sortKey,
    this.page,
    this.isTop,
    this.isNew,
    this.isShow,
  });

  @NopItem(primaryKey: true)
  final int? id;
  final String? name;
  final String? img;
  final String? updateTime;
  final String? lastChapter;
  final int? chapterId;
  final int? bookId;
  final int? page;
  final int? sortKey;
  final bool? isTop;
  final bool? isNew;
  final bool? isShow;
  @override
  List get allItems => _allItems;
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

  BookContentDb.fromBookContent(BookContent content)
      : id = null,
        bookId = content.id,
        cid = content.cid,
        cname = content.cname,
        nid = content.nid,
        pid = content.pid,
        content = content.content,
        hasContent = Table.intToBool(content.hasContent);

  @NopItem(primaryKey: true)
  final int? id;
  final int? bookId;
  final int? cid;
  final String? cname;
  final int? nid;
  final int? pid;
  final String? content;
  final bool? hasContent;

  @override
  List get allItems => _allItems;
}

class BookIndex extends Table {
  BookIndex({this.id, this.bookId, this.bIndexs});
  @NopItem(primaryKey: true)
  final int? id;
  final int? bookId;
  final String? bIndexs;
  @override
  List get allItems => _allItems;
}

@Nop(tables: [BookCache, BookContentDb, BookIndex])
class BookDatabase extends _GenBookDatabase {
  BookDatabase(this.url, this.version);

  @override
  final String url;
  @override
  int version;
}
