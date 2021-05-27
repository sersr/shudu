import 'dart:async';

import '../utils/utils.dart';
import 'package:sqlite3/sqlite3.dart';

typedef _DatabaseFunction = void Function(NopDatabase db, int version);
typedef _DatabaseUpgradeFunction = void Function(
    NopDatabase db, int oVersion, int nVersion);
typedef ReturnQuery = int Function(String sql, [List<Object?> paramters]);
typedef Execute = void Function(String sql, [List<Object?> paramters]);

abstract class NopDatabase {
  NopDatabase();

  static final _openlist = <String, NopDatabase>{};

  static NopDatabase open(
    String path, {
    required _DatabaseFunction onCreate,
    int version = 1,
    _DatabaseUpgradeFunction? onUpgrade,
    _DatabaseUpgradeFunction? onDowngrade,
  }) {
    if (_openlist.containsKey(path)) return _openlist[path]!;
    final nop = NopDatabaseImpl._();
    _openlist[path] = nop;
    nop._open(path,
        version: version,
        onCreate: onCreate,
        onDowngrade: onDowngrade,
        onUpgrade: onUpgrade);
    return nop;
  }

  Execute get execute;
  List<Row> Function(String sql, [List<Object?> parameters]) get rawQuery;
  ReturnQuery get rawUpdate;
  ReturnQuery get rawDelete;
  ReturnQuery get rawInsert;
}

class NopDatabaseImpl extends NopDatabase {
  NopDatabaseImpl._();
  late Database db;

  @override
  late final execute = db.execute;

  @override
  late var rawQuery = _query;

  @override
  late var rawDelete = _inneridu;

  @override
  late var rawUpdate = _inneridu;
  @override
  late var rawInsert = _inneridu;

  void _open(
    String path, {
    required _DatabaseFunction onCreate,
    int version = 1,
    _DatabaseUpgradeFunction? onUpgrade,
    _DatabaseUpgradeFunction? onDowngrade,
  }) {
    assert(version > 0);

    db = sqlite3.open(path);
    final _v = db.userVersion;

    if (_v == 0) {
      onCreate(this, version);
      db.userVersion = version;
    } else if (_v < version) {
      assert(onUpgrade != null, 'onUpgrade == null');

      if (onUpgrade != null) {
        db.userVersion = version;
        onUpgrade(this, _v, version);
      }
    } else if (_v < version) {
      assert(onDowngrade != null, 'onDowngrade == null');

      if (onDowngrade != null) {
        db.userVersion = version;
        onDowngrade(this, _v, version);
      }
    }
  }

  List<Row> _query(String sql, [List<Object?> parameters = const []]) {
    final result = db.select(sql, parameters);
    return result.map((e) => e).toList();
  }

  int _inneridu(String sql, [List<Object?> paramters = const []]) {
    execute(sql, paramters);

    final count = db.getUpdatedRows();

    if (count > 0 && watcher.hasListener) watcher.run();

    return count;
  }

  final watcher = Watcher();

  QueryListener watch(String sql, [List<Object?> parameters = const []]) {
    return watcher.addListener(
        '${sql}_${parameters.join()}', () => _query(sql, parameters));
  }
}

typedef WatcherFu = List<Map<String, Object?>> Function();

class Watcher {
  Watcher();
  final listeners = <String, QueryListener>{};

  bool get hasListener => listeners.isNotEmpty;

  QueryListener addListener(String key, WatcherFu fn) {
    if (listeners.containsKey(key)) return listeners[key]!;
    final l = QueryListener(key, this, fn);
    listeners[key] = l;
    return l;
  }

  void removeListener(String key) {
    listeners.remove(key);
  }

  void run() {
    for (final l in listeners.values) l._run();
  }
}

class QueryListener {
  QueryListener(this.key, this.watcher, this.watchFn) {
    _controller = StreamController.broadcast(onCancel: _cancel);
  }
  final WatcherFu watchFn;
  final Watcher watcher;
  final String key;

  late StreamController _controller;

  void _cancel() {
    if (!_controller.hasListener) {
      Log.i('no listener');
      // assert(
      //     watcher.listeners.containsKey(key) && watcher.listeners[key] == this);

      // watcher.removeListener(key);
    }
  }

  StreamSubscription listen(
    void Function(dynamic)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  void _run() {
    if (_controller.hasListener) {
      _controller.add(watchFn());
    } else {
      assert(
          watcher.listeners.containsKey(key) && watcher.listeners[key] == this);

      watcher.removeListener(key);
    }
  }
}

// class Table {
//   const Table({this.name = ''});
//   final String name;
// }

// class Column {
//   const Column({this.name = ''});
//   final String name;
// }

// class BookCache {
//   BookCache({
//     this.chapterId,
//     this.img,
//     this.lastChapter,
//     this.name,
//     this.updateTime,
//     this.id,
//     this.isTop,
//     this.sortKey,
//     this.isNew,
//     this.page,
//     this.isShow,
//   });
//   final String? name;
//   final String? img;
//   final String? updateTime;
//   final String? lastChapter;
//   final int? chapterId;
//   final int? id;
//   final int? sortKey;
//   final int? isTop;
//   final int? page;
//   final int? isNew;
//   final int? isShow;

//   factory BookCache.fromMap(Map<String, dynamic> map) {
//     return BookCache(
//       img: map['img'] as String?,
//       updateTime: map['updateTime'] as String?,
//       lastChapter: map['lastChapter'] as String?,
//       chapterId: map['chapterId'] as int?,
//       id: map['bookId'] as int?,
//       name: map['name'] as String?,
//       sortKey: map['sortKey'] as int?,
//       isTop: map['isTop'] as int?,
//       page: map['cPage'] as int?,
//       isNew: map['isNew'] as int?,
//       isShow: map['isShow'] as int? ?? 0,
//     );
//   }
  

//   static const tableName = 'Bookinfo';
//   static String createTable() {
//     return 'CREATE TABLE if not exists $tableName ('
//         'id INTEGER PRIMARY KEY, name TEXT, bookId INTEGER, chapterId INTEGER,'
//         'img TEXT, updateTime TEXT, lastchapter TEXT, sortKey INTEGER, isTop INTEGER'
//         'page INTEGER, isNew INTEGER, isShow INTEGER';
//   }
// }
