import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'book_repository.dart';

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
    );
  }

  @override
  List<Object?> get props => [name, img, updateTime, lastChapter, chapterId, id, sortKey, isTop, page];
}

abstract class BookChapterIdEvent extends Equatable {
  BookChapterIdEvent();
  @override
  List<Object?> get props => [];
}

// class BookChapterSaveEvent extends BookChapterIdEvent {}

class BookChapterIdAddEvent extends BookChapterIdEvent {
  BookChapterIdAddEvent({required this.bookCache});
  final BookCache bookCache;

  @override
  List<Object?> get props => [bookCache];
}

class BookChapterIdDeleteEvent extends BookChapterIdEvent {
  BookChapterIdDeleteEvent({required this.id});
  final int id;
}

class BookChapterIdLoadEvent extends BookChapterIdEvent {
  BookChapterIdLoadEvent({this.load = false});
  final bool load;
  @override
  List<Object> get props => [load];
}

class BookChapterIdIsTopEvent extends BookChapterIdEvent {
  BookChapterIdIsTopEvent({required this.isTop, required this.id});
  final int isTop;
  final int id;
  @override
  List<Object?> get props => [isTop, id];
}

class BookChapterIdFirstLoadEvent extends BookChapterIdEvent {}

class BookChapterIdState {
  BookChapterIdState({this.sortChildren = const [], this.first = false});
  final List<BookCache> sortChildren;
  final bool first;
  factory BookChapterIdState.fromMap(List<Map> list) {
    var _bookCaches = <BookCache>[];
    for (var bookCache in list) {
      _bookCaches.add(BookCache.fromMap(bookCache as Map<String, dynamic>));
    }
    _bookCaches.sort((p, n) => n.sortKey! - p.sortKey!);
    final isTop = _bookCaches.where((element) => element.isTop == 1);
    final custom = _bookCaches.where((element) => element.isTop != 1);
    return BookChapterIdState(sortChildren: isTop.toList()..addAll(custom));
  }
}

class BookCacheBloc extends Bloc<BookChapterIdEvent, BookChapterIdState> {
  BookCacheBloc(this.repository) : super(BookChapterIdState(first: true));
  BookRepository repository;

  @override
  Stream<BookChapterIdState> mapEventToState(BookChapterIdEvent event) async* {
    if (event is BookChapterIdFirstLoadEvent) {
      await repository.initState();
      yield* loadForView(/* load: true */);
    } else if (event is BookChapterIdLoadEvent) {
      yield* loadForView(load: event.load);
    } else if (event is BookChapterIdAddEvent) {
      yield* addBook(event);
    } else if (event is BookChapterIdDeleteEvent) {
      await deleteBook(event);
    } else if (event is BookChapterIdIsTopEvent) {
      repository.innerdb.updateBookIsTop(event.id, event.isTop);
    }
  }

  Completer<void>? loading;

  void completerLoading() {
    if (loading != null && !loading!.isCompleted) {
      loading!.complete();
    }
  }

  Stream<BookChapterIdState> loadForView({bool load = false}) async* {
    // await save();
    var list = <Map<String, dynamic>>[];
    list = await repository.innerdb.db.rawQuery('SELECT * FROM BookInfo');
    if (list.isNotEmpty) {
      final s = BookChapterIdState.fromMap(list);
      yield s;
      if (load) {
        for (var item in s.sortChildren) {
          await Future.delayed(Duration(milliseconds: 200));
          await loadFromNet(item.id!);
        }
        list = await repository.innerdb.db.rawQuery('SELECT * FROM BookInfo');
      }
    }
    yield BookChapterIdState.fromMap(list);
    completerLoading();
  }

  Future<void> loadFromNet(int id) async {
    final rawData = await repository.loadInfo(id);
    final data = rawData.data;
    if (data != null) {
      final newCname = data.lastChapter;
      final lastTime = data.lastTime;
      if (newCname != null && lastTime != null) {
        await repository.innerdb.updateCname(id, newCname, lastTime);
      }
    }
  }

  Stream<BookChapterIdState> addBook(BookChapterIdAddEvent event) async* {
    int? count = 0;
    final bookcache = event.bookCache;
    count = Sqflite.firstIntValue(
        await repository.innerdb.db.rawQuery('SELECT COUNT(*) FROM BookInfo where bookid = ?', [bookcache.id]));
    if (count == 0) {
      await repository.innerdb.db.rawInsert(
        'INSERT INTO BookInfo(name, bookId, chapterId, img, updateTime, lastChapter, sortKey, isTop,cPage,isNew)'
        ' VALUES(?,?,?,?,?,?,?,?,?,?)',
        [
          bookcache.name,
          bookcache.id,
          bookcache.chapterId,
          bookcache.img,
          bookcache.updateTime,
          bookcache.lastChapter,
          bookcache.sortKey,
          bookcache.isTop,
          bookcache.page,
          bookcache.isNew,
        ],
      );
    }
    yield* loadForView();
  }

  Future<void> deleteBook(BookChapterIdDeleteEvent event) async {
    await repository.innerdb.db.rawDelete('DELETE FROM BookInfo WHERE bookId = ?', [event.id]);
  }
}
