import '../data/book_content.dart';
import '../event/book_event.dart';
import '../utils/utils.dart';
import 'book_database.dart';
import 'table.dart';

// 数据库接口实现
mixin DatabaseMixin on BookDatabase, DatabaseEvent, ComplexEventDatabase {
  @override
  Future<void> updateBookStatusAndSetNew(int id,
      [String? cname, String? updateTime]) async {
    assert(cname != null && updateTime != null);
    final _cname =
        query('SELECT lastChapter from BookInfo where bookId = ?', [id]);

    if (_cname.isNotEmpty) {
      if (_cname.first['lastChapter'] != cname) {
        update(
            'update BookInfo set lastChapter = ?, isNew = ?, updateTime = ? where bookId = ?',
            [cname, 1, updateTime, id]);
      }
    }
  }

  @override
  Future<void> updateBookStatusCustom(int id, int cid, int page) async {
    update(
        'update BookInfo set chapterId = ?, cPage = ?, isNew = ?,sortKey = ? where bookId = ?',
        [cid, page, 0, DateTime.now().millisecondsSinceEpoch, id]);
  }

  @override
  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow) async {
    update(
        'update BookInfo set isTop = ?,sortKey = ?, isShow = ? where bookId = ?',
        [isTop, DateTime.now().millisecondsSinceEpoch, isShow, id]);
  }

  @override
  Future<void> saveContent(BookContent bookContent) =>
      _insertOrUpdateContent(bookContent);

  Future<void> _insertOrUpdateContent(BookContent bookContent) async {
    final count = int.tryParse(query(
        'SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?',
        [bookContent.id, bookContent.cid]).first.columnAt(0).toString());

    if (count! > 0) {
      update(
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
      insert(
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

  Future<List<Map<String, Object?>>> getContentDb(
      int bookid, int contentid) async {
    return query(
        'SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [bookid, contentid]);
  }

  @override
  Future<Set<int>> getAllBookId() async {
    final key = 'bookId';
    final data = <int>{};
    final _l = query('SELECT $key FROM BookContent');
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
    delete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  @override
  Future<void> insertOrUpdateIndexs(int? id, String indexs) async {
    int? count = 0;
    final q = query('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]);
    count = int.tryParse(q.first.columnAt(0).toString()) ?? count;

    if (count > 0) {
      update('UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info,
          'count: $count,id: $id cache bIndexs.'));
    } else {
      insert(
        'INSERT INTO BookIndex (bookId,bIndexs)'
        ' VALUES(?,?)',
        [id, indexs],
      );
    }
  }

  @override
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid) async {
    return query('SELECT bIndexs FROM BookIndex WHERE bookId = ?', [bookid]);
  }

  @override
  Future<List<Map<String, Object?>>> getCacheContentsCidDb(int bookid) async {
    return query('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
  }

  @override
  Future<void> insertBook(BookCache bookCache) async {
    int? count = 0;
    count = int.tryParse(query('SELECT COUNT(*) FROM BookInfo where bookid = ?',
            [bookCache.id]).first.columnAt(0).toString()) ??
        count;

    if (count == 0) {
      insert(
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
    return delete('DELETE FROM BookInfo WHERE bookId = ?', [id]);
  }

  @override
  Future<List<Map<String, Object?>>> getMainBookListDb() async {
    return query('SELECT * FROM BookInfo');
  }
}
