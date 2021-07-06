// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nop_database.dart';

// **************************************************************************
// Generator: GenNopGeneratorForAnnotation
// **************************************************************************

abstract class _GenBookDatabase extends $Database {
  late final _tables = <DatabaseTable>[
    bookCacheTable,
    bookContentDbTable,
    bookIndexTable
  ];

  @override
  List<DatabaseTable> get tables => _tables;

  late final bookCacheTable = _GenBookCacheTable(this);
  late final bookContentDbTable = _GenBookContentDbTable(this);
  late final bookIndexTable = _GenBookIndexTable(this);
}

extension BookCacheExt on BookCache {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'img': img,
      'updateTime': updateTime,
      'lastChapter': lastChapter,
      'chapterId': chapterId,
      'bookId': bookId,
      'page': page,
      'sortKey': sortKey,
      'isTop': isTop,
      'isNew': isNew,
      'isShow': isShow
    };
  }

  List get _allItems => List.of([
        id,
        name,
        img,
        updateTime,
        lastChapter,
        chapterId,
        bookId,
        page,
        sortKey,
        isTop,
        isNew,
        isShow
      ], growable: false);
}

class _GenBookCacheTable extends DatabaseTable<BookCache> {
  _GenBookCacheTable($Database db) : super(db);

  @override
  final table = 'BookCache';
  final id = 'id';
  final name = 'name';
  final img = 'img';
  final updateTime = 'updateTime';
  final lastChapter = 'lastChapter';
  final chapterId = 'chapterId';
  final bookId = 'bookId';
  final page = 'page';
  final sortKey = 'sortKey';
  final isTop = 'isTop';
  final isNew = 'isNew';
  final isShow = 'isShow';

  @override
  QueryStatement<BookCache, _GenBookCacheTable> get query =>
      QueryStatement<BookCache, _GenBookCacheTable>(this, db);

  @override
  UpdateStatement<BookCache, _GenBookCacheTable> get update =>
      UpdateStatement<BookCache, _GenBookCacheTable>(this, db);

  @override
  InsertStatement<BookCache, _GenBookCacheTable> get insert =>
      InsertStatement<BookCache, _GenBookCacheTable>(this, db);

  @override
  DeleteStatement<BookCache, _GenBookCacheTable> get delete =>
      DeleteStatement<BookCache, _GenBookCacheTable>(this, db);

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $name TEXT, $img '
        'TEXT, $updateTime TEXT, $lastChapter TEXT, $chapterId INTEGER, $bookId '
        'INTEGER, $page INTEGER, $sortKey INTEGER, $isTop INTEGER, $isNew '
        'INTEGER, $isShow INTEGER)';
  }

  BookCache _toTable(Map<String, dynamic> map) => BookCache(
      id: map['id'] as int?,
      name: map['name'] as String?,
      img: map['img'] as String?,
      updateTime: map['updateTime'] as String?,
      lastChapter: map['lastChapter'] as String?,
      chapterId: map['chapterId'] as int?,
      bookId: map['bookId'] as int?,
      page: map['page'] as int?,
      sortKey: map['sortKey'] as int?,
      isTop: Table.intToBool(map['isTop'] as int?),
      isNew: Table.intToBool(map['isNew'] as int?),
      isShow: Table.intToBool(map['isShow'] as int?));

  @override
  List<BookCache> toTable(List<Row> query) =>
      query.map((e) => _toTable(e)).toList();
  @override
  Map<String, dynamic> toJson(BookCache table) => table.toJson();
}

extension ItemExtensionBookCache<
    T extends ItemExtension<BookCache, _GenBookCacheTable, T>> on T {
  T get id => item(table.id);

  T get name => item(table.name);

  T get img => item(table.img);

  T get updateTime => item(table.updateTime);

  T get lastChapter => item(table.lastChapter);

  T get chapterId => item(table.chapterId);

  T get bookId => item(table.bookId);

  T get page => item(table.page);

  T get sortKey => item(table.sortKey);

  T get isTop => item(table.isTop);

  T get isNew => item(table.isNew);

  T get isShow => item(table.isShow);
}

extension BookContentDbExt on BookContentDb {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'cid': cid,
      'cname': cname,
      'nid': nid,
      'pid': pid,
      'content': content,
      'hasContent': hasContent
    };
  }

  List get _allItems =>
      List.of([id, bookId, cid, cname, nid, pid, content, hasContent],
          growable: false);
}

class _GenBookContentDbTable extends DatabaseTable<BookContentDb> {
  _GenBookContentDbTable($Database db) : super(db);

  @override
  final table = 'BookContentDb';
  final id = 'id';
  final bookId = 'bookId';
  final cid = 'cid';
  final cname = 'cname';
  final nid = 'nid';
  final pid = 'pid';
  final content = 'content';
  final hasContent = 'hasContent';

  @override
  QueryStatement<BookContentDb, _GenBookContentDbTable> get query =>
      QueryStatement<BookContentDb, _GenBookContentDbTable>(this, db);

  @override
  UpdateStatement<BookContentDb, _GenBookContentDbTable> get update =>
      UpdateStatement<BookContentDb, _GenBookContentDbTable>(this, db);

  @override
  InsertStatement<BookContentDb, _GenBookContentDbTable> get insert =>
      InsertStatement<BookContentDb, _GenBookContentDbTable>(this, db);

  @override
  DeleteStatement<BookContentDb, _GenBookContentDbTable> get delete =>
      DeleteStatement<BookContentDb, _GenBookContentDbTable>(this, db);

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, $cid '
        'INTEGER, $cname TEXT, $nid INTEGER, $pid INTEGER, $content TEXT, '
        '$hasContent INTEGER)';
  }

  BookContentDb _toTable(Map<String, dynamic> map) => BookContentDb(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      cid: map['cid'] as int?,
      cname: map['cname'] as String?,
      nid: map['nid'] as int?,
      pid: map['pid'] as int?,
      content: map['content'] as String?,
      hasContent: Table.intToBool(map['hasContent'] as int?));

  @override
  List<BookContentDb> toTable(List<Row> query) =>
      query.map((e) => _toTable(e)).toList();
  @override
  Map<String, dynamic> toJson(BookContentDb table) => table.toJson();
}

extension ItemExtensionBookContentDb<
    T extends ItemExtension<BookContentDb, _GenBookContentDbTable, T>> on T {
  T get id => item(table.id);

  T get bookId => item(table.bookId);

  T get cid => item(table.cid);

  T get cname => item(table.cname);

  T get nid => item(table.nid);

  T get pid => item(table.pid);

  T get content => item(table.content);

  T get hasContent => item(table.hasContent);
}

extension BookIndexExt on BookIndex {
  Map<String, dynamic> toJson() {
    return {'id': id, 'bookId': bookId, 'bIndexs': bIndexs};
  }

  List get _allItems => List.of([id, bookId, bIndexs], growable: false);
}

class _GenBookIndexTable extends DatabaseTable<BookIndex> {
  _GenBookIndexTable($Database db) : super(db);

  @override
  final table = 'BookIndex';
  final id = 'id';
  final bookId = 'bookId';
  final bIndexs = 'bIndexs';

  @override
  QueryStatement<BookIndex, _GenBookIndexTable> get query =>
      QueryStatement<BookIndex, _GenBookIndexTable>(this, db);

  @override
  UpdateStatement<BookIndex, _GenBookIndexTable> get update =>
      UpdateStatement<BookIndex, _GenBookIndexTable>(this, db);

  @override
  InsertStatement<BookIndex, _GenBookIndexTable> get insert =>
      InsertStatement<BookIndex, _GenBookIndexTable>(this, db);

  @override
  DeleteStatement<BookIndex, _GenBookIndexTable> get delete =>
      DeleteStatement<BookIndex, _GenBookIndexTable>(this, db);

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, '
        '$bIndexs TEXT)';
  }

  BookIndex _toTable(Map<String, dynamic> map) => BookIndex(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      bIndexs: map['bIndexs'] as String?);

  @override
  List<BookIndex> toTable(List<Row> query) =>
      query.map((e) => _toTable(e)).toList();
  @override
  Map<String, dynamic> toJson(BookIndex table) => table.toJson();
}

extension ItemExtensionBookIndex<
    T extends ItemExtension<BookIndex, _GenBookIndexTable, T>> on T {
  T get id => item(table.id);

  T get bookId => item(table.bookId);

  T get bIndexs => item(table.bIndexs);
}
