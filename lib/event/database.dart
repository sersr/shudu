import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../utils/utils.dart';
import 'book_event.dart';

// 只实现数据库相关函数
mixin SqfliteDatabase on DatabaseEvent {
  late Database _db;
  String get dataPath;

  @override
  Future<void> initState() async {
    _db = await getDb();
  }

  Future<Database> getDb();

  Future<void> onCreate(Database db, int version) async {
    _db = db;

    await db.execute(
        'CREATE TABLE BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId'
        ' INTEGER, chapterId INTEGER, img TEXT, updateTime TEXT, '
        'lastChapter TEXT, sortKey INTEGER, isTop INTEGER,'
        ' cPage INTEGER, isNew INTEGER)');

    await db.execute(
        'CREATE TABLE BookContent (id INTEGER PRIMARY KEY, bookId INTEGER,'
        ' cid INTEGER, cname TEXT, nid INTEGER, pid INTEGER, content'
        ' TEXT, hasContent INTEGER)');

    await db.execute('CREATE TABLE BookIndex (id INTEGER PRIMARY KEY, bookId '
        'INTEGER,bIndexs TEXT)');
  }

  @override
  Future<void> updateBookStatusAndSetNew(
      int id, String cname, String updateTime) async {
    final _cname = await _db
        .rawQuery('SELECT lastChapter from BookInfo where bookId = ?', [id]);

    if (_cname.isNotEmpty) {
      if (_cname.first['lastChapter'] != cname) {
        await _db.rawUpdate(
            'update BookInfo set lastChapter = ?, isNew = ?, updateTime = ? where bookId = ?',
            [cname, 1, updateTime, id]);
      }
    }
  }

  @override
  Future<void> updateBookStatus(int id, int cid, int page) async {
    await _db.rawUpdate(
        'update BookInfo set chapterId = ?, cPage = ?, isNew = ?,sortKey = ? where bookId = ?',
        [cid, page, 0, DateTime.now().millisecondsSinceEpoch, id]);
  }

  @override
  Future<void> updateBookStatusAndSetTop(int id, int isTop) async {
    await _db.rawUpdate(
        'update BookInfo set isTop = ?,sortKey = ?  where bookId = ?',
        [isTop, DateTime.now().millisecondsSinceEpoch, id]);
  }

  @override
  Future<void> saveContent(BookContent bookContent) =>
      _insertOrUpdateContent(bookContent);

  Future<void> _insertOrUpdateContent(BookContent bookContent) async {
    final count = Sqflite.firstIntValue(await _db.rawQuery(
        'SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?',
        [bookContent.id, bookContent.cid]));

    if (count! > 0) {
      await _db.rawUpdate(
          'UPDATE BookContent SET pid = ?, nid = ?, hasContent = ?,content = ? WHERE bookId = ? AND cid = ?',
          [
            bookContent.pid,
            bookContent.nid,
            bookContent.hasContent,
            bookContent.content,
            bookContent.id,
            bookContent.cid
          ]);
    } else {
      await _db.rawInsert(
        'INSERT INTO BookContent (bookId, cid, cname, nid, pid, content, hasContent)'
        ' VALUES(?,?,?,?,?,?,?)',
        [
          bookContent.id,
          bookContent.cid,
          bookContent.cname,
          bookContent.nid,
          bookContent.pid,
          bookContent.content,
          bookContent.hasContent,
        ],
      );
    }
  }

  @override
  Future<List<Map<String, Object?>>> getContentDb(
      int bookid, int contentid) async {
    return _db.rawQuery(
        'SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [bookid, contentid]);
  }

  @override
  Future<Set<int>> getAllBookId() async {
    final key = 'bookId';
    final data = <int>{};
    final _l = await _db.rawQuery('SELECT $key FROM BookContent');
    if (_l.isNotEmpty) {
      for (final l in _l) {
        if (l.containsKey(key) && l[key] is int) {
          data.add(l[key] as int);
        }
      }
    }
    return data;
  }

  @override
  Future<void> deleteCache(int bookId) async {
    await _db.rawDelete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  @override
  Future<void> insertOrUpdateIndexs(int? id, String indexs) async {
    int? count = 0;

    count = Sqflite.firstIntValue(await _db
        .rawQuery('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]));
    if (count! > 0) {
      await _db.rawUpdate(
          'UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info,
          'count: $count,id: $id cache bIndexs.',
          stage: this, name: 'cacheinnerdb'));
    } else {
      await _db.rawInsert(
        'INSERT INTO BookIndex (bookId,bIndexs)'
        ' VALUES(?,?)',
        [id, indexs],
      );
    }
  }

  @override
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid) async {
    return _db
        .rawQuery('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
  }

  @override
  Future<void> insertBook(BookCache bookCache) async {
    int? count = 0;
    count = Sqflite.firstIntValue(await _db.rawQuery(
        'SELECT COUNT(*) FROM BookInfo where bookid = ?', [bookCache.id]));
    if (count == 0) {
      await _db.rawInsert(
        'INSERT INTO BookInfo(name, bookId, chapterId, img, updateTime, lastChapter, sortKey, isTop,cPage,isNew)'
        ' VALUES(?,?,?,?,?,?,?,?,?,?)',
        [
          bookCache.name,
          bookCache.id,
          bookCache.chapterId,
          bookCache.img,
          bookCache.updateTime,
          bookCache.lastChapter,
          bookCache.sortKey,
          bookCache.isTop,
          bookCache.page,
          bookCache.isNew,
        ],
      );
    }
  }

  @override
  Future<int> deleteBook(int id) async {
    return _db.rawDelete('DELETE FROM BookInfo WHERE bookId = ?', [id]);
  }

  @override
  Future<List<Map<String, Object?>>> getMainBookListDb() async {
    return _db.rawQuery('SELECT * FROM BookInfo');
  }

  /// [BookEvent] 章节文本加载 数据库实现
  // 只从数据库加载

  // /// 默认实现
  // @override
  // Future<RawContentLines?> getContentNet(
  //     int bookid, int contentid, int words) async {
  //   return null;
  // }
}

/// [Android],[IOS],[macOS],[fuchsia] implementation
///
/// main Isolate
mixin InnerDatabaseImpl on SqfliteDatabase {
  @override
  String get dataPath => 'book_view_cache.db';

  @override
  Future<Database> getDb() => databaseFactory.openDatabase(dataPath,
      options: OpenDatabaseOptions(version: 1, onCreate: onCreate));
}

/// [Windows],[Linux] implementation
///
mixin InnerDatabaseWinImpl on SqfliteDatabase {
  @override
  String get dataPath => 'book_view_cache_test.db';

  @override
  Future<Database> getDb() {
    sqfliteFfiInit();
    return databaseFactoryFfi.openDatabase(dataPath,
        options: OpenDatabaseOptions(version: 1, onCreate: onCreate));
  }
}
