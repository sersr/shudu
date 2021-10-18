import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:useful_tools/useful_tools.dart';

import '../data/data.dart';
import '../event/event.dart';

class BookIndexsData {
  BookIndexsData({this.indexs, this.bookid, this.contentid}) {
    chapters;
  }
  static final none = BookIndexsData();

  final NetBookIndex? indexs;
  final int? bookid;
  final int? contentid;

  List<String>? _vols;
  int? _index;
  int? _volIndex;
  int? _currentIndex;
  List<BookIndexChapter>? _allChapters;

  List<String>? get vols => _vols;

  int? get index => _index;

  int? get volIndex => _volIndex;

  int? get currentIndex => _currentIndex;

  List<BookIndexChapter>? get allChapters {
    final _all = _allChapters;
    if (_all == null || _all.isEmpty) {
      final _c = chapters;
      if (_c != null) _allChapters ??= _c.expand((element) => element).toList();
    }

    return _allChapters;
  }

  // final int? length;
  List<List<BookIndexChapter>>? _chapters;

  // 初始化
  List<List<BookIndexChapter>>? get chapters {
    final _c = _chapters;
    if (_c != null && _c.isNotEmpty) return _c;

    final list = indexs?.list;
    if (list == null) return null;

    var currentIndex = 0;
    _chapters ??= list.map((e) => e.list ?? const []).toList();
    _vols ??= list.map<String>((e) => e.name ?? '').toList();

    assert(_chapters?.length == _vols?.length);

    var done = false;
    for (var i = 0; i < list.length; i++) {
      final _i = list[i];
      final clist = _i.list;
      if (clist != null) {
        for (var l = 0; l < clist.length; l++) {
          final short = clist[l];

          if (short.id == contentid ||
              (i == list.length - 1 && l == clist.length - 1)) {
            _index = l;
            _volIndex = i;
            currentIndex += l;
            done = true;
            break;
          }
        }
        if (!done) currentIndex += clist.length;
      }
      if (done) break;
    }
    _currentIndex = currentIndex;
    return _chapters;
  }

  bool shouldUpdate([int? bookid, int? contentid]) =>
      this.bookid != bookid ||
      this.contentid != contentid ||
      indexs?.list == null ||
      _index == null ||
      _volIndex == null;

  bool get isValid =>
      bookid != null &&
      contentid != null &&
      indexs != null &&
      _index != null &&
      _volIndex != null;

  bool equalTo(Object? other) {
    if (identical(this, other)) return true;
    return runtimeType == other.runtimeType &&
        other is BookIndexsData &&
        bookid == other.bookid &&
        contentid == other.contentid &&
        indexs?.list?.length == other.indexs?.list?.length &&
        _index == other._index &&
        _volIndex == other._volIndex;
  }
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

  StreamSubscription? _cids;
  StreamSubscription? _watchCurrentCid;

  void addRegisterKey(Object key) {
    _listenOnIds.add(key);
    assert(Log.i('register'));
    EventQueue.runOneTaskOnQueue(this, () {
      if (listenOn && _data?.isValid == true) {
        _listenAll();
      }
    });
  }

  void removeRegisterKey(Object key) {
    _listenOnIds.remove(key);
    EventQueue.runOneTaskOnQueue(this, () {
      if (!listenOn) {
        assert(Log.i('pause'));
        _watchCurrentCid?.pause();
        _cids?.pause();
      }
    });
  }

  void _listenerReset() {
    _watchCurrentCid?.cancel();
    _cids?.cancel();
    _watchCurrentCid = null;
    _cids = null;
  }

  void _listenAll() {
    assert(_data?.isValid == true);
    final bookid = _data!.bookid!;

    _watchCurrentCid ??= repository.bookEvent.bookCacheEvent
        .watchBookCacheCid(bookid)
        .listen((_bookCaches) {
      assert(Log.e('_bookCaches cache ids'));

      if (_data?.isValid != true) return;
      EventQueue.runOneTaskOnQueue(_watchCurrentCid, () {
        if (_bookCaches != null && _bookCaches.isNotEmpty) {
          final _cid = _bookCaches.last.chapterId;
          final _bookid = _data!.bookid!;
          final cid = _data!.contentid!;

          if (_bookid == bookid && _cid != cid) {
            loadIndexs(bookid, _cid);
          }
        }
      });
    });

    _cids ??= repository.bookEvent.bookContentEvent
        .watchCacheContentsCidDb(bookid)
        .map((e) => e?.map((e) => e.cid).whereType<int>())
        .listen((listData) {
      if (listData == null) return;

      EventQueue.runOneTaskOnQueue(_cids, () {
        assert(Log.e('book cache ids'));
        if (_data?.isValid != true) return;
        Log.e('book cache ids ${_data?.bookid == bookid}', onlyDebug: false);

        if (_data?.bookid == bookid) {
          _cacheList = listData;
          notifyListeners();
        }
      });
    });
    _watchCurrentCid?.resume();
    _cids?.resume();
  }

  var _cacheList = Iterable.empty();

  bool contains(int? key) {
    return _cacheList.contains(key);
  }

  // 数据集合
  BookIndexsData? _data;
  BookIndexsData? get data => _data;

  void setIndexData(int bookid, int contentid, NetBookIndex indexs) {
    final data =
        BookIndexsData(bookid: bookid, contentid: contentid, indexs: indexs);
    final _list = data.chapters;
    if (_list != null && _list.isNotEmpty) {
      if (_data?.bookid != data.bookid) {
        _listenerReset();
      }
      _data = data;
      notifyListeners();
    }
  }

  final _queue = EventQueue();


  void loadIndexs([int? bookid, int? contentid, bool restore = false]) {
    if (!_queue.actived) {
      // 先执行在添加到队列中
      final f = _load(bookid, contentid, restore);
      _queue.addEventTask(() => f);
      return;
    }
    _queue.addOneEventTask(() => _load(bookid, contentid, restore));
  }

  Future<void> _load(
      [int? bookid, int? contentid, bool restore = false]) async {
    bookid ??= _data?.bookid;
    contentid ??= _data?.contentid;

    if (bookid == null || contentid == null) return;
    final refresh = _data?.shouldUpdate(bookid, contentid) ?? true;

    final isNewBook = _data?.bookid != bookid;

    await releaseUI;
    if (isNewBook) {
      final data = _data;
      _data = null;
      if (data != null) notifyListeners();

      final bookIndexShort =
          await repository.bookEvent.getIndexs(bookid, false) ??
              const NetBookIndex();

      setIndexData(bookid, contentid, bookIndexShort);
    } else if (refresh && _data?.isValid == true) {
      setIndexData(bookid, contentid, _data!.indexs!);
    } else if (restore) {
      notifyListeners();
    }

    // data == null or data.bookid != bookid or data.contentid != contentid
    // ...
    if (_data?.shouldUpdate(bookid, contentid) ?? true)
      bookUpDateTime.remove(bookid);

    removeExpired();

    if (!bookUpDateTime.containsKey(bookid)) {
      final bookIndexShort =
          await repository.bookEvent.getIndexs(bookid, true) ??
              const NetBookIndex();

      setIndexData(bookid, contentid, bookIndexShort);

      if (_data != null &&
          _data!.isValid &&
          bookid == _data!.bookid &&
          bookIndexShort.list != null) {
        bookUpDateTime[bookid] = DateTime.now().millisecondsSinceEpoch;
      }
    }

    // 没有及时更新
    if (_data?.bookid != bookid) {
      _data = BookIndexsData.none;
    }

    if (_data?.isValid == true) {
      if (listenOn) _listenAll();
      calculate(_data!);
    } else {
      notifyListeners();
    }
  }

  final slide = ValueNotifier(0);
  var sldvalue = SliderValue(index: 0, max: 200);

  void calculate(BookIndexsData data) {
    final _list = data.allChapters;
    final _current = data.currentIndex;
    if (_list == null || _current == null) return;

    /// 数组 以 0 为起点
    final _max = _list.length - 1;

    sldvalue
      ..index = _current
      ..max = _max;
    slide.value = _current;
  }
}

class SliderValue {
  SliderValue({required this.max, required this.index});
  int max;
  int index;
}
