import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shudu/bloc/book_repository.dart';
import 'package:shudu/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

abstract class BookIndexEvent extends Equatable {
  BookIndexEvent();
  @override
  List<Object?> get props => [];
}

class BookIndexShowEvent extends BookIndexEvent {
  BookIndexShowEvent({this.id, this.cid});
  final int? id;
  final int? cid;
  @override
  List<Object?> get props => [id, cid];
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
  int updateInterval = 600000;

  /// 记录所有访问的书籍的更新时间
  Map<int?, int> bookUpDateTime = {};

  @override
  Stream<BookIndexState> mapEventToState(BookIndexEvent event) async* {
    if (event is BookIndexShowEvent) {
      // if (cid == event.cid) {
      //   final _s = state;
      //   yield BookIndexLoadingState();
      //   await Future.delayed(Duration(milliseconds: 400 * (Random().nextInt(3) + 1)));
      //   yield _s;
      //   return;
      // }
      yield* await sendIndexs(bookid: event.id ?? 0, contentid: event.cid ?? 0);
    } else if (event is BookIndexReloadEvent) {
      yield* await sendIndexs(bookid: id ?? 0, contentid: cid ?? 0);
    }
  }

  Future<void> cachedb(int? id, String indexs) async {
    int? count = 0;

    count =
        Sqflite.firstIntValue(await repository!.db.rawQuery('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]));
    if (count! > 0) {
      await repository!.db.rawUpdate('UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info, 'count: $count,id: ${id} cache bIndexs.',
          stage: this, name: 'cachedb'));
    } else {
      await repository!.db.rawInsert(
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
    var queryList = await repository!.db.rawQuery('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
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
        assert(Log.i('indexs, id == bookid', stage: this, name: 'sendIndexs'));
        yield BookIndexWidthData(
            id: bookid, bookIndexs: indexs, index: index, volIndex: volIndex, cacheList: cacheList);
      }
    } else {
      yield BookIndexIdleState();
      indexs.clear();
      id = bookid;
      cid = contentid;
      var bookList = [];
      bookList = await repository!.db.rawQuery('SELECT * FROM BookIndex WHERE bookId = ?', [bookid]);
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
    if (indexs.isEmpty ||
        !inIndexs ||
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

      /// indexs 改变了
      if (indexs.length != bookIndexShort.length ||
          indexs.last.last.cname != bookIndexShort.last.last.cname ||
          indexs.last.last.cid != bookIndexShort.last.last.cid) {
        // var index = bookIndexShort.length - 1;
        indexs = bookIndexShort;

        final newCname = bookIndexShort.last.last.cname;

        await repository!.updateCname(bookid, newCname, DateTime.now().toStringFormat);

        if (bookIndexShort.isNotEmpty) {
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
          final lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
          bookUpDateTime[bookid] = lastUpdateTime;
          assert(Log.i('indexs, id == bookid', stage: this, name: 'sendIndexs'));
          yield BookIndexWidthData(
              id: bookid, bookIndexs: indexs, index: index, volIndex: volIndex, cacheList: cacheList);
        }
        await cachedb(id, rawData);
      }
    }
  }

  Future<List<List>> loadFromList(String restr) async {
    return await repository!.loadIndexsList(restr);
  }
}
