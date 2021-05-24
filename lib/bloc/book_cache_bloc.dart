import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../event/event.dart';

class BookCache extends Equatable {
  BookCache({
    this.chapterId,
    this.img,
    this.lastChapter,
    this.name,
    this.updateTime,
    this.id,
    this.isTop,
    this.sortKey,
    this.isNew,
    this.page,
    this.isShow,
  });
  final String? name;
  final String? img;
  final String? updateTime;
  final String? lastChapter;
  final int? chapterId;
  final int? id;
  final int? sortKey;
  final int? isTop;
  final int? page;
  final int? isNew;
  final int? isShow;
  // BookCache copyWith(
  //     {String? name,
  //     String? img,
  //     String? updateTime,
  //     String? lastChapter,
  //     int? chapterId,
  //     int? id,
  //     int? sortKey,
  //     int? isTop,
  //     int? isNew,
  //     int? page}) {
  //   return BookCache(
  //       name: name ?? this.name,
  //       img: img ?? this.img,
  //       updateTime: updateTime ?? this.updateTime,
  //       lastChapter: lastChapter ?? this.lastChapter,
  //       chapterId: chapterId ?? this.chapterId,
  //       id: id ?? this.id,
  //       sortKey: sortKey ?? this.sortKey,
  //       isTop: isTop ?? this.isTop,
  //       isNew: isNew ?? this.isNew,
  //       page: page ?? this.page);
  // }

  factory BookCache.fromMap(Map<String, dynamic> map) {
    return BookCache(
      img: map['img'] as String?,
      updateTime: map['updateTime'] as String?,
      lastChapter: map['lastChapter'] as String?,
      chapterId: map['chapterId'] as int?,
      id: map['bookId'] as int?,
      name: map['name'] as String?,
      sortKey: map['sortKey'] as int?,
      isTop: map['isTop'] as int?,
      page: map['cPage'] as int?,
      isNew: map['isNew'] as int?,
      isShow: map['isShow'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        name,
        img,
        updateTime,
        lastChapter,
        chapterId,
        id,
        sortKey,
        isTop,
        page,
        isShow
      ];
}

abstract class BookChapterIdEvent extends Equatable {
  BookChapterIdEvent();
  @override
  List<Object?> get props => [];
}

class _BookCacheInnerEvent extends BookChapterIdEvent {}

class BookChapterIdFirstLoadEvent extends BookChapterIdEvent {}

class BookChapterIdState {
  BookChapterIdState({this.list = const [], this.first = false});
  List<Map> list;
  List<BookCache>? _sortChildren;
  List<BookCache> get sortChildren {
    var _bookCaches = <BookCache>[];
    if (_sortChildren != null) return _sortChildren!;

    if (list.isNotEmpty) {
      for (var bookCache in list) {
        _bookCaches.add(BookCache.fromMap(bookCache as Map<String, dynamic>));
      }
      _bookCaches.sort((p, n) => n.sortKey! - p.sortKey!);
      final isTop = _bookCaches.where((element) => element.isTop == 1);
      final custom = _bookCaches.where((element) => element.isTop != 1);
      _sortChildren = isTop.toList()..addAll(custom);
    } else {
      _sortChildren = <BookCache>[];
    }

    return _sortChildren!;
  }

  List<BookCache>? _showChildren;
  List<BookCache> get showChildren {
    final sort = sortChildren;

    _showChildren ??= sort.where((element) => element.isShow != 0).toList();

    return _showChildren!;
  }

  final bool first;
  factory BookChapterIdState.fromMap(List<Map> list) {
    return BookChapterIdState(list: list);
  }
}

class BookCacheBloc extends Bloc<BookChapterIdEvent, BookChapterIdState> {
  BookCacheBloc(this.repository) : super(BookChapterIdState(first: true));
  Repository repository;

  // 不在 [mapEventToState] 中处理异步，不然事件无法即时处理
  @override
  Stream<BookChapterIdState> mapEventToState(BookChapterIdEvent event) async* {
    if (event is BookChapterIdFirstLoadEvent) {
      // update(); // 正式版
      load();
    } else if (event is _BookCacheInnerEvent) {
      yield* _load();
    }
  }

  Completer<void>? loading;
  Future<void>? get awaitloading => loading?.future;

  void completerLoading() {
    if (loading != null && !loading!.isCompleted) {
      loading!.complete();
    }
  }

  Stream<BookChapterIdState> _load() async* {
    final list = await repository.databaseEvent.getMainBookListDb();
    yield BookChapterIdState.fromMap(list);
    completerLoading();
  }

  Future<void> _update() async {
    final list = await repository.databaseEvent.getMainBookListDb();
    if (list.isNotEmpty) {
      final s = BookChapterIdState.fromMap(list);
      for (var item in s.sortChildren) {
        await Future.delayed(Duration(milliseconds: 200));
        await loadFromNet(item.id!);
      }
    }
  }

  void emitUpdate() => add(_BookCacheInnerEvent());

  Future<void> load({bool update = false}) async {
    loading = Completer<void>();
    if (update) {
      await _update();
    }
    emitUpdate();
  }

  Future<void> addBook(BookCache bookCache) async {
    await repository.databaseEvent.insertBook(bookCache);
    emitUpdate();
  }

  Future<void> updateTop(int id, int isTop, {int isShow = 1}) async {
    await repository.databaseEvent.updateBookStatusAndSetTop(id, isTop, isShow);
    emitUpdate();
  }

  Future<void> deleteBook(int id) async {
    await repository.databaseEvent.deleteBook(id);
    emitUpdate();
  }

  Future<void> loadFromNet(int id) async {
    final rawData = await repository.customEvent.getInfo(id);
    final data = rawData.data;
    if (data != null) {
      final newCname = data.lastChapter;
      final lastTime = data.lastTime;
      if (newCname != null && lastTime != null) {
        return repository.databaseEvent
            .updateBookStatusAndSetNew(id, newCname, lastTime);
      }
    }
  }
}
