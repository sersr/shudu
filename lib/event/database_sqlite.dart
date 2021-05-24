// import '../moor/database.dart';
// import 'book_event.dart';
// import 'package:moor/moor.dart';
// import '../data/data.dart' as data;

// mixin BookDatabase implements DatabaseEvent {
//   Database get db;

//   @override
//   Future<int> deleteBook(int id) {
//     final d = db.delete(db.bookInfos)..where((book) => book.bookId.equals(id));
//     return d.go();
//   }

//   @override
//   Future<int> removeBook(int id) {
//     final u = db.update(db.bookInfos)..where((book) => book.id.equals(id));
//     return u.write(BookInfosCompanion(isShow: Value(false)));
//   }

//   @override
//   Future<int> deleteContents(int bookId) {
//     return (db.delete(db.bookContents)
//           ..where((tbl) => tbl.bookId.equals(bookId)))
//         .go();
//   }

//   @override
//   Future<List<int>> getAllBookId() {
//     return (db.select(db.bookInfos).map((info) => info.bookId)).get();
//   }

//   Future<List<BookInfo>> getAllBook() {
//     return db.select(db.bookInfos).get();
//   }

//   @override
//   Future<List<BookContent>> getCacheContentsDb(int bookid) {
//     return (db.select(db.bookContents)
//           ..where((book) => book.bookId.equals(bookid)))
//         .get();
//   }

//   @override
//   Future<data.BookContent> getContentDb(int bookid, int contentid) async {
//     // final query = db.select(db.bookContents)
//     //   ..where((tbl) =>
//     //       tbl.bookId.equals(bookid).equalsExp(tbl.cid.equals(contentid)));
//     // return query.getSingle();
//     final query = db.customSelect(
//         'SELECT * AS c FROM bookContents WHERE bookId = ? AND cid = ?',
//         variables: [Variable.withInt(bookid), Variable(contentid)],
//         readsFrom: {db.bookContents});
//     final row = await query.getSingleOrNull();
//     if (row == null) return const data.BookContent();
//     return data.BookContent.fromJson(row.data);
//   }

//   // @override
//   // Future<List<Map<String, Object?>>> getIndexsDb(int bookid) {
//   //   final query = db.customSelect('SELECT * AS i FROM BookIndexs')
//   // }

//   @override
//   Future<List<Map<String, Object?>>> getMainBookListDb() {
//     // TODO: implement getMainBookListDb
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> initState() {
//     // TODO: implement initState
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
//   Future<void> updateBookStatusAndSetNew(
//       int id, String cname, String updateTime) {
//     // TODO: implement updateBookStatusAndSetNew
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateBookStatusAndSetTop(int id, int isTop) {
//     // TODO: implement updateBookStatusAndSetTop
//     throw UnimplementedError();
//   }
// }
