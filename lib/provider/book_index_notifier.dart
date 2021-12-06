import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:useful_tools/useful_tools.dart';

import '../data/data.dart';
import '../event/event.dart';

enum ApiType {
  biquge,
  zhangdu,
}

class BookIndexsData {
  BookIndexsData(
      {this.api = ApiType.biquge,
      this.indexs,
      this.data,
      this.bookid,
      this.contentid}) {
    chapters;
  }
  static final none = BookIndexsData();
  final ApiType api;
  final NetBookIndex? indexs;
  final int? bookid;
  final int? contentid;
  final List<ZhangduChapterData>? data;
  List<String>? _vols;
  int? _index;
  int? _volIndex;
  int? _currentIndex;
  List<BookIndexChapter>? _allChapters;

  List<String>? get vols => _vols;

  int? get index => _index;

  int? get volIndex => _volIndex;
  int? _zuIndex;
  int? get currentIndex {
    if (api == ApiType.biquge) {
      return _currentIndex;
    } else {
      if (_zuIndex != null || data == null) return _zuIndex;
      var current = data!.length - 1;
      for (var i = 0; i < data!.length; i++) {
        if (data![i].id == contentid) {
          current = i;
          break;
        }
      }
      return _zuIndex ??= current;
    }
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
          (indexs?.list == null || _index == null || _volIndex == null)) ||
      (this.api == ApiType.zhangdu && data?.isNotEmpty != true);

  bool get isValid => isValidBqg || isValidZd;
  bool get isValidBqg =>
      api == ApiType.biquge &&
      bookid != null &&
      contentid != null &&
      indexs != null &&
      _index != null &&
      _volIndex != null;
  bool get isValidZd =>
      api == ApiType.zhangdu &&
      bookid != null &&
      contentid != null &&
      data?.isNotEmpty == true;
  bool equalTo(Object? other) {
    if (identical(this, other)) return true;
    return runtimeType == other.runtimeType &&
        other is BookIndexsData &&
        bookid == other.bookid &&
        contentid == other.contentid &&
        indexs?.list?.length == other.indexs?.list?.length &&
        api == other.api &&
        data == other.data &&
        _index == other._index &&
        _volIndex == other._volIndex;
  }
}

class BookIndexNotifier extends ChangeNotifier
    with NotifyStateOnChangeNotifier {
  BookIndexNotifier({required this.repository}) {
    handle = repository;
  }

  final Repository repository;

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
    // 如果是暂停状态，`onDone`不会调用
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
    final d = data;
    if (d != null) {
      switch (d.api) {
        case ApiType.biquge:
          _listenAllBiquge();
          break;
        case ApiType.zhangdu:
          _listenAllZhangdu();
          break;
        default:
      }
    }
  }

  void _listenAllZhangdu() {
    assert(_data?.isValid == true);
    final bookid = _data!.bookid!;

    _watchCurrentCid ??= repository.bookEvent.zhangduEvent
        .watchZhangduCurrentCid(bookid)
        .listen((_bookCaches) {
      assert(Log.w('正在监听: $bookid | 当前章节 cid ...'));

      if (_data?.isValidZd != true) return;
      EventQueue.runOneTaskOnQueue(_watchCurrentCid, () {
        if (_bookCaches != null && _bookCaches.isNotEmpty) {
          final _cid = _bookCaches.last.chapterId;
          final _bookid = _data!.bookid!;
          final cid = _data!.contentid!;

          if (_bookid == bookid && _cid != cid) {
            loadIndexs(bookid, _cid, api: ApiType.zhangdu);
          }
        }
      });
    }, onDone: () {
      _watchCurrentCid = null;
    });

    _cids ??= repository.bookEvent.zhangduEvent
        .watchZhangduContentCid(bookid)
        .listen((listData) {
      if (listData == null) return;

      EventQueue.runOneTaskOnQueue(_cids, () {
        assert(Log.w('正在监听: $bookid | 缓存章节 ...'));
        if (_data?.isValidZd != true) return;

        if (_data?.bookid == bookid) {
          _cacheList = listData;
          notifyListeners();
        }
      });
    }, onDone: () {
      _cids = null;
    });
    _rsumeAll();
  }

  void _listenAllBiquge() {
    assert(_data?.isValid == true);
    final bookid = _data!.bookid!;

    _watchCurrentCid ??= repository.bookEvent.bookCacheEvent
        .watchCurrentCid(bookid)
        .listen((_bookCaches) {
      if (_data?.isValidBqg != true) return;
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
    }, onDone: () {
      _watchCurrentCid = null;
    });

    _cids ??= repository.bookEvent.bookContentEvent
        .watchBookContentCid(bookid)
        .map((e) => e?.map((e) => e.cid).whereType<int>())
        .listen((listData) {
      if (listData == null) return;

      EventQueue.runOneTaskOnQueue(_cids, () {
        Log.i('book cache ids ${_data?.bookid == bookid}', onlyDebug: false);
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

  void setZhangduIndexData(
      int bookid, int contentid, List<ZhangduChapterData> chapterData) {
    final data = BookIndexsData(
        bookid: bookid,
        contentid: contentid,
        data: chapterData,
        api: ApiType.zhangdu);
    if (chapterData.isNotEmpty) {
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
    Log.i(
        'update: bookid: $bookid cid: $contentid $isNewBook | $refresh | $restore');

    await releaseUI;
    if (isNewBook) {
      final data = _data;
      _data = null;
      if (data != null) notifyListeners();
      if (api == ApiType.biquge) {
        final bookIndexShort =
            await repository.bookEvent.getIndexs(bookid, false) ??
                const NetBookIndex();

        setIndexData(bookid, contentid, bookIndexShort);
      } else if (api == ApiType.zhangdu) {
        final data = await repository.bookEvent.zhangduEvent
                .getZhangduIndex(bookid, false) ??
            const [];
        setZhangduIndexData(bookid, contentid, data);
      }
    } else {
      bool _done = true;
      if (refresh) {
        if (_data?.isValidBqg == true) {
          setIndexData(bookid, contentid, _data!.indexs!);
        } else if (_data?.isValidZd == true) {
          setZhangduIndexData(bookid, contentid, _data!.data!);
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
      if (api == ApiType.biquge) {
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
      } else if (api == ApiType.zhangdu) {
        final d = await repository.bookEvent.zhangduEvent
                .getZhangduIndex(bookid, true) ??
            const [];
        setZhangduIndexData(bookid, contentid, d);
        if (_data != null &&
            _data!.isValid &&
            bookid == _data!.bookid &&
            d.isNotEmpty) {
          bookUpDateTime[bookid] = DateTime.now().millisecondsSinceEpoch;
        }
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
    if (data.api == ApiType.biquge) {
      final list = data.allChapters;
      final _current = data.currentIndex;

      if (list != null) max = list.length - 1;
      current = _current;
    } else {
      final list = data.data;
      final _current = data.currentIndex;
      current = _current;
      if (list != null) max = list.length - 1;
    }
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
