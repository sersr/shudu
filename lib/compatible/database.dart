import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../utils/utils.dart';
import 'book_event.dart';

// 只实现数据库相关函数
mixin SqfliteDatabase on BookEvent {
  late Database _db;
  late String dataPath;

  @override
  Future<void> initState() async {
    _db = await getDb();
  }

  Future<Database> getDb();

  Future<void> onCreate(Database db, int version) async {
    _db = db;
    await db.execute('CREATE TABLE BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId INTEGER, chapterId INTEGER,'
        'img TEXT, updateTime TEXT, lastChapter TEXT, sortKey INTEGER, isTop INTEGER, cPage INTEGER, isNew INTEGER)');
    await db.execute('CREATE TABLE BookContent (id INTEGER PRIMARY KEY, bookId INTEGER, cid INTEGER, cname TEXT,'
        'nid INTEGER, pid INTEGER, content TEXT, hasContent INTEGER)');
    await db.execute('CREATE TABLE BookIndex (id INTEGER PRIMARY KEY, bookId INTEGER,bIndexs TEXT)');
  }

  @override
  Future<void> updateCname(int id, String cname, String updateTime) async {
    final _ocname = await _db.rawQuery('SELECT lastChapter from BookInfo where bookId = ?', [id]);
    if (_ocname.isNotEmpty) {
      if (_ocname.first['lastChapter'] != cname) {
        await _db.rawUpdate('update BookInfo set lastChapter = ?, isNew = ?, updateTime = ? where bookId = ?',
            [cname, 1, updateTime, id]);
      }
    }
  }

  @override
  Future<void> updateMainInfo(int id, int cid, int page) async {
    await _db.rawUpdate('update BookInfo set chapterId = ?, cPage = ?, isNew = ?,sortKey = ? where bookId = ?',
        [cid, page, 0, DateTime.now().millisecondsSinceEpoch, id]);
  }

  @override
  Future<void> updateBookIsTop(int id, int isTop) async {
    await _db.rawUpdate('update BookInfo set isTop = ?,sortKey = ?  where bookId = ?',
        [isTop, DateTime.now().millisecondsSinceEpoch, id]);
  }

  @override
  Future<void> saveToDatabase(BookContent bookContent) async {
    final count = Sqflite.firstIntValue(await _db
        .rawQuery('SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?', [bookContent.id, bookContent.cid]));
    if (count! > 0) {
      await _db.rawUpdate(
          'UPDATE BookContent SET pid = ?, nid = ?, hasContent = ?,content = ? WHERE bookId = ? AND cid = ?', [
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
  Future<List<Map<String, Object?>>> loadFromDb(int bookid, int contentid) async {
    return _db.rawQuery('SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [bookid, contentid]);
  }

  // 只从数据库加载
  @override
  Future<RawContentLines> load(int bookid, int contentid, int words, {bool update = false}) async {
    final queryList = await loadFromDb(bookid, contentid);
    if (queryList.isNotEmpty) {
      final map = queryList.first;
      final bookContent = BookContent.fromJson(map);
      if (bookContent.content != null) {
        final lines = await textLayout(bookContent.content!, bookContent.cname!, words);
        if (lines.isNotEmpty) {
          return RawContentLines(
            pages: lines,
            nid: bookContent.nid,
            pid: bookContent.pid,
            cid: bookContent.cid,
            hasContent: bookContent.hasContent,
            cname: bookContent.cname,
          );
        }
      }
    }
    return super.load(bookid, contentid, words);
  }

  @override
  Future<void> deleteCache(int bookId) async {
    await _db.rawDelete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  @override
  Future<void> cacheinnerdb(int? id, String indexs) async {
    int? count = 0;

    count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]));
    if (count! > 0) {
      await _db.rawUpdate('UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info, 'count: $count,id: $id cache bIndexs.',
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
  Future<List<Map<String, Object?>>> sendIndexs(int bookid) async {
    return _db.rawQuery('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
  }

  @override
  Future<void> addBook(BookCache bookCache) async {
    int? count = 0;
    count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM BookInfo where bookid = ?', [bookCache.id]));
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
  Future<List<Map<String, Object?>>> loadBookInfo() async {
    return _db.rawQuery('SELECT * FROM BookInfo');
  }
}

/// [Android],[IOS],[macOS],[fuchsia] implementation
///
/// main Isolate
abstract class InnerDatabaseImpl extends BookEvent with SqfliteDatabase {
  @override
  String dataPath = 'book_view_cache.db';

  @override
  Future<Database> getDb() => openDatabase(dataPath, version: 1, onCreate: onCreate);
}

/// [Windows],[Linux] implementation
///
abstract class InnerDatabaseWinImpl extends BookEvent with SqfliteDatabase {
  @override
  String dataPath = 'book_view_cache_test.db';

  @override
  Future<Database> getDb() {
    sqfliteFfiInit();
    return databaseFactoryFfi.openDatabase(dataPath, options: OpenDatabaseOptions(version: 1, onCreate: onCreate));
  }
}
