import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/utils.dart';
import 'book_repository.dart';

abstract class BookIndexEvent {
  BookIndexEvent();
}

class BookIndexShowEvent extends BookIndexEvent {
  BookIndexShowEvent({this.id, this.cid});
  final int? id;
  final int? cid;
}

class BookIndexReloadEvent extends BookIndexEvent {}

abstract class BookIndexState extends Equatable {
  BookIndexState();

  @override
  List<Object?> get props => [];
}

class BookIndexIdleState extends BookIndexState {}

class BookIndexErrorState extends BookIndexState {
  BookIndexErrorState();

  @override
  List<Object> get props => [];
}

class BookIndexShort {
  BookIndexShort(this.bname, this.cname, this.cid);
  // final String volname;
  final String? cname;
  final int? cid;
  final String? bname;
}

class BookIndexWidthData extends BookIndexState {
  BookIndexWidthData(
      {required this.bookIndexs,
      required this.id,
      required this.index,
      required this.volIndex,
      required this.cacheList});
  final List<List> bookIndexs;
  final int id;
  final int index;
  final List<int> cacheList;
  final int volIndex;
  @override
  List<Object?> get props => [id, bookIndexs, index, cacheList, volIndex];
}

class BookIndexBloc extends Bloc<BookIndexEvent, BookIndexState> {
  BookIndexBloc({this.repository}) : super(BookIndexIdleState());

  BookRepository? repository;

  List<List> indexs = [];
  int? id;
  int? cid;
  int lastUpdateTime = 0;

  /// 更新时间的间隔
  static const int updateInterval = 1000 * 60 * 3;

  /// 记录所有访问的书籍的更新时间
  Map<int?, int> bookUpDateTime = {};

  @override
  Stream<BookIndexState> mapEventToState(BookIndexEvent event) async* {
    if (event is BookIndexShowEvent) {
      assert(() {
        if (event.cid == null || event.id == null) {
          print('BookIndexEvent: event == null');
        }
        return true;
      }());
      yield* sendIndexs(bookid: event.id ?? 0, contentid: event.cid ?? 0);
    } else if (event is BookIndexReloadEvent) {
      yield* sendIndexs(bookid: id ?? 0, contentid: cid ?? 0);
    }
  }

  Future<void> cacheinnerdb(int? id, String indexs) async {
    int? count = 0;

    count = Sqflite.firstIntValue(
        await repository!.innerdb.db.rawQuery('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]));
    if (count! > 0) {
      await repository!.innerdb.db.rawUpdate('UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info, 'count: $count,id: $id cache bIndexs.',
          stage: this, name: 'cacheinnerdb'));
    } else {
      await repository!.innerdb.db.rawInsert(
        'INSERT INTO BookIndex (bookId,bIndexs)'
        ' VALUES(?,?)',
        [id, indexs],
      );
    }
  }

  Stream<BookIndexState> sendIndexs({required int bookid, required int contentid}) async* {
    final _id = id;
    var index = 0;
    var volIndex = 0;
    var inIndexs = false;
    var cacheList = <int>[];
    var queryList = await repository!.innerdb.db.rawQuery('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
    for (var l in queryList) {
      cacheList.add(l['cid'] as int);
    }

    if (indexs.isNotEmpty && _id == bookid) {
      for (var i = 0; i < indexs.length; i++) {
        for (var l = 0; l < indexs[i].length; l++) {
          if (indexs[i][l] is BookIndexShort && indexs[i][l].cid == contentid) {
            index = l - 1;
            volIndex = i;
            inIndexs = true;
            break;
          }
        }
      }
      if (inIndexs) {
        yield BookIndexWidthData(
            id: bookid, bookIndexs: indexs, index: index, volIndex: volIndex, cacheList: cacheList);
      }
    } else {
      yield BookIndexIdleState();
      indexs.clear();
      id = bookid;
      cid = contentid;
      var bookList = [];
      bookList = await repository!.innerdb.db.rawQuery('SELECT * FROM BookIndex WHERE bookId = ?', [bookid]);
      if (bookList.isNotEmpty) {
        final restr = bookList.first['bIndexs'] as String?;
        if (restr != null && restr.isNotEmpty) {
          final bookIndexShort = await loadFromList(restr);
          if (bookIndexShort.isNotEmpty) {
            index = 0;
            volIndex = 0;
            for (var i = 0; i < bookIndexShort.length; i++) {
              for (var l = 0; l < bookIndexShort[i].length; l++) {
                if (bookIndexShort[i][l] is BookIndexShort && bookIndexShort[i][l].cid == contentid) {
                  index = l - 1;
                  volIndex = i;
                  inIndexs = true;
                  break;
                }
              }
            }
            if (inIndexs) {
              yield BookIndexWidthData(
                  id: bookid, bookIndexs: bookIndexShort, index: index, volIndex: volIndex, cacheList: cacheList);
              assert(Log.i('indexs: ${bookIndexShort.length}', stage: this, name: 'sendIndexs'));
            }
            indexs = bookIndexShort;
          }
        }
      }
    }

    if (indexs.isEmpty || // immediate
        !inIndexs || // immediate
        (bookUpDateTime[bookid] ?? 0) + updateInterval <= DateTime.now().millisecondsSinceEpoch) {
      final rawData = await repository!.getIndexsFromNet(bookid);
      if (rawData.isEmpty) {
        if (indexs.isEmpty) {
          yield BookIndexErrorState();
        } else if (!inIndexs) {
          yield BookIndexWidthData(
              id: bookid, bookIndexs: indexs, index: index, volIndex: volIndex, cacheList: cacheList);
        }
        return;
      }

      final bookIndexShort = await loadFromList(rawData);

      if (bookIndexShort.isNotEmpty) {
        // 网络请求成功
        bookUpDateTime[bookid] = DateTime.now().millisecondsSinceEpoch;

        /// indexs 改变了
        if (indexs.length != bookIndexShort.length ||
            indexs.last.last.cname != bookIndexShort.last.last.cname ||
            indexs.last.last.cid != bookIndexShort.last.last.cid) {
          final newCname = bookIndexShort.last.last.cname;

          await repository!.innerdb.updateCname(bookid, newCname, DateTime.now().toStringFormat);
          indexs = bookIndexShort;
          index = 0;
          volIndex = 0;
          for (var i = 0; i < indexs.length; i++) {
            for (var l = 0; l < indexs[i].length; l++) {
              if (indexs[i][l] is BookIndexShort && indexs[i][l].cid == contentid) {
                index = l - 1;
                volIndex = i;
                break;
              }
            }
          }
          assert(Log.i('indexs, id == bookid', stage: this, name: 'sendIndexs'));
          yield BookIndexWidthData(
              id: bookid, bookIndexs: indexs, index: index, volIndex: volIndex, cacheList: cacheList);
          await cacheinnerdb(id, rawData);
        }
      }
    }
  }

  Future<List<List>> loadFromList(String restr) async {
    return await repository!.loadIndexsList(restr);
  }
}
