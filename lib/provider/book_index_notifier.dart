import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../event/event.dart';
import '../utils/utils.dart';

class BookIndexShort {
  BookIndexShort(this.bname, this.cname, this.cid);
  // final String volname;
  final String? cname;
  final int? cid;
  final String? bname;
}

class BookIndexsData {
  const BookIndexsData({
    this.indexs,
    this.id,
    this.cid,
    this.index,
    this.volIndex,
    this.length,
  });
  final List<List>? indexs;
  final int? id;
  final int? cid;
  final int? index;
  final int? volIndex;
  final int? length;

  bool shouldUpdate([int? bookid, int? contentid]) =>
      bookid != id ||
      contentid != cid ||
      indexs == null ||
      indexs!.isEmpty ||
      index == null ||
      volIndex == null ||
      length == null;

  bool get isValid =>
      id != null &&
      cid != null &&
      indexs != null &&
      index != null &&
      volIndex != null &&
      length != null;
}

class BookIndexNotifier extends ChangeNotifier {
  BookIndexNotifier({required this.repository});

  late Repository repository;

  int lastUpdateTime = 0;

  /// 更新时间的间隔
  static const int updateInterval = 1000 * 60 * 3;

  /// 记录所有访问的书籍的更新时间
  Map<int?, int> bookUpDateTime = {};

  void removeExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    bookUpDateTime.removeWhere((_, value) => value + updateInterval <= now);
  }

  bool get listenOn => _listenOnIds.isNotEmpty;

  final _listenOnIds = <Object>{};
  void listener(Object key) {
    _listenOnIds.add(key);
    if (data?.isValid == true) _listenAll();
  }

  void rmListener(Object key) {
    _listenOnIds.remove(key);
    if (!listenOn) {
      Log.w('cancel');

      _watchCurrentCid?.cancel();
      _cids?.cancel();
      _watchCurrentCid = null;
      _cids = null;
    }
  }

  void _listenAll() {
    assert(data?.isValid == true);
    final bookid = data!.id!;
    var cid = data!.cid!;
    _watchCurrentCid ??= repository.bookEvent.bookCacheEvent
        .watchBookCacheCid(bookid)
        .listen((_bookCaches) {
      Log.e('_bookCaches cache ids');

      if (data?.isValid != true) return;

      if (_bookCaches != null && _bookCaches.isNotEmpty) {
        final _cid = _bookCaches.last.chapterId;
        final _bookid = data!.id!;
        cid = data!.cid!;

        if (_bookid == bookid && _cid != cid) {
          sendIndexs(bookid, _cid);
        }
      }
    });
    _cids ??= repository.bookEvent.bookContentEvent
        .watchCacheContentsCidDb(bookid)
        .map((e) => e?.map((e) => e.cid).whereType<int>())
        .listen((listData) {
      if (listData == null) return;
      _cacheList = listData;

      Log.e('book cache ids');

      if (data?.isValid != true) return;

      if (_keys.isNotEmpty && _keys.any(listData.contains)) {
        _keys.clear();
        notifyListeners();
      }
    });
  }

  var _cacheList = Iterable.empty();

  final _keys = <int>{};
  bool contains(int? key) {
    final contains = _cacheList.contains(key);
    if (!contains && key != null) _keys.add(key);
    return contains;
  }

  StreamSubscription? _cids;
  StreamSubscription? _watchCurrentCid;

  BookIndexsData? data;

  void setIndex(int bookid, int cid, List<List> indexs) {
    int? index;
    int? volIndex;
    var inIndexs = false;
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

    if (inIndexs) go(bookid, cid, indexs, index!, volIndex!);
  }

  void go(int bookid, int cid, List<List> indexs, int index, int volIndex) {
    _keys.clear();
    data = BookIndexsData(
        id: bookid,
        cid: cid,
        indexs: indexs,
        index: index,
        volIndex: volIndex,
        length: _cacheList.length);
    notifyListeners();
  }

  final _looper = EventLooper();

  Future<void> sendIndexs([int? bookid, int? contentid]) async {
    _looper.addEventTask(() => _sendIndexs(bookid, contentid));
  }

  Future<void> _sendIndexs([int? bookid, int? contentid]) async {
    bookid ??= data?.id;
    contentid ??= data?.cid;

    if (bookid == null || contentid == null) return;

    final refresh = data?.shouldUpdate(bookid, contentid) ?? true;

    if (listenOn && data?.id != bookid) {
      _watchCurrentCid?.cancel();
      _cids?.cancel();
      _watchCurrentCid = null;
      _cids = null;
    }

    if (refresh) {
      var bookIndexShort = await repository.bookEvent.getIndexs(bookid, false);

      if (bookIndexShort != null && bookIndexShort.isNotEmpty) {
        setIndex(bookid, contentid, bookIndexShort);
      }
    } else if (data?.isValid == true) {
      setIndex(bookid, contentid, data!.indexs!);
    }

    if (data?.shouldUpdate(bookid, contentid) ?? true)
      bookUpDateTime.remove(bookid);

    removeExpired();

    if (!bookUpDateTime.containsKey(bookid)) {
      final bookIndexShort = await repository.bookEvent.getIndexs(bookid, true);
      if (bookIndexShort != null && bookIndexShort.isNotEmpty) {
        setIndex(bookid, contentid, bookIndexShort);
      }
    }

    if (data?.isValid == true) {
      if (listenOn) _listenAll();
      calculate(data!.indexs!, data!.index!, data!.volIndex!);
    }
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
