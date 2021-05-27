// import '../data/book_content.dart';
// import '../bloc/book_cache_bloc.dart';
// import 'package:sqlite3/sqlite3.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// import 'book_event.dart';

// abstract class BookDatabase implements DatabaseEvent{
//   late Database db;
//   String get dbname;

//   @override
//   Future<void> initState() async {
//     final path = await getApplicationDocumentsDirectory();

//     db = sqlite3.open(join(path.path, dbname));
//   }

//   @override
//   Future<int> deleteBook(int id) async{
//     db.execute('DELECT FROM BookInfos w')
//     return db.getUpdatedRows();
//   }

//   @override
//   Future<void> deleteCache(int bookId) {
//     // TODO: implement deleteCache
//     throw UnimplementedError();
//   }

//   @override
//   Future<Set<int>> getAllBookId() {
//     // TODO: implement getAllBookId
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Map<String, Object?>>> getCacheContentsDb(int bookid) {
//     // TODO: implement getCacheContentsDb
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Map<String, Object?>>> getContentDb(int bookid, int contentid) {
//     // TODO: implement getContentDb
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Map<String, Object?>>> getIndexsDb(int bookid) {
//     // TODO: implement getIndexsDb
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Map<String, Object?>>> getMainBookListDb() {
//     // TODO: implement getMainBookListDb
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> insertBook(BookCache bookCache) {
//     // TODO: implement insertBook
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> insertOrUpdateIndexs(int? id, String indexs) {
//     // TODO: implement insertOrUpdateIndexs
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> saveContent(BookContent bookContent) {
//     // TODO: implement saveContent
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateBookStatus(int id, int cid, int page) {
//     // TODO: implement updateBookStatus
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateBookStatusAndSetNew(int id, String cname, String updateTime) {
//     // TODO: implement updateBookStatusAndSetNew
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateBookStatusAndSetTop(int id, int isTop) {
//     // TODO: implement updateBookStatusAndSetTop
//     throw UnimplementedError();
//   }
// }
