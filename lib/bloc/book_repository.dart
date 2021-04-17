import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../api/api.dart';
import '../data/book_content.dart';
import '../data/book_index.dart';
import '../data/book_info.dart';
import '../data/book_list.dart';
import '../data/book_list_detail.dart';
import '../data/search_data.dart';
import '../utils/utils.dart';
import 'bloc.dart';
import 'book_cache_bloc.dart';
import 'book_index_bloc.dart';

/// 抽象，便于测试
abstract class Repository {
  Repository();

  String get dataPath;
  InnerDatabase get innerdb;
  String get appPath;
  Box<int> get imageUpdate;

  void addInitCallback(Future<void> Function() callback);
  Future<void> initState();
  void dipose();

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= _BookRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  Future<String> saveImage(String img);
  Future<String> getImageFromNet(String img);

  Future<T> sendMessage<T extends Object>(MessageType type, dynamic args);
  Future<SearchList> searchWithKey(String? key) async {
    var url = Api.searchUrl(key!);
    return sendMessage(MessageType.searchWithKey, url);
  }

  /// 目录
  Future<String> getIndexsFromNet(int id) async {
    final url = Api.indexUrl(id);
    return sendMessage<String>(MessageType.indexs, url);
  }

  /// 章节内容
  Future<BookContent> getContentFromNet(int id, int? cid) async {
    final url = Api.contentUrl(id, cid);
    print(url);
    // 切换源
    Api.moveNext();
    return sendMessage<BookContent>(MessageType.content, url);
  }

  Future<List<List>> loadIndexsList(String str) async {
    return sendMessage<List<List>>(MessageType.mainList, str);
  }

  Future<BookInfoRoot> loadInfo(int id) async {
    final url = Api.infoUrl(id);
    return sendMessage<BookInfoRoot>(MessageType.info, url);
  }

  Future<List<BookList>> getBookList(String c) async {
    return sendMessage<List<BookList>>(MessageType.bookList, c);
  }

  Future<List<BookList>> loadShudan(String c, int index) async {
    return sendMessage<List<BookList>>(MessageType.shudan, [Api.shudanUrl(c, index), index]);
  }

  Future<BookListDetailData> loadShudanDetail(int? index) async {
    final url = Api.shudanDetailUrl(index);
    return sendMessage(MessageType.shudanDetail, url);
  }

  Future<void> restartClient() async {
    await sendMessage(MessageType.restartClient, '');
  }

  // default
  ViewInsets get viewInsets => ViewInsets.zero;
  Future<ViewInsets> getViewInsets();
  int get bottomHeight;

  int level = 50;
  Future<int> getBatteryLevel() async => level;

  Future<double> setRate(double rate);
}

class _BookRepository extends Repository {
  @override
  late String dataPath;
  @override
  late InnerDatabase innerdb;
  @override
  late String appPath;
  @override
  late Box<int> imageUpdate;

  final _initCallbacks = <Future<void> Function()>[];
  @override
  void addInitCallback(Future<void> Function() callback) {
    if (_initCallbacks.contains(callback)) return;
    _initCallbacks.add(callback);
  }

  late ReceivePort clientRP;
  late SendPort clientSP;
  late Isolate _isolate;
  final client = dioCreater();

  var _init = false;

  @override
  Future<void> initState() async {
    if (_init) {
      assert(Log.w('已经初始化了', stage: this, name: 'initState'));
      return;
    }
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    final _futures = <Future>{};

    _futures.add(Future(() async {
      final _secF = <Future>{};

      appPath = (await getApplicationDocumentsDirectory()).path;
      Hive.registerAdapter(ColorAdapter());
      Hive.registerAdapter(AxisAdapter());
      Hive.registerAdapter(TargetPlatformAdapter());
      Hive.registerAdapter(PageBuilderAdapter());

      Hive.init('$appPath/shudu/hive');
      // await Hive.initFlutter();
      final _minitCallbacks = List.of(_initCallbacks);
      _initCallbacks.clear();
      _minitCallbacks.forEach((callback) {
        _secF.add(callback());
      });
      final d = Directory('$appPath/shudu/images');
      _secF.add(Future(() async {
        imageUpdate = await Hive.openBox<int>('imageUpdate');
        final exits = await d.exists();
        if (imageUpdate.get('_version_', defaultValue: -1) == -1) {
          await imageUpdate.deleteFromDisk();
          imageUpdate = await Hive.openBox<int>('imageUpdate');
          await imageUpdate.put('_version_', 1);
          if (exits) await d.delete(recursive: true);
        }
        if (!await d.exists()) {
          await d.create(recursive: true);
        }
      }));
      _secF.add(Future(() async {
        clientRP = ReceivePort();
        _isolate = await Isolate.spawn(_isolateRe, [clientRP.sendPort, appPath]);
        clientSP = await clientRP.first;
      }));
      await Future.wait(_secF);
    }));

    _futures.add(getBatteryLevel());
    _futures.add(getViewInsets());

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
      default:
        assert(false, 'Not yet implemented');
    }
    _futures.add(innerdb.initState());
    await Future.wait(_futures);
    _init = true;
  }

  @override
  void dipose() {
    client.close();
    clientRP.close();
    _isolate.kill(priority: Isolate.immediate);
    _init = false;
  }

  static const int threeDays = 1000 * 60 * 60 * 24 * 3;
  static const int thirtySeconds = 1000 * 30;

  String get imageLocalPath => '$appPath/shudu/images/';

  List<String> imageUrlResolve(String img) {
    var imgName = '';
    String url;
    if (img.startsWith(RegExp('https://|http://'))) {
      final splist = img.split(RegExp('/|%2F'));
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
    return [url, '${url.hashCode}_$imgName'];
  }

  @override
  Future<String> saveImage(String img) async {
    final imgResolve = imageUrlResolve(img);
    final imgName = imgResolve[1];

    final imgPath = '$imageLocalPath$imgName';
    final imgdateTime = imageUpdate.get(imgName.hashCode);
    final shouldUpdate = imgdateTime == null ? true : imgdateTime + threeDays < DateTime.now().millisecondsSinceEpoch;

    if (!shouldUpdate) {
      return imgPath;
    }

    return getImageFromNet(img);
  }

  final errorLoading = <String, int>{};

  @override
  Future<String> getImageFromNet(String img) async {
    final imgResolve = imageUrlResolve(img);
    final url = imgResolve[0];
    final imgName = imgResolve[1];

    final imgPath = '$imageLocalPath$imgName';

    // 避免太过频繁访问网络
    if (errorLoading.containsKey(imgName)) {
      final time = errorLoading[imgName]!;
      if (time + thirtySeconds <= DateTime.now().millisecondsSinceEpoch) {
        // 再次发送网络请求
        errorLoading.remove(imgName);
      } else {
        // 由于没有内置的错误图片，暂时的解决方案
        if (img != 'guizhenwuji.jpg') {
          return saveImage('guizhenwuji.jpg');
        }
        return imgPath;
      }
    }
    var success = false;
    try {
      await client.download(url, (Headers header) {
        final contentType = header.value(HttpHeaders.contentTypeHeader);
        if (contentType != null && contentType.contains(RegExp('image/*'))) {
          success = true;
          print('..图片识别正确..$imgName');
        } else {
          success = false;
          print('..可能不是图片..');
        }
        return imgPath;
      });
      if (success) {
        errorLoading.remove(imgName);
        await imageUpdate.put(imgName.hashCode, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      errorLoading[imgName] = DateTime.now().millisecondsSinceEpoch;
      assert(Log.i('$imgName, $e !!!'));
    }
    final exits = await File(imgPath).exists();
    if (!success) {
      // 只有在下载错误的时候才需要删除
      if (imageUpdate.get(imgName.hashCode) != null && !exits) {
        await imageUpdate.delete(imgName.hashCode);
      }
    }
    if (!exits && img != 'guizhenwuji.jpg') {
      return saveImage('guizhenwuji.jpg');
    }
    // 不管成功与否，都要返回路径
    // 即使是错误路径
    return imgPath;
  }

  @override
  Future<T> sendMessage<T extends Object>(MessageType type, dynamic args) async {
    final port = ReceivePort();
    clientSP.send(IsolateSendMessage(type, args, port.sendPort));
    final result = (await port.first) as IsolateReceiveMessage;
    if (result.result == Result.failed) {
      assert(Log.e('返回错误：${result.data}', stage: this, name: 'sendMessage'));
    } else if (result.result == Result.error) {
      Api.moveNext();
      // restartClient();
    }
    port.close();
    return result.data;
  }

  Battery? _battery;
  ViewInsets _viewInsets = ViewInsets.zero;
  @override
  ViewInsets get viewInsets => _viewInsets;

  var _bottomHeight = 0;
  @override
  int get bottomHeight => _bottomHeight;

  @override
  Future<ViewInsets> getViewInsets() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final viewInsets = await Bangs.safePadding;
      _viewInsets = viewInsets;
      _bottomHeight = await Bangs.bottomHeight ~/ window.devicePixelRatio;

      assert(Log.i('bottomHeight: $_bottomHeight'));
    }
    return _viewInsets;
  }

  @override
  Future<int> getBatteryLevel() async {
    _battery ??= Battery();
    var deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      // var androidInfo = await deviceInfo.androidInfo;
      level = await _battery!.batteryLevel;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      var iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return level;
      }
      level = await _battery!.batteryLevel;
    }

    return level;
  }

  @override
  Future<double> setRate(double rate) async {
    // final _real = await Bangs.setRate(rate);
    // print('rate: return $_real, send: $rate');
    return rate;
  }
}

abstract class InnerDatabase {
  late Database _db;
  late String dataPath;
  Future<void> initState();

  Future<void> onCreate(Database _db, int version) async {
    await _db.execute('CREATE TABLE BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId INTEGER, chapterId INTEGER,'
        'img TEXT, updateTime TEXT, lastChapter TEXT, sortKey INTEGER, isTop INTEGER, cPage INTEGER, isNew INTEGER)');
    await _db.execute('CREATE TABLE BookContent (id INTEGER PRIMARY KEY, bookId INTEGER, cid INTEGER, cname TEXT,'
        'nid INTEGER, pid INTEGER, content TEXT, hasContent INTEGER)');
    await _db.execute('CREATE TABLE BookIndex (id INTEGER PRIMARY KEY, bookId INTEGER,bIndexs TEXT)');
  }

  /// isNew == 1
  Future updateCname(int id, String cname, String updateTime) async {
    final _ocname = await _db.rawQuery('SELECT lastChapter from BookInfo where bookId = ?', [id]);
    if (_ocname.isNotEmpty) {
      if (_ocname.first['lastChapter'] != cname) {
        return _db.rawUpdate('update BookInfo set lastChapter = ?, isNew = ?, updateTime = ? where bookId = ?',
            [cname, 1, updateTime, id]);
      }
    }
  }

  /// isNew == 0
  Future<void> updateMainInfo(int id, int cid, int page) async {
    await _db.rawUpdate('update BookInfo set chapterId = ?, cPage = ?, isNew = ?,sortKey = ? where bookId = ?',
        [cid, page, 0, DateTime.now().millisecondsSinceEpoch, id]);
  }

  Future<void> updateBookIsTop(int id, int isTop) async {
    await _db.rawUpdate('update BookInfo set isTop = ?,sortKey = ?  where bookId = ?',
        [isTop, DateTime.now().millisecondsSinceEpoch, id]);
  }

  /// [painterBloc]
  Future<void> saveToDatabase(BookContent bookContent) async {
    final count = Sqflite.firstIntValue(await _db
        .rawQuery('SELECT COUNT(*) FROM BookContent WHERE bookId =? AND cid = ?', [bookContent.id, bookContent.cid]));
    if (count! > 0) {
      await _db.rawUpdate(
          'UPDATE BookContent SET pid = ?, nid = ?, hasContent = ?,content = ? WHERE bookId = ? AND cid = ?', [
        bookContent.pid,
        bookContent.nid,
        bookContent.hasContent,
        bookContent.content,
        bookContent.id,
        bookContent.cid
      ]);
    } else {
      await _db.rawInsert(
        'INSERT INTO BookContent (bookId, cid, cname, nid, pid, content, hasContent)'
        ' VALUES(?,?,?,?,?,?,?)',
        [
          bookContent.id,
          bookContent.cid,
          bookContent.cname,
          bookContent.nid,
          bookContent.pid,
          bookContent.content,
          bookContent.hasContent,
        ],
      );
    }
  }

  Future<List<Map<String, Object?>>> loadFromDb(int contentid, int _bookid) async {
    return _db.rawQuery('SELECT content,nid,pid,cid,cname,hasContent FROM BookContent WHERE bookId =? AND cid = ?',
        [_bookid, contentid]);
  }

  Future<void> deleteCache(int bookId) async {
    await _db.rawDelete('DELETE FROM BookContent WHERE bookId = ?', [bookId]);
  }

  /// [BookIndexBloc]
  Future<void> cacheinnerdb(int? id, String indexs) async {
    int? count = 0;

    count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM BookIndex WHERE bookId = ?', [id]));
    if (count! > 0) {
      await _db.rawUpdate('UPDATE BookIndex set bIndexs = ? WHERE bookId = ?', [indexs, id]);
      assert(Log.log(count > 1 ? Log.error : Log.info, 'count: $count,id: $id cache bIndexs.',
          stage: this, name: 'cacheinnerdb'));
    } else {
      await _db.rawInsert(
        'INSERT INTO BookIndex (bookId,bIndexs)'
        ' VALUES(?,?)',
        [id, indexs],
      );
    }
  }

  Future<List<Map<String, Object?>>> sendIndexs(int bookid) async {
    return _db.rawQuery('SELECT cid FROM BookContent WHERE bookId =?', [bookid]);
  }

  /// [BookCacheBloc]
  Future<void> addBook(BookCache bookCache) async {
    int? count = 0;
    count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM BookInfo where bookid = ?', [bookCache.id]));
    if (count == 0) {
      await _db.rawInsert(
        'INSERT INTO BookInfo(name, bookId, chapterId, img, updateTime, lastChapter, sortKey, isTop,cPage,isNew)'
        ' VALUES(?,?,?,?,?,?,?,?,?,?)',
        [
          bookCache.name,
          bookCache.id,
          bookCache.chapterId,
          bookCache.img,
          bookCache.updateTime,
          bookCache.lastChapter,
          bookCache.sortKey,
          bookCache.isTop,
          bookCache.page,
          bookCache.isNew,
        ],
      );
    }
  }

  Future<int> deleteBook(int id) async {
    return _db.rawDelete('DELETE FROM BookInfo WHERE bookId = ?', [id]);
  }

  Future<List<Map<String, Object?>>> loadBookInfo() async {
    return _db.rawQuery('SELECT * FROM BookInfo');
  }
}

/// [Android],[IOS],[macOS],[fuchsia] implementation
class InnerDatabaseImpl extends InnerDatabase {
  InnerDatabaseImpl();
  @override
  String dataPath = 'book_view_cache.db';

  @override
  Future<void> initState() async {
    _db = await openDatabase(dataPath, version: 1, onCreate: onCreate);
    // await db.execute('ALTER TABLE BookContent ADD COLUMN hasContent INTEGER');
  }
}

/// [Windows],[Linux] implementation
class InnerDatabaseWinImpl extends InnerDatabase {
  InnerDatabaseWinImpl() {
    sqfliteFfiInit();
  }

  @override
  String dataPath = 'book_view_cache_test.db';
  @override
  Future<void> initState() async {
    _db = await databaseFactoryFfi.openDatabase(dataPath, options: OpenDatabaseOptions(version: 1, onCreate: onCreate));
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
  searchWithKey,
}

class MessageFunc {
  static Future<void> mainList(IsolateSendMessage m) async {
    var bookIndexShort = <List>[];
    try {
      final map = BookIndexRoot.fromJson(jsonDecode(m.args)).data!;
      for (var bookVol in map.list!) {
        final _inl = <dynamic>[bookVol.name];
        for (var bookChapter in bookVol.list!) {
          _inl.add(BookIndexShort(map.name, bookChapter.name, bookChapter.id));
        }
        bookIndexShort.add(_inl);
      }
      m.sp.send(IsolateReceiveMessage(data: bookIndexShort));
    } catch (e) {
      Log.e('url:${m.args}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: bookIndexShort, result: Result.failed));
    }
  }

  static Future<void> bookList(IsolateSendMessage m) async {
    final String c = m.args;
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
      m.sp.send(IsolateReceiveMessage(data: const <BookList>[], result: Result.failed));
    } else {
      try {
        m.sp.send(IsolateReceiveMessage(data: BookListRoot.fromJson(jsonDecode(data)).data));
      } catch (e) {
        Log.e('url:${m.args}, $e', name: '_isolate');
        m.sp.send(IsolateReceiveMessage(data: const <BookList>[], result: Result.failed));
      }
    }
  }

  static Future<void> info(IsolateSendMessage m, Dio client) async {
    return common(
      m,
      client,
      onSuccess: (map) => BookInfoRoot.fromJson(map),
      onError: (_) => m.sp.send(IsolateReceiveMessage(data: const BookInfoRoot(), result: Result.failed)),
    );
  }

  static Future<void> shudanDetail(IsolateSendMessage m, Dio client) async {
    return common(
      m,
      client,
      onSuccess: (map) => BookListDetailRoot.fromJson(map).data,
      onError: (_) => m.sp.send(IsolateReceiveMessage(data: const BookListDetailData(), result: Result.failed)),
    );
  }

  static Future<void> indexs(IsolateSendMessage m, Dio client) async {
    try {
      var respone = await client.get(m.args);
      m.sp.send(IsolateReceiveMessage(data: respone.data!.replaceAll('},]', '}]')));
    } catch (e) {
      Log.e('url:${m.args}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
    }
  }

  static String textDiv(String text) {
    /// layout
    var _text = text.replaceAll(reg, '').replaceAll(RegExp('([(\n|<br/>)\u3000*]+(\n|<br/>))|(<br/>)'), '\n');
    if (_text.startsWith(RegExp('\n'))) {
      _text = _text.replaceFirst(RegExp('\n'), '');
    }
    if (!_text.startsWith(RegExp('\u3000'))) {
      _text = '\u3000\u3000' + _text;
    }
    return _text;
  }

  static Future<void> content(IsolateSendMessage m, Dio client) async {
    return common(m, client, onSuccess: (map) {
      final data = BookContentRoot.fromJson(map).data;
      if (data != null) {
        if (data.content != null) {
          final text = textDiv(data.content!);
          return data.copyWith(content: text);
        } else {
          return const BookContent();
        }
      }
    }, onError: (str) {
      var cid = -1;
      var cname = '';
      var content = '';
      var hasContent = -1;
      var id = -1;
      var name = '';
      var nid = -1;
      var pid = -1;
      final now = Timeline.now;

      str.replaceAllMapped(
          RegExp(
              r'"id":([0-9]+),"name":"(.*?)","cid":(.*?),"cname":"(.*?)","pid":(.*?),"nid":(.*?),"content":"(.*?)","hasContent":(.*?)}'),
          (match) {
        final count = match.groupCount;
        for (var i = 1; i <= count; i++) {
          Log.i('match :${match[i]}');
        }
        id = int.tryParse(match[1]!) ?? -1;
        name = match[2] ?? '';
        cid = int.tryParse(match[3]!) ?? -1;
        cname = match[4] ?? '';

        pid = int.tryParse(match[5]!) ?? -1;
        nid = int.tryParse(match[6]!) ?? -1;
        content = match[7] ?? '';
        hasContent = int.tryParse(match[8]!) ?? -1;
        ;
        return '';
      });
      Log.i('bookContent map : ${(Timeline.now - now) / 1000}ms');

      if (id != -1 && content.isNotEmpty && name.isNotEmpty && cname.isNotEmpty) {
        content = textDiv(content);
        m.sp.send(
          IsolateReceiveMessage(
            data: BookContent(
              id: id,
              name: name,
              cid: cid,
              pid: pid,
              nid: nid,
              content: content,
              hasContent: hasContent,
              cname: cname,
            ),
          ),
        );
      }
      m.sp.send(IsolateReceiveMessage(data: const BookContent(), result: Result.failed));
    });
  }

  static Future<void> shudan(IsolateSendMessage m, Dio client) async {
    try {
      final String c = m.args[0];
      final int index = m.args[1];
      var respone = await client.get(c);
      final data = respone.data!;
      m.sp.send(IsolateReceiveMessage(data: BookListRoot.fromJson(jsonDecode(data)).data ?? <BookList>[]));
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
      Log.e('url:${m.args}, $e', name: '_isolate');
      m.sp.send(IsolateReceiveMessage(data: const <BookList>[], result: Result.failed));
    }
  }

  static Future<void> searchWithKey(IsolateSendMessage m, Dio client) async {
    return common(m, client,
        onSuccess: (map) => SearchList.fromJson(map),
        onError: (_) => m.sp.send(IsolateReceiveMessage(data: const SearchList(), result: Result.failed)));
  }

  static final reg = RegExp('\u0009|\u000B|\u000C|\u000D|\u0020|'
      '\u00A0|\u1680|\uFEFF|\u205F|\u202F|\u2028|\u2000|\u2001|\u2002|'
      '\u2003|\u2004|\u2005|\u2006|\u2007|\u2008|\u2009|\u200A|(&nbsp;)+');

  static Future<void> common(
    IsolateSendMessage m,
    Dio client, {
    required dynamic Function(Map<String, dynamic>) onSuccess,
    required void Function(String str) onError,
  }) async {
    var str = '';
    try {
      var respone = await client.get<String>(m.args);
      str = respone.data!;
      Map<String, dynamic> map = jsonDecode(str);

      m.sp.send(IsolateReceiveMessage(data: onSuccess(map)));
    } catch (e) {
      onError(str);
    }
  }
}

class IsolateSendMessage {
  IsolateSendMessage(this.type, this.args, this.sp);
  final MessageType type;
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

void _isolateRe(List args) async {
  assert(() {
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
  var frequency = 0;

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
            if (frequency >= 6) {
              Log.i('await content.....');
              await Future.delayed(Duration(seconds: 2));
            }
            frequency++;
            Future.delayed(Duration(seconds: 8), () {
              if (frequency > 0) {
                frequency--;
              }
            });
            if (frequency > 2) {
              await Future.delayed(Duration(milliseconds: 500));
            }
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
          case MessageType.searchWithKey:
            MessageFunc.searchWithKey(m, client);
            break;
          case MessageType.restartClient:
            Log.i('restartClient....', name: 'restartClient');
            client.close();
            client = dioCreater();
            m.sp.send(IsolateReceiveMessage(data: ''));
            break;
          default:
            assert(false, 'not yet implemented');
            m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
        }
      }
    },
  );
}

Dio dioCreater() => Dio(
      BaseOptions(
        connectTimeout: 5000,
        sendTimeout: 5000,
        receiveTimeout: 10000,
        headers: {HttpHeaders.connectionHeader: 'keep-alive'},
      ),
    );

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) {
    final colorValue = reader.readInt();
    return Color(colorValue);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }

  @override
  int get typeId => 0;
}

class AxisAdapter extends TypeAdapter<Axis> {
  @override
  Axis read(BinaryReader reader) {
    final index = reader.readInt();
    return Axis.values[index];
  }

  @override
  void write(BinaryWriter writer, Axis axis) {
    writer.writeInt(axis.index);
  }

  @override
  int get typeId => 1;
}

class TargetPlatformAdapter extends TypeAdapter<TargetPlatform> {
  @override
  TargetPlatform read(BinaryReader reader) {
    final index = reader.readInt();
    return TargetPlatform.values[index];
  }

  @override
  void write(BinaryWriter writer, TargetPlatform obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 2;
}

class PageBuilderAdapter extends TypeAdapter<PageBuilder> {
  @override
  PageBuilder read(BinaryReader reader) {
    final index = reader.readInt();
    return PageBuilder.values[index];
  }

  @override
  void write(BinaryWriter writer, PageBuilder obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 3;
}
