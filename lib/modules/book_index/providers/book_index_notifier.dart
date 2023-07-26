import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:nop/nop.dart';

import '../../../api/api.dart';
import '../../../data/data.dart';
import '../../../event/export.dart';

class BookIndexsData {
  BookIndexsData(
      {this.api = ApiType.biquge, this.indexs, this.bookid, this.contentid}) {
    chapters;
  }
  static final none = BookIndexsData();
  final ApiType api;
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
  int? get currentIndex {
    return _currentIndex;
  }

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

  bool shouldUpdate(int? bookid, int? contentid, ApiType api) =>
      this.bookid != bookid ||
      this.contentid != contentid ||
      this.api != api ||
      (this.api == ApiType.biquge &&
          (indexs?.list == null || _index == null || _volIndex == null));

  bool get isValid => isValidBqg;
  bool get isValidBqg =>
      api == ApiType.biquge &&
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
        api == other.api &&
        _index == other._index &&
        _volIndex == other._volIndex;
  }
}

class BookIndexNotifier extends ChangeNotifierBase
    with NotifyStateOnChangeNotifier, NopLifecycle {
  BookIndexNotifier();

  late final Repository repository = getType();
  @override
  void nopInit() {
    super.nopInit();
    handle = repository;
  }

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
    EventQueue.runOne(this, () {
      if (listenOn && _data?.isValid == true) {
        _listenAll();
      }
    });
  }

  void removeRegisterKey(Object key) {
    _listenOnIds.remove(key);
    EventQueue.runOne(this, () {
      if (!listenOn) {
        assert(Log.i('pause'));
        _pauseAll();
      }
    });
  }

  @override
  void onOpen() {
    if (_data?.isValid == true) {
      _listenAll();
      if (!listenOn) {
        _pauseAll();
      }
    }
  }

  @override
  void onClose() {
    _listenerReset();
  }

  void _listenerReset() {
    _watchCurrentCid?.cancel();
    _cids?.cancel();
    _watchCurrentCid = null;
    _cids = null;
  }

  @override
  void dispose() {
    _listenerReset();
    super.dispose();
  }

  void _pauseAll() {
    if (_watchCurrentCid?.isPaused == false) {
      _watchCurrentCid?.pause();
    }
    if (_cids?.isPaused == false) {
      _cids?.pause();
    }
  }

  void _rsumeAll() {
    if (_watchCurrentCid?.isPaused == true) {
      _watchCurrentCid?.resume();
    }
    if (_cids?.isPaused == true) {
      _cids?.resume();
    }
  }

  void _listenAll() {
    _rsumeAll();
    _listenAllBiquge();
  }

  void _listenAllBiquge() {
    assert(_data?.isValid == true);
    final bookid = _data!.bookid!;

    _watchCurrentCid ??=
        repository.bookCacheEvent.watchCurrentCid(bookid).listen((_bookCaches) {
      if (_data?.isValidBqg != true) return;
      EventQueue.runOne(_watchCurrentCid, () {
        if (_bookCaches.isNotEmpty) {
          final _cid = _bookCaches.last.chapterId;
          final _bookid = _data!.bookid!;
          final cid = _data!.contentid!;

          if (_bookid == bookid && _cid != cid) {
            loadIndexs(bookid, _cid);
          }
        }
      });
    }, onDone: () {
      _watchCurrentCid = null;
    });

    _cids ??= repository.bookContentEvent.watchBookContentCid(bookid).map((e) {
      return e.map((e) => e.cid).whereType<int>();
    }).listen((listData) {
      EventQueue.runOne(_cids, () {
        if (_data?.isValidBqg != true) return;
        if (_data?.bookid == bookid) {
          _cacheList = listData;
          notifyListeners();
        }
      });
    }, onDone: () {
      _cids = null;
    });
  }

  var _cacheList = Iterable<int>.empty();

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
  void reloadIndexs() {
    loadIndexs(null, null);
  }

  Future<void> loadIndexs(int? bookid, int? contentid,
      {bool restore = false, ApiType api = ApiType.biquge}) async {
    return _queue.addOneEventTask(
        () => _load(bookid, contentid, restore: restore, api: api));
  }

  Future<void> _load(int? bookid, int? contentid,
      {ApiType api = ApiType.biquge, bool restore = false}) async {
    bookid ??= _data?.bookid;
    contentid ??= _data?.contentid;

    if (bookid == null || contentid == null) return;
    final refresh = _data?.shouldUpdate(bookid, contentid, api) ?? true;

    final isNewBook = _data?.bookid != bookid;
    assert(Log.i(
        'update: bookid: $bookid cid: $contentid $isNewBook | $refresh | $restore'));

    await idleWait;
    if (isNewBook) {
      final data = _data;
      _data = null;
      if (data != null) notifyListeners();
      final bookIndexShort =
          await repository.getIndexs(bookid, false) ?? const NetBookIndex();

      setIndexData(bookid, contentid, bookIndexShort);
    } else {
      bool _done = true;
      if (refresh) {
        if (_data?.isValidBqg == true) {
          setIndexData(bookid, contentid, _data!.indexs!);
        } else {
          _done = false;
        }
      }
      if (!_done && restore) {
        notifyListeners();
      }
    }

    // data == null or data.bookid != bookid or data.contentid != contentid
    // ...
    if (_data?.shouldUpdate(bookid, contentid, api) ?? true)
      bookUpDateTime.remove(bookid);

    removeExpired();

    if (!bookUpDateTime.containsKey(bookid)) {
      final bookIndexShort =
          await repository.getIndexs(bookid, true) ?? const NetBookIndex();

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
    int? max;
    int? current;

    final list = data.allChapters;
    final _current = data.currentIndex;

    if (list != null) max = list.length - 1;
    current = _current;

    if (max == null || current == null) return;
    max = math.max(max, current);
    sldvalue
      ..index = current
      ..max = max;
    slide.value = current;
  }
}

class SliderValue {
  SliderValue({required this.max, required this.index});
  int max;
  int index;
}
