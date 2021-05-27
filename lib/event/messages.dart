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
  getContent,
}
enum DatabaseMessage {
  // database
  addBook,
  insertBookInfo,
  deleteBook,
  deleteCache,
  loadBookInfo,
  getCacheContentsDb,
  updateBookIsTop,
  updateCname,
  updateMainInfo,
  getIndexDb,
  getAllBookId,
  getCacheItem,
}

class IsolateSendMessage {
  IsolateSendMessage(this.type, this.args, this.messageId);
  final dynamic type;
  final dynamic args;
  final int messageId;
}

enum Result {
  success,
  failed,
  error,
}

class IsolateReceiveMessage {
  IsolateReceiveMessage(
      {required this.data,
      required this.messageId,
      this.result = Result.success});
  final int messageId;
  final dynamic data;
  final Result result;
}
