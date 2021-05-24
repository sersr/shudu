import '../utils/utils.dart';

import '../data/book_content.dart';
import '../bloc/book_cache_bloc.dart';
import '../event/book_event.dart';
import 'nop.dart';
import 'package:path/path.dart';

abstract class BookDatabase implements DatabaseEvent {
  late NopDatabase _db;

  String get path => 'nop_book_database.nopdb';
  String get appPath;

  @override
  Future<void> initState() async {
    _db = NopDatabase.open(join(appPath, path), version: 1,
        onCreate: (db, version) {
      db.execute(
          'CREATE TABLE  if not exists BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId'
          ' INTEGER, chapterId INTEGER, img TEXT, updateTime TEXT, '
          'lastChapter TEXT, sortKey INTEGER, isTop INTEGER,'
          ' cPage INTEGER, isNew INTEGER, isShow INTEGER)');

      db.execute(
          'CREATE TABLE  if not exists BookContent (id INTEGER PRIMARY KEY, bookId INTEGER,'
          ' cid INTEGER, cname TEXT, nid INTEGER, pid INTEGER, content'
          ' TEXT, hasContent INTEGER)');
      db.execute(
          'CREATE TABLE  if not exists BookIndex (id INTEGER PRIMARY KEY, bookId '
          'INTEGER,bIndexs TEXT)');
    });
  }

  @override
  Future<void> updateBookStatusAndSetNew(
      int id, String cname, String updateTime) async {
    final _cname =
        _db.query('SELECT lastChapter from BookInfo where bookId = ?', [id]);

    if (_cname.isNotEmpty) {
      if (_cname.first['lastChapter'] != cname) {
        _db.update(
            'update BookInfo set lastChapter = ?, isNew = ?, updateTime = ? where bookId = ?',
            [cname, 1, updateTime, id]);
      }
    }
  }

  @override
  Future<void> updateBookStatus(int id, int cid, int page) async {
    _db.update(
        'update BookInfo set chapterId = ?, cPage = ?, isNew = ?,sortKey = ? where bookId = ?',
        [cid, page, 0, DateTime.now().millisecondsSinceEpoch, id]);
  }

  @override
  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow) async {
    _db.update(
        'update BookInfo set isTop = ?,sortKey = ?, isShow = ? where bookId = ?',
        [isTop, DateTime.now().millisecondsSinceEpoch, isShow, id]);
  }

  @override
  Future<void> saveContent(BookContent bookContent) =>
      _insertOrUpdateContent(bookContent);

  Future<void> _insertOrUpdateContent(BookContent bookContent) async {
    final count = int.tryParse(_db
        .query('SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?',
            [bookContent.id, bookContent.cid])
        .first
        .columnAt(0)
        .toString());

    if (count! > 0) {
      _db.update(
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
      _db.insert(
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
    return _db.query(
        'SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [bookid, contentid]);
  }

  @override
  Future<Set<int>> getAllBookId() async {
    final key = 'bookId';
    final data = <int>{};
    final _l = _db.query('SELECT $key FROM BookContent');
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
    _db.delete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  @override
  Future<void> insertOrUpdateIndexs(int? id, String indexs) async {
    int? count = 0;
    final q =
        _db.query('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]);
    count = int.tryParse(q.first.columnAt(0).toString()) ?? count;
    print('q: $q, count: $count, ${q.first.values.first}');
    if (count > 0) {
      _db.update(
          'UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info,
          'count: $count,id: $id cache bIndexs.',
          stage: this, name: 'cacheinnerdb'));
    } else {
      _db.insert(
        'INSERT INTO BookIndex (bookId,bIndexs)'
        ' VALUES(?,?)',
        [id, indexs],
      );
    }
  }

  @override
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid) async {
    return _db
        .query('SELECT bIndexs FROM BookIndex WHERE bookId = ?', [bookid]);
  }

  @override
  Future<List<Map<String, Object?>>> getCacheContentsDb(int bookid) async {
    return _db.query('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
  }

  @override
  Future<void> insertBook(BookCache bookCache) async {
    int? count = 0;
    count = int.tryParse(_db
            .query('SELECT COUNT(*) FROM BookInfo where bookid = ?',
                [bookCache.id])
            .first
            .columnAt(0)
            .toString()) ??
        count;

    if (count == 0) {
      _db.insert(
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
    return _db.delete('DELETE FROM BookInfo WHERE bookId = ?', [id]);
  }

  @override
  Future<List<Map<String, Object?>>> getMainBookListDb() async {
    return _db.query('SELECT * FROM BookInfo');
  }
}
