import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../data/data.dart';
import '../../database/database.dart';
import 'book_event.dart';

// export
abstract class ComplexEvent {
  FutureOr<RawContentLines?> getContent(int bookid, int contentid, bool update);
  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update);
  FutureOr<BookInfoRoot?> getInfo(int id);
}

abstract class ServerEvent {
  @protected
  FutureOr<RawContentLines?> getContentDb(int bookid, int contentid);
  @protected
  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs);
  @protected
  FutureOr<List<BookIndex>?> getIndexsDb(int bookid);
  @protected
  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb);
  @protected
  FutureOr<int?> insertOrUpdateBook(BookInfo data);
}

abstract class ServerNetEvent {
  @protected
  FutureOr<BookContentDb?> getContentNet(int bookid, int contentid);
  @protected
  FutureOr<BookInfoRoot?> getInfoNet(int id);
  @protected
  FutureOr<String?> getIndexsNet(int id);
}
