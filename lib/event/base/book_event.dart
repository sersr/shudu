import 'dart:async';
import 'dart:typed_data';

import 'package:nop/nop.dart';
import 'package:nop_annotations/nop_annotations.dart';

import '../../data/data.dart';
import '../../database/database.dart';
import '../../modules/book_list/views/cache_manager.dart';
import 'data.dart';
import 'server_event.dart';

export 'data.dart';
export 'server_event.dart';

part 'book_event.g.dart';

@NopServerEvent()
@NopServerEventItem(connectToServer: ['database'], serverName: 'book')
abstract mixin class BookEvent
    implements CustomEvent, DatabaseEvent, ComplexEvent {
  BookCacheEvent get bookCacheEvent => this;
  BookContentEvent get bookContentEvent => this;
  CustomEvent get customEvent => this;
  DatabaseEvent get databaseEvent => this;
  ComplexEvent get complexEvent => this;
}

abstract class BookContentEvent {
  Stream<List<BookContentDb>?> watchBookContentCid(int bookid);
  FutureOr<int?> deleteCache(int bookId);
}

abstract class BookCacheEvent {
  FutureOr<Option<List<BookCache>>> getMainList();
  Stream<List<BookCache>?> watchMainList();

  FutureOr<int?> updateBook(int id, BookCache book);
  FutureOr<int?> insertBook(BookCache bookCache);
  FutureOr<int?> deleteBook(int id);

  Stream<List<BookCache>?> watchCurrentCid(int id);
  FutureOr<List<CacheItem>?> getCacheItems();
}

@NopServerEventItem(serverName: 'database', separate: true)
abstract class DatabaseEvent
    implements BookCacheEvent, BookContentEvent, ServerEvent {}

abstract class CustomEvent implements ServerNetEvent {
  FutureOr<SearchList?> getSearchData(String key);

  @NopServerMethod(useTransferType: true)
  FutureOr<Uint8List?> getImageBytes(String img);

  FutureOr<List<BookList>?> getHiveShudanLists(String c);

  FutureOr<List<BookList>?> getShudanLists(String c, int index);
  FutureOr<BookTopData?> getTopLists(String c, String date, int index);
  FutureOr<BookTopData?> getCategLists(int c, String date, int index);

  FutureOr<BookListDetailData?> getShudanDetail(int index);
  FutureOr<List<BookCategoryData>?> getCategoryData();
}
