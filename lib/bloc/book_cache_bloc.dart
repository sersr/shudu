import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/nop_database.dart';
import '../event/event.dart';

abstract class BookChapterIdEvent extends Equatable {
  const BookChapterIdEvent();
  @override
  List<Object?> get props => [];
}

class _BookCacheInnerEvent extends BookChapterIdEvent {
  const _BookCacheInnerEvent();
}

class BookChapterIdFirstLoadEvent extends BookChapterIdEvent {}

class BookChapterIdState {
  BookChapterIdState({this.list = const [], this.first = false});
  List<BookCache> list;
  List<BookCache>? _sortChildren;
  List<BookCache> get sortChildren {
    var _bookCaches = list;
    if (_sortChildren != null) return _sortChildren!;

    if (list.isNotEmpty) {
      _bookCaches.sort((p, n) => n.sortKey! - p.sortKey!);
      final isTop = _bookCaches.where((element) => element.isTop == true);
      final custom = _bookCaches.where((element) => element.isTop != true);
      _sortChildren = isTop.toList()..addAll(custom);
    } else {
      _sortChildren = <BookCache>[];
    }

    return _sortChildren!;
  }

  List<BookCache>? _showChildren;
  List<BookCache> get showChildren {
    final sort = sortChildren;

    _showChildren ??= sort.where((element) => element.isShow == true).toList();

    return _showChildren!;
  }

  final bool first;
  factory BookChapterIdState.fromMap(List<BookCache> list) {
    return BookChapterIdState(list: list);
  }
}

class BookCacheBloc extends Bloc<BookChapterIdEvent, BookChapterIdState> {
  BookCacheBloc(this.repository) : super(BookChapterIdState(first: true));
  Repository repository;

  @override
  Stream<BookChapterIdState> mapEventToState(BookChapterIdEvent event) async* {
    if (event is BookChapterIdFirstLoadEvent) {
      load();
      // _cacheSub ??= repository.bookEvent.bookCacheEvent
      //     .watchMainBookListDb()
      //     .listen(_listen);
    } else if (event is _BookCacheInnerEvent) {
      yield* _load();
    }
  }

  // StreamSubscription? _cacheSub;

  // void cancel() {
  //   _cacheSub?.cancel();
  //   _cacheSub = null;
  // }

  // void get pause => _cacheSub?.pause();

  // var _cacheList = <BookCache>[];

  // Completer? _receive;
  // void _listen(List<BookCache>? data) {
  //   if (data == null) return;
  //   if (_cacheList.isEmpty && data.isNotEmpty)
  //     add(const _BookCacheInnerEvent());

  //   _cacheList = data;
  //   _receive?.complete();
  //   _receive = null;
  //   Log.e('_main list listen');
  // }

  Completer<void>? loading;
  Future<void>? get awaitloading => loading?.future;

  void completerLoading() {
    if (loading != null && !loading!.isCompleted) {
      loading!.complete();
    }
  }

  FutureOr<List<BookCache>> get getList async {
    return await repository.bookEvent.bookCacheEvent.getMainBookListDb() ??
        const [];
  }

  Stream<BookChapterIdState> _load() async* {
    yield BookChapterIdState.fromMap(await getList);
    completerLoading();
  }

  Future<void> _update() async {
    final list = await getList;
    if (list.isNotEmpty) {
      final s = BookChapterIdState.fromMap(list);
      for (var item in s.sortChildren) {
        await Future.delayed(Duration(milliseconds: 200));
        await loadFromNet(item.bookId!);
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
    await repository.bookEvent.bookCacheEvent.insertBook(bookCache);
  }

  Future<void> updateTop(int id, bool isTop, {bool isShow = true}) async {
    // _receive ??= Completer<void>()..future.whenComplete(emitUpdate);
    await repository.bookEvent.bookCacheEvent
        .updateBookStatusAndSetTop(id, isTop, isShow);
    emitUpdate();
  }

  Future<void> deleteBook(int id) async {
    // _receive ??= Completer<void>()..future.whenComplete(emitUpdate);

    await repository.bookEvent.bookCacheEvent.deleteBook(id);
    emitUpdate();
  }

  Future<int> loadFromNet(int id) async {
    return await repository.bookEvent.updateBookStatus(id) ?? 0;
  }
}
