// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nop_database.dart';

// **************************************************************************
// Generator: GenNopGeneratorForAnnotation
// **************************************************************************

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

  late final bookCache = _GenBookCache(this);
  late final bookContentDb = _GenBookContentDb(this);
  late final bookIndex = _GenBookIndex(this);
  late final zhangduCache = _GenZhangduCache(this);
  late final zhangduContent = _GenZhangduContent(this);
  late final zhangduIndex = _GenZhangduIndex(this);
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

class _GenBookCache extends DatabaseTable<BookCache, _GenBookCache> {
  _GenBookCache($Database db) : super(db);

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
      UpdateStatement<BookCache, _GenBookCache> update, BookCache bookCache) {
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
  List<BookCache> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => _toTable(e)).toList();
}

extension ItemExtensionBookCache<T extends ItemExtension<_GenBookCache>> on T {
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

  T get bookCache_id => id;

  T get bookCache_name => name;

  T get bookCache_img => img;

  T get bookCache_updateTime => updateTime;

  T get bookCache_lastChapter => lastChapter;

  T get bookCache_chapterId => chapterId;

  T get bookCache_bookId => bookId;

  T get bookCache_page => page;

  T get bookCache_sortKey => sortKey;

  T get bookCache_isTop => isTop;

  T get bookCache_isNew => isNew;

  T get bookCache_isShow => isShow;
}

extension JoinItemBookCache<J extends JoinItem<_GenBookCache>> on J {
  J get bookCache_id => joinItem(joinTable.id) as J;

  J get bookCache_name => joinItem(joinTable.name) as J;

  J get bookCache_img => joinItem(joinTable.img) as J;

  J get bookCache_updateTime => joinItem(joinTable.updateTime) as J;

  J get bookCache_lastChapter => joinItem(joinTable.lastChapter) as J;

  J get bookCache_chapterId => joinItem(joinTable.chapterId) as J;

  J get bookCache_bookId => joinItem(joinTable.bookId) as J;

  J get bookCache_page => joinItem(joinTable.page) as J;

  J get bookCache_sortKey => joinItem(joinTable.sortKey) as J;

  J get bookCache_isTop => joinItem(joinTable.isTop) as J;

  J get bookCache_isNew => joinItem(joinTable.isNew) as J;

  J get bookCache_isShow => joinItem(joinTable.isShow) as J;
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

class _GenBookContentDb
    extends DatabaseTable<BookContentDb, _GenBookContentDb> {
  _GenBookContentDb($Database db) : super(db);

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
      UpdateStatement<BookContentDb, _GenBookContentDb> update,
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
  List<BookContentDb> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => _toTable(e)).toList();
}

extension ItemExtensionBookContentDb<T extends ItemExtension<_GenBookContentDb>>
    on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get cid => item(table.cid) as T;

  T get cname => item(table.cname) as T;

  T get nid => item(table.nid) as T;

  T get pid => item(table.pid) as T;

  T get content => item(table.content) as T;

  T get hasContent => item(table.hasContent) as T;

  T get bookContentDb_id => id;

  T get bookContentDb_bookId => bookId;

  T get bookContentDb_cid => cid;

  T get bookContentDb_cname => cname;

  T get bookContentDb_nid => nid;

  T get bookContentDb_pid => pid;

  T get bookContentDb_content => content;

  T get bookContentDb_hasContent => hasContent;
}

extension JoinItemBookContentDb<J extends JoinItem<_GenBookContentDb>> on J {
  J get bookContentDb_id => joinItem(joinTable.id) as J;

  J get bookContentDb_bookId => joinItem(joinTable.bookId) as J;

  J get bookContentDb_cid => joinItem(joinTable.cid) as J;

  J get bookContentDb_cname => joinItem(joinTable.cname) as J;

  J get bookContentDb_nid => joinItem(joinTable.nid) as J;

  J get bookContentDb_pid => joinItem(joinTable.pid) as J;

  J get bookContentDb_content => joinItem(joinTable.content) as J;

  J get bookContentDb_hasContent => joinItem(joinTable.hasContent) as J;
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

class _GenBookIndex extends DatabaseTable<BookIndex, _GenBookIndex> {
  _GenBookIndex($Database db) : super(db);

  @override
  final table = 'BookIndex';
  final id = 'id';
  final bookId = 'bookId';
  final bIndexs = 'bIndexs';
  final itemCounts = 'itemCounts';
  final cacheItemCounts = 'cacheItemCounts';

  void updateBookIndex(
      UpdateStatement<BookIndex, _GenBookIndex> update, BookIndex bookIndex) {
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

  BookIndex _toTable(Map<String, dynamic> map) => BookIndex(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      bIndexs: map['bIndexs'] as String?,
      itemCounts: map['itemCounts'] as int?,
      cacheItemCounts: map['cacheItemCounts'] as int?);

  @override
  List<BookIndex> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => _toTable(e)).toList();
}

extension ItemExtensionBookIndex<T extends ItemExtension<_GenBookIndex>> on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get bIndexs => item(table.bIndexs) as T;

  T get itemCounts => item(table.itemCounts) as T;

  T get cacheItemCounts => item(table.cacheItemCounts) as T;

  T get bookIndex_id => id;

  T get bookIndex_bookId => bookId;

  T get bookIndex_bIndexs => bIndexs;

  T get bookIndex_itemCounts => itemCounts;

  T get bookIndex_cacheItemCounts => cacheItemCounts;
}

extension JoinItemBookIndex<J extends JoinItem<_GenBookIndex>> on J {
  J get bookIndex_id => joinItem(joinTable.id) as J;

  J get bookIndex_bookId => joinItem(joinTable.bookId) as J;

  J get bookIndex_bIndexs => joinItem(joinTable.bIndexs) as J;

  J get bookIndex_itemCounts => joinItem(joinTable.itemCounts) as J;

  J get bookIndex_cacheItemCounts => joinItem(joinTable.cacheItemCounts) as J;
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

class _GenZhangduCache extends DatabaseTable<ZhangduCache, _GenZhangduCache> {
  _GenZhangduCache($Database db) : super(db);

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

  void updateZhangduCache(
      UpdateStatement<ZhangduCache, _GenZhangduCache> update,
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

  ZhangduCache _toTable(Map<String, dynamic> map) => ZhangduCache(
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
      query.map((e) => _toTable(e)).toList();
}

extension ItemExtensionZhangduCache<T extends ItemExtension<_GenZhangduCache>>
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

  T get zhangduCache_id => id;

  T get zhangduCache_bookId => bookId;

  T get zhangduCache_name => name;

  T get zhangduCache_pinyin => pinyin;

  T get zhangduCache_picture => picture;

  T get zhangduCache_chapterId => chapterId;

  T get zhangduCache_chapterName => chapterName;

  T get zhangduCache_chapterUpdateTime => chapterUpdateTime;

  T get zhangduCache_page => page;

  T get zhangduCache_sortKey => sortKey;

  T get zhangduCache_isTop => isTop;

  T get zhangduCache_isNew => isNew;

  T get zhangduCache_isShow => isShow;
}

extension JoinItemZhangduCache<J extends JoinItem<_GenZhangduCache>> on J {
  J get zhangduCache_id => joinItem(joinTable.id) as J;

  J get zhangduCache_bookId => joinItem(joinTable.bookId) as J;

  J get zhangduCache_name => joinItem(joinTable.name) as J;

  J get zhangduCache_pinyin => joinItem(joinTable.pinyin) as J;

  J get zhangduCache_picture => joinItem(joinTable.picture) as J;

  J get zhangduCache_chapterId => joinItem(joinTable.chapterId) as J;

  J get zhangduCache_chapterName => joinItem(joinTable.chapterName) as J;

  J get zhangduCache_chapterUpdateTime =>
      joinItem(joinTable.chapterUpdateTime) as J;

  J get zhangduCache_page => joinItem(joinTable.page) as J;

  J get zhangduCache_sortKey => joinItem(joinTable.sortKey) as J;

  J get zhangduCache_isTop => joinItem(joinTable.isTop) as J;

  J get zhangduCache_isNew => joinItem(joinTable.isNew) as J;

  J get zhangduCache_isShow => joinItem(joinTable.isShow) as J;
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

class _GenZhangduContent
    extends DatabaseTable<ZhangduContent, _GenZhangduContent> {
  _GenZhangduContent($Database db) : super(db);

  @override
  final table = 'ZhangduContent';
  final id = 'id';
  final bookId = 'bookId';
  final contentId = 'contentId';
  final name = 'name';
  final sort = 'sort';
  final data = 'data';

  void updateZhangduContent(
      UpdateStatement<ZhangduContent, _GenZhangduContent> update,
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

  ZhangduContent _toTable(Map<String, dynamic> map) => ZhangduContent(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      contentId: map['contentId'] as int?,
      name: map['name'] as String?,
      sort: map['sort'] as int?,
      data: map['data'] as String?);

  @override
  List<ZhangduContent> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => _toTable(e)).toList();
}

extension ItemExtensionZhangduContent<
    T extends ItemExtension<_GenZhangduContent>> on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get contentId => item(table.contentId) as T;

  T get name => item(table.name) as T;

  T get sort => item(table.sort) as T;

  T get data => item(table.data) as T;

  T get zhangduContent_id => id;

  T get zhangduContent_bookId => bookId;

  T get zhangduContent_contentId => contentId;

  T get zhangduContent_name => name;

  T get zhangduContent_sort => sort;

  T get zhangduContent_data => data;
}

extension JoinItemZhangduContent<J extends JoinItem<_GenZhangduContent>> on J {
  J get zhangduContent_id => joinItem(joinTable.id) as J;

  J get zhangduContent_bookId => joinItem(joinTable.bookId) as J;

  J get zhangduContent_contentId => joinItem(joinTable.contentId) as J;

  J get zhangduContent_name => joinItem(joinTable.name) as J;

  J get zhangduContent_sort => joinItem(joinTable.sort) as J;

  J get zhangduContent_data => joinItem(joinTable.data) as J;
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

class _GenZhangduIndex extends DatabaseTable<ZhangduIndex, _GenZhangduIndex> {
  _GenZhangduIndex($Database db) : super(db);

  @override
  final table = 'ZhangduIndex';
  final id = 'id';
  final bookId = 'bookId';
  final data = 'data';
  final itemCounts = 'itemCounts';
  final cacheItemCounts = 'cacheItemCounts';

  void updateZhangduIndex(
      UpdateStatement<ZhangduIndex, _GenZhangduIndex> update,
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

  ZhangduIndex _toTable(Map<String, dynamic> map) => ZhangduIndex(
      id: map['id'] as int?,
      bookId: map['bookId'] as int?,
      data: map['data'] as String?,
      itemCounts: map['itemCounts'] as int?,
      cacheItemCounts: map['cacheItemCounts'] as int?);

  @override
  List<ZhangduIndex> toTable(Iterable<Map<String, Object?>> query) =>
      query.map((e) => _toTable(e)).toList();
}

extension ItemExtensionZhangduIndex<T extends ItemExtension<_GenZhangduIndex>>
    on T {
  T get id => item(table.id) as T;

  T get bookId => item(table.bookId) as T;

  T get data => item(table.data) as T;

  T get itemCounts => item(table.itemCounts) as T;

  T get cacheItemCounts => item(table.cacheItemCounts) as T;

  T get zhangduIndex_id => id;

  T get zhangduIndex_bookId => bookId;

  T get zhangduIndex_data => data;

  T get zhangduIndex_itemCounts => itemCounts;

  T get zhangduIndex_cacheItemCounts => cacheItemCounts;
}

extension JoinItemZhangduIndex<J extends JoinItem<_GenZhangduIndex>> on J {
  J get zhangduIndex_id => joinItem(joinTable.id) as J;

  J get zhangduIndex_bookId => joinItem(joinTable.bookId) as J;

  J get zhangduIndex_data => joinItem(joinTable.data) as J;

  J get zhangduIndex_itemCounts => joinItem(joinTable.itemCounts) as J;

  J get zhangduIndex_cacheItemCounts =>
      joinItem(joinTable.cacheItemCounts) as J;
}
