import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
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

typedef DCallback<T> = Future<void> Function(T d);

// class SecondData extends Object {
//   SecondData(this.db, this.bloc);
//   // final Dio dio;
//   final Database db;
//   // final SharedPreferences prefs;
//   final BookCacheBloc bloc;
// }

abstract class BookRepository {
  BookRepository();

  late String dataPath;
  // Dio dio;
  late Database db;
  // late SharedPreferences prefs;
  late String appPath;
  final _init = ValueNotifier<bool>(false);
  ValueNotifier<bool> get init => _init;
  static int shortid(int id) => (id / 1000 + 1).toInt();

  static String imageUrl(String img) => 'https://imgapixs.pigqq.com/BookFiles/BookImages/$img';

  static String contentUrl(int id, int? cid) {
    final sd = shortid(id);
    return 'https://contentxs.pigqq.com/BookFiles/Html/$sd/$id/$cid.html';
  }

  static String indexUrl(int id) {
    final sid = shortid(id);
    return 'https://infosxs.pigqq.com/BookFiles/Html/$sid/$id/index.html';
  }

  static String infoUrl(int id) {
    final sid = shortid(id);
    return 'https://infosxs.pigqq.com/BookFiles/Html/$sid/$id/info.html';
  }

  static String shudanUrl(String c, int index) {
    return 'https://scxs.pigqq.com/shudan/man/all/$c/$index.html';
  }

  static String shudanDetailUrl(int? index) {
    assert(index != null);
    return 'https://scxs.pigqq.com/shudan/detail/$index.html';
  }

  late ReceivePort clientRP;
  late SendPort clientSP;
  late Isolate _isolate;
  final client = TimeClient();
  @mustCallSuper
  Future<void> initState() async {
    // dio ??= Dio(BaseOptions(connectTimeout: 5000, receiveTimeout: 5000, sendTimeout: 5000));
    // prefs = await SharedPreferences.getInstance();
    appPath = (await getApplicationDocumentsDirectory())!.path;
    Hive.init('$appPath/shudu/hive');
    final d = Directory('$appPath/shudu/images');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    clientRP = ReceivePort();
    _isolate = await Isolate.spawn(_isolateRe, [clientRP.sendPort, appPath]);
    clientSP = await clientRP.first;
  }

  void afterInit() {
    _init.value = true;
  }

  void dipose() async {
    _isolate.kill();
    await db.close();
  }

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

  /// 目录
  Future<String> getIndexsFromNet(int id) async {
    final url = indexUrl(id);
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
    final url = contentUrl(id, cid);
    return await sendMessage<BookContent>(MessageType.content, url);
  }

  String get imageLocalPath => '$appPath/shudu/images/';
  var errorLoading = <String>[];
  int time = 0;
  Future<dynamic> saveImage(String img) async {
    var imgName = '';
    String url;
    if (img.startsWith('https://') || img.startsWith('http://')) {
      var reurl = img.replaceAll('%3A', ':').replaceAll('%2F', '/').replaceAll(RegExp('https://|http://'), '');
      final splist = reurl.split('/');
      for (var i = splist.length - 1; i >= 0; i--) {
        if (splist[i].isNotEmpty) {
          imgName = splist[i];
          break;
        }
      }
      url = img;
    } else {
      url = imageUrl(img);
      imgName = img;
    }

    final imgPath = '$imageLocalPath$imgName';
    if (!await File(imgPath).exists()) {
      if (errorLoading.contains(imgName)) {
        if (time + 1000 * 120 <= DateTime.now().millisecondsSinceEpoch) {
          time = DateTime.now().millisecondsSinceEpoch;
          errorLoading.remove(imgName);
        } else {
          return '${imageLocalPath}guizhenwuji.jpg';
        }
      }
      try {
        var respone = await client.get(Uri.parse(url));

        if (respone.statusCode <= 304) {
          try {
            decodeImageFromList(respone.bodyBytes);
            await File(imgPath).writeAsBytes(respone.bodyBytes);
            return respone.bodyBytes;
          } catch (e) {
            Log.e('no image !!!', stage: this, name: 'saveImage');
          }
        } else {
          errorLoading.add(imgName);
          return '${imageLocalPath}guizhenwuji.jpg';
        }
      } catch (e) {
        print('url:$url, e: $e');
        errorLoading.add(imgName);
        return '${imageLocalPath}zanwutupian.jpg';
      }
    }
    return imgPath;
  }

  /// bookIndexBloc.loadFromList
  Future<List<List>> loadIndexsList(String str) async {
    return await sendMessage<List<List>>(MessageType.mainList, str);
  }

  Future<BookInfoRoot> loadInfo(int id) async {
    final url = infoUrl(id);
    return await sendMessage<BookInfoRoot>(MessageType.info, url);
  }

  Future<List<BookList>> getBookList(String c) async => await sendMessage<List<BookList>>(MessageType.bookList, c);

  Future<List<BookList>> loadShudan(String c, int index) async {
    return await sendMessage<List<BookList>>(MessageType.shudan, [c, index]);
    // if (result.isNotEmpty) {
    //   return [result, 302];
    // } else {
    //   return ['', 404];
    // }
    // return result;
  }

  Future<BookListDetailData> loadShudanDetail(int? index) async {
    final url = shudanDetailUrl(index);
    return await sendMessage(MessageType.shudanDetail, url);
  }
}

class ImagePathData {
  const ImagePathData({this.path = '', this.error = false});
  final String path;
  final bool error;
}

class BookRepositoryImpl extends BookRepository {
  BookRepositoryImpl();
  @override
  String dataPath = 'book_view_cache.db';

  @override
  Future<void> initState() async {
    await super.initState();
    db = await openDatabase(dataPath, version: 1, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId INTEGER, chapterId INTEGER,'
          'img TEXT, updateTime TEXT, lastChapter TEXT, sortKey INTEGER, isTop INTEGER, cPage INTEGER, isNew INTEGER)');
      await db.execute('CREATE TABLE BookContent (id INTEGER PRIMARY KEY, bookId INTEGER, cid INTEGER, cname TEXT,'
          'nid INTEGER, pid INTEGER, content TEXT, hasContent INTEGER)');
      await db.execute('CREATE TABLE BookIndex (id INTEGER PRIMARY KEY, bookId INTEGER,bIndexs TEXT)');
    });
    // await db.execute('ALTER TABLE BookContent ADD COLUMN hasContent INTEGER');
    afterInit();
  }
}

class BookRepositoryWinImpl extends BookRepository {
  BookRepositoryWinImpl() {
    sqfliteFfiInit();
  }

  @override
  String dataPath = 'book_view_cache_test.db';
  @override
  Future<void> initState() async {
    await super.initState();
    db = await databaseFactoryFfi.openDatabase(
      dataPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE BookInfo (id INTEGER PRIMARY KEY, name TEXT, bookId INTEGER, chapterId INTEGER,'
              'img TEXT, updateTime TEXT, lastChapter TEXT, sortKey INTEGER, isTop INTEGER, cPage INTEGER, isNew INTEGER)');
          await db.execute('CREATE TABLE BookContent (id INTEGER PRIMARY KEY, bookId INTEGER, cid INTEGER, cname TEXT,'
              'nid INTEGER, pid INTEGER, content TEXT, hasContent INTEGER)');
          await db.execute('CREATE TABLE BookIndex (id INTEGER PRIMARY KEY, bookId INTEGER, bIndexs TEXT)');
        },
      ),
    );
    afterInit();
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
  imgPath,
}

class IsolateSendMessage {
  IsolateSendMessage(this.type, this.arg, this.sp);
  final MessageType type;
  final dynamic arg;
  final SendPort sp;
}

enum Result {
  success,
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
    Log.switchToPrint = (stage) {
      return true;
    };
    return true;
  }());
  final port = args[0];
  final appPath = args[1];
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);
  Hive.init(appPath + '/shudu/hive');
  final client = TimeClient();


  receivePort.listen(
    (m) async {
      if (m is IsolateSendMessage) {
        switch (m.type) {
          case MessageType.info:
            try {
              var respone = await client.get(Uri.parse(m.arg));
              Map<String, dynamic> map = jsonDecode(utf8.decoder.convert(respone.bodyBytes));
              m.sp.send(IsolateReceiveMessage(data: BookInfoRoot.fromJson(map), result: Result.success));
            } catch (e) {
              Log.e('url:${m.arg}, $e', name: '_isolate');
              m.sp.send(IsolateReceiveMessage(data: BookInfoRoot(), result: Result.error));
            }
            break;
          case MessageType.shudanDetail:
            try {
              var respone = await client.get(Uri.parse(m.arg));
              Map<String, dynamic> map = jsonDecode(utf8.decoder.convert(respone.bodyBytes));
              m.sp.send(IsolateReceiveMessage(data: BookListDetailRoot.fromJson(map).data, result: Result.success));
            } catch (e) {
              Log.e('url:${m.arg}, $e', name: '_isolate');
              m.sp.send(IsolateReceiveMessage(data: BookListDetailData(), result: Result.error));
            }
            break;
          case MessageType.indexs:
            try {
              var respone = await client.get(Uri.parse(m.arg));
              m.sp.send(IsolateReceiveMessage(
                  data: utf8.decoder.convert(respone.bodyBytes).replaceAll('},]', '}]'), result: Result.success));
            } catch (e) {
              Log.e('url:${m.arg}, $e', name: '_isolate');
              m.sp.send(IsolateReceiveMessage(data: '', result: Result.error));
            }
            break;
          case MessageType.content:
            try {
              var respone = await client.get(Uri.parse(m.arg));
              m.sp.send(IsolateReceiveMessage(
                  data: BookContentRoot.fromJson(jsonDecode(utf8.decoder.convert(respone.bodyBytes))).data,
                  result: Result.success));
            } catch (e) {
              Log.e('url:${m.arg}, $e', name: '_isolate');

              m.sp.send(IsolateReceiveMessage(data: BookContent(), result: Result.error));
            }
            break;
          case MessageType.shudan:
            try {
              final String c = m.arg[0];
              final int index = m.arg[1];
              var respone = await client.get(Uri.parse(BookRepository.shudanUrl(c, index)));
              final data = utf8.decoder.convert(respone.bodyBytes);
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

            break;
          case MessageType.bookList:
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
                m.sp.send(
                    IsolateReceiveMessage(data: BookListRoot.fromJson(jsonDecode(data)).data, result: Result.success));
              } catch (e) {
                Log.e('url:${m.arg}, $e', name: '_isolate');
                m.sp.send(IsolateReceiveMessage(data: <BookList>[], result: Result.error));
              }
            }
            break;
          case MessageType.mainList:
            var bookIndexShort = <List>[];
            BookIndex map;
            try {
              map = BookIndexRoot.fromJson(jsonDecode(m.arg)).data!;
              for (var bookVol in map.list!) {
                final _inl = []..add(bookVol.name);
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
            break;
          default:
            m.sp.send(IsolateReceiveMessage(data: '', result: Result.error));
        }
      }
    },
  );
  // receivePort.listen((m) async{
  // });
}

// Future<http.Response> http.get(Uri url, {Map<String, String>? headers}) {
//   return _withClient((client) => client.get(url, headers: headers));
// }

// Future<T> _withClient<T>(Future<T> Function(http.Client) fn) async {
//   var client = http.Client();

//   final result = await fn(client);
//   // client.close();
//   return result;
// }

// Future<HttpClientResponse> wrapClient(Uri uri, {Map<String, Object>? headers}) async {
//   var client = HttpClient();
//   client.connectionTimeout = const Duration(seconds: 15);
//   return await client.http.get(uri).then((request) async {
//     if (headers != null) {
//       headers.forEach((key, value) {
//         request.headers.add(key, value);
//       });
//     }
//     return request.close();
//   });
// }

// Future<T?> timeLimit<T>(Future<T> Function() fn, {int? seconds, void Function(Object)? onTimeout}) async {
//   try {
//     return await fn().timeout(Duration(seconds: seconds ?? 5));
//   } catch (e) {
//     onTimeout?.call(e);
//     return null;
//   }
// }
