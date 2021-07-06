import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../event/event.dart';

import '../utils/utils.dart';

abstract class BookIndexEvent {
  const BookIndexEvent();
}

class BookIndexShowEvent extends BookIndexEvent {
  const BookIndexShowEvent({this.id, this.cid});
  final int? id;
  final int? cid;
}

class BookIndexReloadEvent extends BookIndexEvent {
  const BookIndexReloadEvent();
}

abstract class BookIndexState {
  BookIndexState();
}

class BookIndexIdleState extends BookIndexState {}

class BookIndexErrorState extends BookIndexState {}

class BookIndexShort {
  BookIndexShort(this.bname, this.cname, this.cid);
  // final String volname;
  final String? cname;
  final int? cid;
  final String? bname;
}

class BookIndexWidthData extends BookIndexState {
  BookIndexWidthData({
    required this.bookIndexs,
    required this.id,
    required this.index,
    required this.volIndex,
    required this.length,
  });
  final List<List> bookIndexs;
  final int id;
  final int index;
  final int volIndex;
  final int length;
  @override
  bool operator ==(Object other) {
    return other is BookIndexWidthData &&
        other.bookIndexs == bookIndexs &&
        other.id == id &&
        other.index == index &&
        other.volIndex == volIndex &&
        other.length == length;
  }

  @override
  int get hashCode {
    return hashValues(this, bookIndexs, id, index, volIndex);
  }
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
    _willUpdate = false;
    if (event is BookIndexShowEvent) {
      yield* sendIndexs(bookid: event.id ?? 0, contentid: event.cid ?? 0);
    } else if (event is BookIndexReloadEvent) {
      yield* sendIndexs(bookid: id ?? 0, contentid: cid ?? 0);
    }
  }

  Future<int> cacheinnerdb(int id, String indexs) async {
    return await repository.bookEvent.bookIndexEvent
            .insertOrUpdateIndexs(id, indexs) ??
        0;
  }

  void removeExpired() {
    bookUpDateTime.removeWhere((key, value) =>
        value + updateInterval <= DateTime.now().millisecondsSinceEpoch);
  }

  bool get listenOn => _listenOnIds.isNotEmpty;

  final _listenOnIds = <int>[];
  int get listenOnId {
    final _id = _listenOnIds.length + 1;
    _listenOnIds.add(_id);

    _listenall();

    return _id;
  }

  void removeListener(int id) {
    _listenOnIds.remove(id);
    if (!listenOn) {
      Log.w('cancel');

      _watchCurrentCid?.cancel();
      _cids?.cancel();
      _watchCurrentCid = null;
      _cids = null;
    }
  }

  void _listenall() {
    if (id == null || cid == null) return;
    _watchCurrentCid ??= repository.bookEvent.bookCacheEvent
        .watchBookCacheCid(id!)
        .listen((_bookCaches) {
      if (_bookCaches != null && _bookCaches.isNotEmpty) {
        final f = _bookCaches.last;
        if (f.chapterId != cid) {
          _willUpdate = true;
          _timer?.cancel();
          _timer = Timer(const Duration(milliseconds: 100), () async {
            Log.e('update current cid');
            await EventLooper.instance.wait();

            add(BookIndexShowEvent(id: id, cid: f.chapterId));
          });
        }
      }
    });
    _cids ??= repository.bookEvent.bookContentEvent
        .watchCacheContentsCidDb(id!)
        .map((e) => e?.map((e) => e.cid).whereType<int>())
        .listen((data) {
      if (data == null) return;
      _cacheList = data;
      Log.e('book cache ids');
      _listenCidf ??=
          Future.delayed(const Duration(milliseconds: 600), () async {
        if (!_willUpdate && _keys.isNotEmpty && _keys.any(data.contains)) {
          Log.e('contains');
          _keys.clear();
          await EventLooper.instance.wait();

          add(BookIndexReloadEvent());
        }
      })
            ..whenComplete(() => _listenCidf = null);
    });
  }

  var _willUpdate = false;
  var _cacheList = Iterable.empty();

  Future? _listenCidf;

  final _keys = <int>{};
  bool contains(int? key) {
    final contains = _cacheList.contains(key);
    if (!contains && key != null) _keys.add(key);
    return contains;
  }

  StreamSubscription? _cids;
  StreamSubscription? _watchCurrentCid;
  Timer? _timer;
  Stream<BookIndexState> sendIndexs(
      {required int bookid, required int contentid}) async* {
    removeExpired();

    var index = 0;
    var volIndex = 0;
    var inIndexs = false;

    BookIndexWidthData go() {
      _keys.clear();
      return BookIndexWidthData(
          id: bookid,
          bookIndexs: indexs,
          index: index,
          volIndex: volIndex,
          length: _cacheList.length);
    }

    final same = indexs.isNotEmpty && id == bookid;
    if (!same) {
      yield BookIndexIdleState();
    }
    final _id = id;
    id = bookid;
    cid = contentid;

    if (listenOn) {
      if (_id != bookid) {
        _watchCurrentCid?.cancel();
        _cids?.cancel();
        _watchCurrentCid = null;
        _cids = null;
      }
      _listenall();
    }

    if (same) {
      for (var i = 0; i < indexs.length; i++) {
        for (var l = 0; l < indexs[i].length; l++) {
          if (indexs[i][l] is BookIndexShort && indexs[i][l].cid == cid) {
            index = l - 1;
            volIndex = i;
            inIndexs = true;
            break;
          }
        }
      }

      if (inIndexs) {
        yield go();
        Log.i('yield');
      }
    } else {
      indexs = <List>[];
      var bookIndexShort = await repository.bookEvent.getIndexs(bookid, false);

      if (bookIndexShort != null && bookIndexShort.isNotEmpty) {
        index = 0;
        volIndex = 0;
        for (var i = 0; i < bookIndexShort.length; i++) {
          for (var l = 0; l < bookIndexShort[i].length; l++) {
            if (bookIndexShort[i][l] is BookIndexShort &&
                bookIndexShort[i][l].cid == cid) {
              index = l - 1;
              volIndex = i;
              inIndexs = true;
              break;
            }
          }
        }
        indexs = bookIndexShort;

        if (inIndexs) {
          yield go();

          assert(Log.i('indexs: ${bookIndexShort.length}'));
        }
      }
    }

    if (indexs.isEmpty || !inIndexs || !bookUpDateTime.containsKey(bookid)) {
      final bookIndexShort = await repository.bookEvent.getIndexs(bookid, true);

      if (bookIndexShort != null && bookIndexShort.isNotEmpty) {
        // 网络请求成功

        bookUpDateTime[bookid] = DateTime.now().millisecondsSinceEpoch;

        /// indexs 改变了
        if (indexs.length != bookIndexShort.length ||
            indexs.last.last.cname != bookIndexShort.last.last.cname ||
            indexs.last.last.cid != bookIndexShort.last.last.cid) {
          indexs = bookIndexShort;
          index = 0;
          volIndex = 0;
          for (var i = 0; i < indexs.length; i++) {
            for (var l = 0; l < indexs[i].length; l++) {
              if (indexs[i][l] is BookIndexShort &&
                  indexs[i][l].cid == contentid) {
                index = l - 1;
                volIndex = i;
                break;
              }
            }
          }
          assert(Log.i('indexs, id == bookid'));

          yield go();
        }
      } else {
        if (indexs.isEmpty) {
          yield BookIndexErrorState();
        } else if (!inIndexs) {
          yield go();
        }
      }
    }
    if (indexs.isNotEmpty) calculate(indexs, index, volIndex);
  }

  final slide = ValueNotifier(0);
  var sldvalue = SliderValue(index: 0, max: 200);

  void calculate(List<List> indexs, int index, int volIndex) {
    var _index = index;
    for (var i = 0; i < indexs.length; i++) {
      if (i < volIndex) {
        _index += indexs[i].length - 1;
      } else {
        break;
      }
    }

    var max = indexs.fold<int>(
        0, (previousValue, element) => previousValue + element.length - 1);

    max--;
    max = math.max(_index, max);

    sldvalue
      ..index = _index
      ..max = max;
    slide.value = _index;
  }
}

class SliderValue {
  SliderValue({required this.max, required this.index});
  int max;
  int index;
}
