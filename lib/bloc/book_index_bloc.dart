import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  BookIndexBloc({required this.repository}) : super(BookIndexIdleState());

  late Repository repository;

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
      yield* sendIndexs(bookid: event.id ?? 0, contentid: event.cid ?? 0);
    } else if (event is BookIndexReloadEvent) {
      yield* sendIndexs(bookid: id ?? 0, contentid: cid ?? 0);
    }
  }

  Future<void> cacheinnerdb(int? id, String indexs) async {
    return repository.innerdb.cacheinnerdb(id, indexs);
  }

  Stream<BookIndexState> sendIndexs({required int bookid, required int contentid}) async* {
    if (id == bookid &&
        cid == contentid &&
        (bookUpDateTime[bookid] ?? 0) + updateInterval > DateTime.now().millisecondsSinceEpoch) {
      return;
    }
    final _id = id;
    var index = 0;
    var volIndex = 0;
    var inIndexs = false;
    var cacheList = <int>[];
    var queryList = await repository.innerdb.sendIndexs(bookid);
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
      indexs = <List>[];
      if (queryList.isNotEmpty) {
        final restr = queryList.first['bIndexs'] as String?;
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
    id = bookid;
    cid = contentid;
    if (indexs.isEmpty || // immediate
        !inIndexs || // immediate
        (bookUpDateTime[bookid] ?? 0) + updateInterval <= DateTime.now().millisecondsSinceEpoch) {
      final rawData = await repository.getIndexsFromNet(bookid);
      if (rawData.isEmpty) {
        if (indexs.isEmpty) {
          yield BookIndexErrorState();
        } else if (!inIndexs) {
          calculate(indexs, index, volIndex);
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

          await repository.innerdb.updateCname(bookid, newCname, DateTime.now().toStringFormat);
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
          calculate(indexs, index, volIndex);
          yield BookIndexWidthData(
              id: bookid, bookIndexs: indexs, index: index, volIndex: volIndex, cacheList: cacheList);
          await cacheinnerdb(id, rawData);
        }
      }
    } else {
      calculate(indexs, index, volIndex);
    }
  }

  Future<List<List>> loadFromList(String restr) async {
    return await repository.loadIndexsList(restr);
  }

  ValueNotifier<int> slide = ValueNotifier(0);
  var sldvalue = SliderValue(index: 0, max: 200);

  void calculate(List<List> indexs, int index, int volIndex) {
    var max = 200;
    for (var i = 0; i < indexs.length; i++) {
      if (i < volIndex) {
        index += indexs[i].length - 1;
      } else {
        break;
      }
    }
    max = 0;
    indexs.forEach((element) {
      max += element.length - 1;
    });

    max--;
    max = math.max(index, max);

    slide.value = index;

    sldvalue = SliderValue(index: index, max: max);
  }
}

class SliderValue {
  SliderValue({required this.max, required this.index});
  final int max;
  final int index;
}
