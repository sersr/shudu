
import 'dart:isolate';

enum CustomMessage {
  info,
  shudanDetail,
  indexs,
  content,
  shudan,
  bookList,
  mainList,
  restartClient,
  searchWithKey,
  saveImage,
  divText,
  getContent,
}
enum DatabaseMessage {
  // database
  addBook,
  cacheinnerdb,
  deleteBook,
  deleteCache,
  loadBookInfo,
  getCacheContentsDb,
  updateBookIsTop,
  updateCname,
  updateMainInfo,
  getIndexDb,
  getAllBookId,
}

class IsolateSendMessage {
  IsolateSendMessage(this.type, this.args, this.sp);
  final dynamic type;
  final dynamic args;
  final SendPort sp;
}

enum Result {
  success,
  failed,
  error,
}

class IsolateReceiveMessage {
  IsolateReceiveMessage({required this.data, this.result = Result.success});
  final dynamic data;
  final Result result;
}