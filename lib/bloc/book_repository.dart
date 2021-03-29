import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:battery/battery.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../api/api.dart';
import '../data/search_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/book_content.dart';
import '../data/book_index.dart';
import '../data/book_info.dart';
import '../data/book_list.dart';
import '../data/book_list_detail.dart';
import '../utils/utils.dart';
import 'book_index_bloc.dart';

class BookRepository {
  BookRepository(this.afterInitCallback);

  late String dataPath;
  late InnerDatabase innerdb;
  late String appPath;
  late Box<int> imageUpdate;

  ValueNotifier<bool> get init => _init;
  final _init = ValueNotifier<bool>(false);

  final VoidCallback afterInitCallback;

  late ReceivePort clientRP;
  late SendPort clientSP;
  late Isolate _isolate;
  final client = dioCreater();
  @mustCallSuper
  Future<void> initState() async {
    appPath = (await getApplicationDocumentsDirectory()).path;
    Hive.init('$appPath/shudu/hive');
    imageUpdate = await Hive.openBox<int>('imageUpdate');
    final d = Directory('$appPath/shudu/images');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }

    await getBatteryLevel();

    clientRP = ReceivePort();
    _isolate = await Isolate.spawn(_isolateRe, [clientRP.sendPort, appPath]);
    clientSP = await clientRP.first;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
        innerdb = InnerDatabaseImpl();
        break;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        innerdb = InnerDatabaseWinImpl();
        break;
    }
    await innerdb.initState();
    afterInit();
  }

  // 启动app时等待初始化完成
  Future<void> afterInit() async {
    _init.value = true;
    await afterInitCallback();
  }

  void dipose() {
    client.close();
    clientRP.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  Future<SearchList> searchWithKey(String? key) async {
    var url = Api.searchUrl(key!);
    try {
      var respone = await client.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      Map<String, dynamic> map = jsonDecode(utf8.decode(respone.data!));
      return SearchList.fromJson(map);
    } catch (e) {
      return Future.value();
    }
  }

  /// 目录
  Future<String> getIndexsFromNet(int id) async {
    final url = Api.indexUrl(id);
    return await sendMessage<String>(MessageType.indexs, url);
  }

  Future<T> sendMessage<T extends Object>(MessageType type, dynamic arg) async {
    final port = ReceivePort();
    clientSP.send(IsolateSendMessage(type, arg, port.sendPort));
    final result = (await port.first) as IsolateReceiveMessage;
    return result.data;
  }

  /// 章节内容
  Future<BookContent> getContentFromNet(int id, int? cid) async {
    final url = Api.contentUrl(id, cid);
    return await sendMessage<BookContent>(MessageType.content, url);
  }

  static const int oneWeek = 1000 * 60 * 60 * 24 * 7;
  static const int thirtySeconds = 1000 * 30;
  // var inLocal = <String>[];
  String get imageLocalPath => '$appPath/shudu/images/';
  var errorLoading = <String>[];
  int time = 0;
  Future<String> saveImage(String img) async {
    var imgName = '';
    String url;
    if (img.startsWith(RegExp(r'https://|http://'))) {
      var reurl = img.replaceAll('%2F', '/');
      final splist = reurl.split('/');
      for (var i = splist.length - 1; i >= 0; i--) {
        if (splist[i].isNotEmpty) {
          imgName = splist[i];
          break;
        }
      }
      url = img;
    } else {
      url = Api.imageUrl(img);
      imgName = img;
    }
    final imgPath = '$imageLocalPath$imgName';
    final imgdateTime = imageUpdate.get(imgName.hashCode);
    final shouldUpdate = imgdateTime == null ? true : imgdateTime + oneWeek < DateTime.now().millisecondsSinceEpoch;
    if (!shouldUpdate) {
      return imgPath;
    }

    if (errorLoading.contains(imgName)) {
      if (time + thirtySeconds <= DateTime.now().millisecondsSinceEpoch) {
        time = DateTime.now().millisecondsSinceEpoch;
        // 再次发送网络请求
        errorLoading.remove(imgName);
      } else {
        return '${imageLocalPath}guizhenwuji.jpg';
      }
    }

    try {
      var respone = await client.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      // 验证是否为图片格式
      final buffer = await ImmutableBuffer.fromUint8List(Uint8List.fromList(respone.data!));
      await ImageDescriptor.encoded(buffer);
      errorLoading.remove(imgName);
      await imageUpdate.put(imgName.hashCode, DateTime.now().millisecondsSinceEpoch);
      await File(imgPath).writeAsBytes(respone.data!);
    } catch (e) {
      assert(Log.i('$imgName, $e !!!'));
      // 本地已经存在资源；
      // 网络请求出现错误，使用本地资源（旧图片）
      // if (imgdateTime == null) {
      //   errorLoading.add(imgName);
      //   return '${imageLocalPath}guizhenwuji.jpg';
      // }
    }
    // success
    return imgPath;
  }

  Future<List<List>> loadIndexsList(String str) async {
    return await sendMessage<List<List>>(MessageType.mainList, str);
  }

  Future<BookInfoRoot> loadInfo(int id) async {
    final url = Api.infoUrl(id);
    return await sendMessage<BookInfoRoot>(MessageType.info, url);
  }

  Future<List<BookList>> getBookList(String c) async {
    return await sendMessage<List<BookList>>(MessageType.bookList, c);
  }

  Future<List<BookList>> loadShudan(String c, int index) async {
    return await sendMessage<List<BookList>>(MessageType.shudan, [c, index]);
  }

  Future<BookListDetailData> loadShudanDetail(int? index) async {
    final url = Api.shudanDetailUrl(index);
    return await sendMessage(MessageType.shudanDetail, url);
  }

  Future<void> restartClient() async {
    await sendMessage(MessageType.restartClient, '');
  }

  Battery? _battery;
  int level = 50;

  Future<int> getBatteryLevel() async {
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      _battery ??= Battery();
      final _level = await _battery!.batteryLevel;
      level = _level;
    }
    return level;
  }
}

abstract class InnerDatabase {
  late Database db;
  late String dataPath;
  Future<void> initState();

  /// isNew == 1
  Future<void> updateCname(int id, String cname, String updateTime) async {
    final _ocname = await db.rawQuery('SELECT lastChapter from BookInfo where bookId = ?', [id]);
    if (_ocname.isNotEmpty) {
      if (_ocname.first['lastChapter'] != cname) {
        await db.rawUpdate('update BookInfo set lastChapter = ?, isNew = ?, updateTime = ? where bookId = ?',
            [cname, 1, updateTime, id]);
      }
    }
  }

  Future<void> onCreate(Database _db, int version) async {
    await _db.execute('CREATE TABLE BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId INTEGER, chapterId INTEGER,'
        'img TEXT, updateTime TEXT, lastChapter TEXT, sortKey INTEGER, isTop INTEGER, cPage INTEGER, isNew INTEGER)');
    await _db.execute('CREATE TABLE BookContent (id INTEGER PRIMARY KEY, bookId INTEGER, cid INTEGER, cname TEXT,'
        'nid INTEGER, pid INTEGER, content TEXT, hasContent INTEGER)');
    await _db.execute('CREATE TABLE BookIndex (id INTEGER PRIMARY KEY, bookId INTEGER,bIndexs TEXT)');
  }

  /// isNew == 0
  Future<void> updateMainInfo(int id, int cid, int page) async {
    await db.rawUpdate('update BookInfo set chapterId = ?, cPage = ?, isNew = ?,sortKey = ? where bookId = ?',
        [cid, page, 0, DateTime.now().millisecondsSinceEpoch, id]);
  }

  void updateBookIsTop(int id, int isTop) async {
    await db.rawUpdate('update BookInfo set isTop = ?,sortKey = ?  where bookId = ?',
        [isTop, DateTime.now().millisecondsSinceEpoch, id]);
  }
}

class InnerDatabaseImpl extends InnerDatabase {
  InnerDatabaseImpl();
  @override
  String dataPath = 'book_view_cache.db';

  @override
  Future<void> initState() async {
    db = await openDatabase(dataPath, version: 1, onCreate: onCreate);
    // await db.execute('ALTER TABLE BookContent ADD COLUMN hasContent INTEGER');
  }
}

class InnerDatabaseWinImpl extends InnerDatabase {
  InnerDatabaseWinImpl() {
    sqfliteFfiInit();
  }

  @override
  String dataPath = 'book_view_cache_test.db';
  @override
  Future<void> initState() async {
    db = await databaseFactoryFfi.openDatabase(dataPath, options: OpenDatabaseOptions(version: 1, onCreate: onCreate));
    // await db.execute('ALTER TABLE BookContent ADD COLUMN hasContent INTEGER');
    // await db.rawDelete(
    //   'DELETE FROM BookContent WHERE bookId = ?',
    //   [445578],
    // );
  }
}

enum MessageType {
  info,
  shudanDetail,
  indexs,
  content,
  shudan,
  bookList,
  mainList,
  restartClient,
}

class MessageFunc {
  static Future<void> mainList(dynamic m) async {
    var bookIndexShort = <List>[];
    try {
      final map = BookIndexRoot.fromJson(jsonDecode(m.arg)).data!;
      for (var bookVol in map.list!) {
        final _inl = <dynamic>[bookVol.name];
        for (var bookChapter in bookVol.list!) {
          _inl.add(BookIndexShort(map.name, bookChapter.name, bookChapter.id));
        }
        bookIndexShort.add(_inl);
      }
      m.sp.send(IsolateReceiveMessage(data: bookIndexShort, result: Result.success));
    } catch (e) {
      Log.e('url:${m.arg}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: bookIndexShort, result: Result.success));
    }
  }

  static Future<void> bookList(dynamic m) async {
    final String c = m.arg;
    String? data;
    final box = await Hive.openBox('shudanlist');
    if (box.isOpen) {
      switch (c) {
        case 'new':
          data = box.get('shudanNewList');
          break;
        case 'hot':
          data = box.get('shudanHotList');
          break;
        case 'collect':
          data = box.get('shudanCollectList');
          break;
      }
    }
    await box.close();
    if (data == null) {
      m.sp.send(IsolateReceiveMessage(data: <BookList>[], result: Result.error));
    } else {
      try {
        m.sp.send(IsolateReceiveMessage(data: BookListRoot.fromJson(jsonDecode(data)).data, result: Result.success));
      } catch (e) {
        Log.e('url:${m.arg}, $e', name: '_isolate');
        m.sp.send(IsolateReceiveMessage(data: <BookList>[], result: Result.error));
      }
    }
  }

  static Future<void> info(dynamic m, Dio client) async {
    try {
      var respone = await client.get<String>(m.arg);
      Map<String, dynamic> map = jsonDecode(respone.data!);
      m.sp.send(IsolateReceiveMessage(data: BookInfoRoot.fromJson(map), result: Result.success));
    } catch (e) {
      Log.e('url:${m.arg}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: BookInfoRoot(), result: Result.error));
    }
  }

  static Future<void> shudanDetail(dynamic m, Dio client) async {
    try {
      var respone = await client.get<String>(m.arg);
      Map<String, dynamic> map = jsonDecode(respone.data!);
      m.sp.send(IsolateReceiveMessage(data: BookListDetailRoot.fromJson(map).data, result: Result.success));
    } catch (e) {
      Log.e('url:${m.arg}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: BookListDetailData(), result: Result.error));
    }
  }

  static Future<void> indexs(dynamic m, Dio client) async {
    try {
      var respone = await client.get<String>(m.arg);
      m.sp.send(IsolateReceiveMessage(data: respone.data!.replaceAll('},]', '}]'), result: Result.success));
    } catch (e) {
      Log.e('url:${m.arg}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: '', result: Result.error));
    }
  }

  static Future<void> content(dynamic m, Dio client) async {
    try {
      var respone = await client.get<String>(m.arg);
      m.sp.send(IsolateReceiveMessage(
          data: BookContentRoot.fromJson(jsonDecode(respone.data!)).data, result: Result.success));
    } catch (e) {
      Log.e('url:${m.arg}, $e', name: '_isolate');

      m.sp.send(IsolateReceiveMessage(data: BookContent(), result: Result.error));
    }
  }

  static Future<void> shudan(dynamic m, Dio client) async {
    try {
      final String c = m.arg[0];
      final int index = m.arg[1];
      var respone = await client.get<String>(Api.shudanUrl(c, index));
      final data = respone.data!;
      m.sp.send(IsolateReceiveMessage(
          data: BookListRoot.fromJson(jsonDecode(data)).data ?? <BookList>[], result: Result.success));
      if (index == 1) {
        final box = await Hive.openBox('shudanlist');
        switch (c) {
          case 'new':
            await box.put('shudanNewList', data);
            break;
          case 'hot':
            await box.put('shudanHotList', data);
            break;
          case 'collect':
            await box.put('shudanCollectList', data);
            break;
        }
        await box.close();
      }
    } catch (e) {
      Log.e('url:${m.arg}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: <BookList>[], result: Result.error));
    }
  }
}

class IsolateSendMessage {
  IsolateSendMessage(this.type, this.arg, this.sp);
  final MessageType type;
  final dynamic arg;
  final SendPort sp;
}

enum Result {
  success,
  failed,
  error,
}

class IsolateReceiveMessage {
  IsolateReceiveMessage({required this.data, required this.result});
  final dynamic data;
  final Result result;
}

void _isolateRe(List args) async {
  assert(() {
    // Bloc.observer = SimpleBlocObserver();
    Log.enablePrint = (stage) {
      return true;
    };
    return true;
  }());
  final port = args[0];
  final appPath = '${args[1]}/shudu';
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);
  Hive.init(appPath + '/hive');
  var client = dioCreater();

  receivePort.listen(
    (m) async {
      if (m is IsolateSendMessage) {
        switch (m.type) {
          case MessageType.info:
            MessageFunc.info(m, client);
            break;
          case MessageType.shudanDetail:
            MessageFunc.shudanDetail(m, client);
            break;
          case MessageType.indexs:
            MessageFunc.indexs(m, client);
            break;
          case MessageType.content:
            MessageFunc.content(m, client);
            break;
          case MessageType.shudan:
            MessageFunc.shudan(m, client);
            break;
          case MessageType.bookList:
            MessageFunc.bookList(m);
            break;
          case MessageType.mainList:
            MessageFunc.mainList(m);
            break;
          case MessageType.restartClient:
            client.close();
            client = dioCreater();
            m.sp.send(IsolateReceiveMessage(data: '', result: Result.success));
            break;
          default:
            m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
        }
      }
    },
  );
}

Dio dioCreater() => Dio(BaseOptions(connectTimeout: 5000, sendTimeout: 5000, receiveTimeout: 10000));
