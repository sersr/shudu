// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nop_database.dart';

// **************************************************************************
// Generator: GenNopGeneratorForAnnotation
// **************************************************************************

// ignore_for_file: curly_braces_in_flow_control_structures
abstract class _GenBookDatabase extends $Database {
  late final _tables = <DatabaseTable>[
    bookCache,
    bookContentDb,
    bookIndex,
    zhangduCache,
    zhangduContent,
    zhangduIndex
  ];

  @override
  List<DatabaseTable> get tables => _tables;

  late final bookCache = GenBookCache(this);
  late final bookContentDb = GenBookContentDb(this);
  late final bookIndex = GenBookIndex(this);
  late final zhangduCache = GenZhangduCache(this);
  late final zhangduContent = GenZhangduContent(this);
  late final zhangduIndex = GenZhangduIndex(this);
}

Map<String, dynamic> _BookCache_toJson(BookCache table) {
  return {
    'id': table.id,
    'name': table.name,
    'img': table.img,
    'updateTime': table.updateTime,
    'lastChapter': table.lastChapter,
    'chapterId': table.chapterId,
    'bookId': table.bookId,
    'page': table.page,
    'sortKey': table.sortKey,
    'isTop': table.isTop,
    'isNew': table.isNew,
    'isShow': table.isShow
  };
}

class GenBookCache extends DatabaseTable<BookCache, GenBookCache> {
  GenBookCache($Database db) : super(db);

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

  void updateBookCache(
      UpdateStatement<BookCache, GenBookCache> update, BookCache bookCache) {
    if (bookCache.id != null) update.id.set(bookCache.id);

    if (bookCache.name != null) update.name.set(bookCache.name);

    if (bookCache.img != null) update.img.set(bookCache.img);

    if (bookCache.updateTime != null)
      update.updateTime.set(bookCache.updateTime);

    if (bookCache.lastChapter != null)
      update.lastChapter.set(bookCache.lastChapter);

    if (bookCache.chapterId != null) update.chapterId.set(bookCache.chapterId);

    if (bookCache.bookId != null) update.bookId.set(bookCache.bookId);

    if (bookCache.page != null) update.page.set(bookCache.page);

    if (bookCache.sortKey != null) update.sortKey.set(bookCache.sortKey);

    if (bookCache.isTop != null) update.isTop.set(bookCache.isTop);

    if (bookCache.isNew != null) update.isNew.set(bookCache.isNew);

    if (bookCache.isShow != null) update.isShow.set(bookCache.isShow);
  }

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $name TEXT, $img '
        'TEXT, $updateTime TEXT, $lastChapter TEXT, $chapterId INTEGER, $bookId '
        'INTEGER, $page INTEGER, $sortKey INTEGER, $isTop INTEGER, $isNew '
        'INTEGER, $isShow INTEGER)';
  }

  static BookCache mapToTable(Map<String, dynamic> map) => BookCache(
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
  List<BookCache> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => mapToTable(e)).toList();
}

extension ItemExtensionBookCache<T extends ItemExtension<GenBookCache>> on T {
  T get id => item(table.id) as T;

  T get name => item(table.name) as T;

  T get img => item(table.img) as T;

  T get updateTime => item(table.updateTime) as T;

  T get lastChapter => item(table.lastChapter) as T;

  T get chapterId => item(table.chapterId) as T;

  T get bookId => item(table.bookId) as T;

  T get page => item(table.page) as T;

  T get sortKey => item(table.sortKey) as T;

  T get isTop => item(table.isTop) as T;

  T get isNew => item(table.isNew) as T;

  T get isShow => item(table.isShow) as T;

  T get genBookCache_id => id;

  T get genBookCache_name => name;

  T get genBookCache_img => img;

  T get genBookCache_updateTime => updateTime;

  T get genBookCache_lastChapter => lastChapter;

  T get genBookCache_chapterId => chapterId;

  T get genBookCache_bookId => bookId;

  T get genBookCache_page => page;

  T get genBookCache_sortKey => sortKey;

  T get genBookCache_isTop => isTop;

  T get genBookCache_isNew => isNew;

  T get genBookCache_isShow => isShow;
}

extension JoinItemBookCache<J extends JoinItem<GenBookCache>> on J {
  J get genBookCache_id => joinItem(joinTable.id) as J;

  J get genBookCache_name => joinItem(joinTable.name) as J;

  J get genBookCache_img => joinItem(joinTable.img) as J;

  J get genBookCache_updateTime => joinItem(joinTable.updateTime) as J;

  J get genBookCache_lastChapter => joinItem(joinTable.lastChapter) as J;

  J get genBookCache_chapterId => joinItem(joinTable.chapterId) as J;

  J get genBookCache_bookId => joinItem(joinTable.bookId) as J;

  J get genBookCache_page => joinItem(joinTable.page) as J;

  J get genBookCache_sortKey => joinItem(joinTable.sortKey) as J;

  J get genBookCache_isTop => joinItem(joinTable.isTop) as J;

  J get genBookCache_isNew => joinItem(joinTable.isNew) as J;

  J get genBookCache_isShow => joinItem(joinTable.isShow) as J;
}

Map<String, dynamic> _BookContentDb_toJson(BookContentDb table) {
  return {
    'id': table.id,
    'bookId': table.bookId,
    'cid': table.cid,
    'cname': table.cname,
    'nid': table.nid,
    'pid': table.pid,
    'content': table.content,
    'hasContent': table.hasContent
  };
}

class GenBookContentDb extends DatabaseTable<BookContentDb, GenBookContentDb> {
  GenBookContentDb($Database db) : super(db);

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

  void updateBookContentDb(
      UpdateStatement<BookContentDb, GenBookContentDb> update,
      BookContentDb bookContentDb) {
    if (bookContentDb.id != null) update.id.set(bookContentDb.id);

    if (bookContentDb.bookId != null) update.bookId.set(bookContentDb.bookId);

    if (bookContentDb.cid != null) update.cid.set(bookContentDb.cid);

    if (bookContentDb.cname != null) update.cname.set(bookContentDb.cname);

    if (bookContentDb.nid != null) update.nid.set(bookContentDb.nid);

    if (bookContentDb.pid != null) update.pid.set(bookContentDb.pid);

    if (bookContentDb.content != null)
      update.content.set(bookContentDb.content);

    if (bookContentDb.hasContent != null)
      update.hasContent.set(bookContentDb.hasContent);
  }

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, $cid '
        'INTEGER, $cname TEXT, $nid INTEGER, $pid INTEGER, $content TEXT, '
        '$hasContent INTEGER)';
  }

  static BookContentDb mapToTable(Map<String, dynamic> map) => BookContentDb(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      cid: map['cid'] as int?,
      cname: map['cname'] as String?,
      nid: map['nid'] as int?,
      pid: map['pid'] as int?,
      content: map['content'] as String?,
      hasContent: Table.intToBool(map['hasContent'] as int?));

  @override
  List<BookContentDb> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => mapToTable(e)).toList();
}

extension ItemExtensionBookContentDb<T extends ItemExtension<GenBookContentDb>>
    on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get cid => item(table.cid) as T;

  T get cname => item(table.cname) as T;

  T get nid => item(table.nid) as T;

  T get pid => item(table.pid) as T;

  T get content => item(table.content) as T;

  T get hasContent => item(table.hasContent) as T;

  T get genBookContentDb_id => id;

  T get genBookContentDb_bookId => bookId;

  T get genBookContentDb_cid => cid;

  T get genBookContentDb_cname => cname;

  T get genBookContentDb_nid => nid;

  T get genBookContentDb_pid => pid;

  T get genBookContentDb_content => content;

  T get genBookContentDb_hasContent => hasContent;
}

extension JoinItemBookContentDb<J extends JoinItem<GenBookContentDb>> on J {
  J get genBookContentDb_id => joinItem(joinTable.id) as J;

  J get genBookContentDb_bookId => joinItem(joinTable.bookId) as J;

  J get genBookContentDb_cid => joinItem(joinTable.cid) as J;

  J get genBookContentDb_cname => joinItem(joinTable.cname) as J;

  J get genBookContentDb_nid => joinItem(joinTable.nid) as J;

  J get genBookContentDb_pid => joinItem(joinTable.pid) as J;

  J get genBookContentDb_content => joinItem(joinTable.content) as J;

  J get genBookContentDb_hasContent => joinItem(joinTable.hasContent) as J;
}

Map<String, dynamic> _BookIndex_toJson(BookIndex table) {
  return {
    'id': table.id,
    'bookId': table.bookId,
    'bIndexs': table.bIndexs,
    'itemCounts': table.itemCounts,
    'cacheItemCounts': table.cacheItemCounts
  };
}

class GenBookIndex extends DatabaseTable<BookIndex, GenBookIndex> {
  GenBookIndex($Database db) : super(db);

  @override
  final table = 'BookIndex';
  final id = 'id';
  final bookId = 'bookId';
  final bIndexs = 'bIndexs';
  final itemCounts = 'itemCounts';
  final cacheItemCounts = 'cacheItemCounts';

  void updateBookIndex(
      UpdateStatement<BookIndex, GenBookIndex> update, BookIndex bookIndex) {
    if (bookIndex.id != null) update.id.set(bookIndex.id);

    if (bookIndex.bookId != null) update.bookId.set(bookIndex.bookId);

    if (bookIndex.bIndexs != null) update.bIndexs.set(bookIndex.bIndexs);

    if (bookIndex.itemCounts != null)
      update.itemCounts.set(bookIndex.itemCounts);

    if (bookIndex.cacheItemCounts != null)
      update.cacheItemCounts.set(bookIndex.cacheItemCounts);
  }

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, '
        '$bIndexs TEXT, $itemCounts INTEGER, $cacheItemCounts INTEGER)';
  }

  static BookIndex mapToTable(Map<String, dynamic> map) => BookIndex(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      bIndexs: map['bIndexs'] as String?,
      itemCounts: map['itemCounts'] as int?,
      cacheItemCounts: map['cacheItemCounts'] as int?);

  @override
  List<BookIndex> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => mapToTable(e)).toList();
}

extension ItemExtensionBookIndex<T extends ItemExtension<GenBookIndex>> on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get bIndexs => item(table.bIndexs) as T;

  T get itemCounts => item(table.itemCounts) as T;

  T get cacheItemCounts => item(table.cacheItemCounts) as T;

  T get genBookIndex_id => id;

  T get genBookIndex_bookId => bookId;

  T get genBookIndex_bIndexs => bIndexs;

  T get genBookIndex_itemCounts => itemCounts;

  T get genBookIndex_cacheItemCounts => cacheItemCounts;
}

extension JoinItemBookIndex<J extends JoinItem<GenBookIndex>> on J {
  J get genBookIndex_id => joinItem(joinTable.id) as J;

  J get genBookIndex_bookId => joinItem(joinTable.bookId) as J;

  J get genBookIndex_bIndexs => joinItem(joinTable.bIndexs) as J;

  J get genBookIndex_itemCounts => joinItem(joinTable.itemCounts) as J;

  J get genBookIndex_cacheItemCounts =>
      joinItem(joinTable.cacheItemCounts) as J;
}

Map<String, dynamic> _ZhangduCache_toJson(ZhangduCache table) {
  return {
    'id': table.id,
    'bookId': table.bookId,
    'name': table.name,
    'pinyin': table.pinyin,
    'picture': table.picture,
    'chapterId': table.chapterId,
    'chapterName': table.chapterName,
    'chapterUpdateTime': table.chapterUpdateTime,
    'page': table.page,
    'sortKey': table.sortKey,
    'isTop': table.isTop,
    'isNew': table.isNew,
    'isShow': table.isShow
  };
}

class GenZhangduCache extends DatabaseTable<ZhangduCache, GenZhangduCache> {
  GenZhangduCache($Database db) : super(db);

  @override
  final table = 'ZhangduCache';
  final id = 'id';
  final bookId = 'bookId';
  final name = 'name';
  final pinyin = 'pinyin';
  final picture = 'picture';
  final chapterId = 'chapterId';
  final chapterName = 'chapterName';
  final chapterUpdateTime = 'chapterUpdateTime';
  final page = 'page';
  final sortKey = 'sortKey';
  final isTop = 'isTop';
  final isNew = 'isNew';
  final isShow = 'isShow';

  void updateZhangduCache(UpdateStatement<ZhangduCache, GenZhangduCache> update,
      ZhangduCache zhangduCache) {
    if (zhangduCache.id != null) update.id.set(zhangduCache.id);

    if (zhangduCache.bookId != null) update.bookId.set(zhangduCache.bookId);

    if (zhangduCache.name != null) update.name.set(zhangduCache.name);

    if (zhangduCache.pinyin != null) update.pinyin.set(zhangduCache.pinyin);

    if (zhangduCache.picture != null) update.picture.set(zhangduCache.picture);

    if (zhangduCache.chapterId != null)
      update.chapterId.set(zhangduCache.chapterId);

    if (zhangduCache.chapterName != null)
      update.chapterName.set(zhangduCache.chapterName);

    if (zhangduCache.chapterUpdateTime != null)
      update.chapterUpdateTime.set(zhangduCache.chapterUpdateTime);

    if (zhangduCache.page != null) update.page.set(zhangduCache.page);

    if (zhangduCache.sortKey != null) update.sortKey.set(zhangduCache.sortKey);

    if (zhangduCache.isTop != null) update.isTop.set(zhangduCache.isTop);

    if (zhangduCache.isNew != null) update.isNew.set(zhangduCache.isNew);

    if (zhangduCache.isShow != null) update.isShow.set(zhangduCache.isShow);
  }

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, '
        '$name TEXT, $pinyin TEXT, $picture TEXT, $chapterId INTEGER, '
        '$chapterName TEXT, $chapterUpdateTime TEXT, $page INTEGER, $sortKey '
        'INTEGER, $isTop INTEGER, $isNew INTEGER, $isShow INTEGER)';
  }

  static ZhangduCache mapToTable(Map<String, dynamic> map) => ZhangduCache(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      name: map['name'] as String?,
      pinyin: map['pinyin'] as String?,
      picture: map['picture'] as String?,
      chapterId: map['chapterId'] as int?,
      chapterName: map['chapterName'] as String?,
      chapterUpdateTime: map['chapterUpdateTime'] as String?,
      page: map['page'] as int?,
      sortKey: map['sortKey'] as int?,
      isTop: Table.intToBool(map['isTop'] as int?),
      isNew: Table.intToBool(map['isNew'] as int?),
      isShow: Table.intToBool(map['isShow'] as int?));

  @override
  List<ZhangduCache> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => mapToTable(e)).toList();
}

extension ItemExtensionZhangduCache<T extends ItemExtension<GenZhangduCache>>
    on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get name => item(table.name) as T;

  T get pinyin => item(table.pinyin) as T;

  T get picture => item(table.picture) as T;

  T get chapterId => item(table.chapterId) as T;

  T get chapterName => item(table.chapterName) as T;

  T get chapterUpdateTime => item(table.chapterUpdateTime) as T;

  T get page => item(table.page) as T;

  T get sortKey => item(table.sortKey) as T;

  T get isTop => item(table.isTop) as T;

  T get isNew => item(table.isNew) as T;

  T get isShow => item(table.isShow) as T;

  T get genZhangduCache_id => id;

  T get genZhangduCache_bookId => bookId;

  T get genZhangduCache_name => name;

  T get genZhangduCache_pinyin => pinyin;

  T get genZhangduCache_picture => picture;

  T get genZhangduCache_chapterId => chapterId;

  T get genZhangduCache_chapterName => chapterName;

  T get genZhangduCache_chapterUpdateTime => chapterUpdateTime;

  T get genZhangduCache_page => page;

  T get genZhangduCache_sortKey => sortKey;

  T get genZhangduCache_isTop => isTop;

  T get genZhangduCache_isNew => isNew;

  T get genZhangduCache_isShow => isShow;
}

extension JoinItemZhangduCache<J extends JoinItem<GenZhangduCache>> on J {
  J get genZhangduCache_id => joinItem(joinTable.id) as J;

  J get genZhangduCache_bookId => joinItem(joinTable.bookId) as J;

  J get genZhangduCache_name => joinItem(joinTable.name) as J;

  J get genZhangduCache_pinyin => joinItem(joinTable.pinyin) as J;

  J get genZhangduCache_picture => joinItem(joinTable.picture) as J;

  J get genZhangduCache_chapterId => joinItem(joinTable.chapterId) as J;

  J get genZhangduCache_chapterName => joinItem(joinTable.chapterName) as J;

  J get genZhangduCache_chapterUpdateTime =>
      joinItem(joinTable.chapterUpdateTime) as J;

  J get genZhangduCache_page => joinItem(joinTable.page) as J;

  J get genZhangduCache_sortKey => joinItem(joinTable.sortKey) as J;

  J get genZhangduCache_isTop => joinItem(joinTable.isTop) as J;

  J get genZhangduCache_isNew => joinItem(joinTable.isNew) as J;

  J get genZhangduCache_isShow => joinItem(joinTable.isShow) as J;
}

Map<String, dynamic> _ZhangduContent_toJson(ZhangduContent table) {
  return {
    'id': table.id,
    'bookId': table.bookId,
    'contentId': table.contentId,
    'name': table.name,
    'sort': table.sort,
    'data': table.data
  };
}

class GenZhangduContent
    extends DatabaseTable<ZhangduContent, GenZhangduContent> {
  GenZhangduContent($Database db) : super(db);

  @override
  final table = 'ZhangduContent';
  final id = 'id';
  final bookId = 'bookId';
  final contentId = 'contentId';
  final name = 'name';
  final sort = 'sort';
  final data = 'data';

  void updateZhangduContent(
      UpdateStatement<ZhangduContent, GenZhangduContent> update,
      ZhangduContent zhangduContent) {
    if (zhangduContent.id != null) update.id.set(zhangduContent.id);

    if (zhangduContent.bookId != null) update.bookId.set(zhangduContent.bookId);

    if (zhangduContent.contentId != null)
      update.contentId.set(zhangduContent.contentId);

    if (zhangduContent.name != null) update.name.set(zhangduContent.name);

    if (zhangduContent.sort != null) update.sort.set(zhangduContent.sort);

    if (zhangduContent.data != null) update.data.set(zhangduContent.data);
  }

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, '
        '$contentId INTEGER, $name TEXT, $sort INTEGER, $data TEXT)';
  }

  static ZhangduContent mapToTable(Map<String, dynamic> map) => ZhangduContent(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      contentId: map['contentId'] as int?,
      name: map['name'] as String?,
      sort: map['sort'] as int?,
      data: map['data'] as String?);

  @override
  List<ZhangduContent> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => mapToTable(e)).toList();
}

extension ItemExtensionZhangduContent<
    T extends ItemExtension<GenZhangduContent>> on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get contentId => item(table.contentId) as T;

  T get name => item(table.name) as T;

  T get sort => item(table.sort) as T;

  T get data => item(table.data) as T;

  T get genZhangduContent_id => id;

  T get genZhangduContent_bookId => bookId;

  T get genZhangduContent_contentId => contentId;

  T get genZhangduContent_name => name;

  T get genZhangduContent_sort => sort;

  T get genZhangduContent_data => data;
}

extension JoinItemZhangduContent<J extends JoinItem<GenZhangduContent>> on J {
  J get genZhangduContent_id => joinItem(joinTable.id) as J;

  J get genZhangduContent_bookId => joinItem(joinTable.bookId) as J;

  J get genZhangduContent_contentId => joinItem(joinTable.contentId) as J;

  J get genZhangduContent_name => joinItem(joinTable.name) as J;

  J get genZhangduContent_sort => joinItem(joinTable.sort) as J;

  J get genZhangduContent_data => joinItem(joinTable.data) as J;
}

Map<String, dynamic> _ZhangduIndex_toJson(ZhangduIndex table) {
  return {
    'id': table.id,
    'bookId': table.bookId,
    'data': table.data,
    'itemCounts': table.itemCounts,
    'cacheItemCounts': table.cacheItemCounts
  };
}

class GenZhangduIndex extends DatabaseTable<ZhangduIndex, GenZhangduIndex> {
  GenZhangduIndex($Database db) : super(db);

  @override
  final table = 'ZhangduIndex';
  final id = 'id';
  final bookId = 'bookId';
  final data = 'data';
  final itemCounts = 'itemCounts';
  final cacheItemCounts = 'cacheItemCounts';

  void updateZhangduIndex(UpdateStatement<ZhangduIndex, GenZhangduIndex> update,
      ZhangduIndex zhangduIndex) {
    if (zhangduIndex.id != null) update.id.set(zhangduIndex.id);

    if (zhangduIndex.bookId != null) update.bookId.set(zhangduIndex.bookId);

    if (zhangduIndex.data != null) update.data.set(zhangduIndex.data);

    if (zhangduIndex.itemCounts != null)
      update.itemCounts.set(zhangduIndex.itemCounts);

    if (zhangduIndex.cacheItemCounts != null)
      update.cacheItemCounts.set(zhangduIndex.cacheItemCounts);
  }

  @override
  String createTable() {
    return 'CREATE TABLE $table ($id INTEGER PRIMARY KEY, $bookId INTEGER, '
        '$data TEXT, $itemCounts INTEGER, $cacheItemCounts INTEGER)';
  }

  static ZhangduIndex mapToTable(Map<String, dynamic> map) => ZhangduIndex(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      data: map['data'] as String?,
      itemCounts: map['itemCounts'] as int?,
      cacheItemCounts: map['cacheItemCounts'] as int?);

  @override
  List<ZhangduIndex> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => mapToTable(e)).toList();
}

extension ItemExtensionZhangduIndex<T extends ItemExtension<GenZhangduIndex>>
    on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get data => item(table.data) as T;

  T get itemCounts => item(table.itemCounts) as T;

  T get cacheItemCounts => item(table.cacheItemCounts) as T;

  T get genZhangduIndex_id => id;

  T get genZhangduIndex_bookId => bookId;

  T get genZhangduIndex_data => data;

  T get genZhangduIndex_itemCounts => itemCounts;

  T get genZhangduIndex_cacheItemCounts => cacheItemCounts;
}

extension JoinItemZhangduIndex<J extends JoinItem<GenZhangduIndex>> on J {
  J get genZhangduIndex_id => joinItem(joinTable.id) as J;

  J get genZhangduIndex_bookId => joinItem(joinTable.bookId) as J;

  J get genZhangduIndex_data => joinItem(joinTable.data) as J;

  J get genZhangduIndex_itemCounts => joinItem(joinTable.itemCounts) as J;

  J get genZhangduIndex_cacheItemCounts =>
      joinItem(joinTable.cacheItemCounts) as J;
}
