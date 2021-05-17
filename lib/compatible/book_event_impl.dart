// 本地
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../api/api.dart';
import '../data/data.dart';
import '../utils/utils.dart';

import '../bloc/bloc.dart';
import 'book_event.dart';
import 'book_event_mixin.dart';
import 'book_repository.dart';
import 'database.dart';
import 'repository.dart';

/// 数据库在 main Isolate 中调用
///
/// 网络任务在 另一个 Isolate 中调用
class InnerBookEventMainIsolate extends InnerDatabaseImpl with BookTransformerEvent {
  InnerBookEventMainIsolate(this.repository);
  @override
  final Repository repository;
}

// 隔离
class InnerBookEventIsolate extends InnerDatabaseWinImpl with BookIsolateNet {
  InnerBookEventIsolate(this.appPath, this.isOn) : msg = MessageFunc(appPath);

  final String appPath;
  final bool isOn;
  @override
  Future<void> initState() async {
    if (isOn) {
      await super.initState();
    }
    return msg.init();
  }

  @override
  final MessageFunc msg;
}

/// 中间层
///
/// 由 main Isolate 传输到另一个 Isolate
class InnerDatabaseIsoateTransformer extends BookEvent with BookDatabaseTransformerEvent, BookTransformerEvent {
  InnerDatabaseIsoateTransformer(this.repository);
  @override
  final Repository repository;
}

// 隔离任务
class BookEventIsolate extends BookEvent with BookEventDelegateMixin {
  BookEventIsolate(String appPath) {
    bool isON;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        isON = true;
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      default:
        isON = false;
    }
    target = InnerBookEventIsolate(appPath, isON);
  }

  @override
  InnerBookEventIsolate? target;

  // 函数路径处理
  void resolveFunc(IsolateSendMessage m) {
    if (target == null) return;
    if (target!.msg.resolve(m)) return;
    if (!target!.isOn) {
      Log.i('something was error');
      return;
    }
    switch (m.type) {
      case MessageDatabase.addBook:
        addBook(m.args)._futureNull(m);
        break;
      case MessageDatabase.cacheinnerdb:
        final id = m.args[0];
        final indexs = m.args[1];
        cacheinnerdb(id, indexs)._futureNull(m);
        break;
      case MessageDatabase.deleteBook:
        deleteBook(m.args).then(
          (value) => m.sp.send(IsolateReceiveMessage(data: value)),
          onError: (_) => m.sp.send(IsolateReceiveMessage(data: -1, result: Result.failed)),
        );
        break;
      case MessageDatabase.deleteCache:
        deleteCache(m.args)._futureNull(m);
        break;
      case MessageDatabase.loadBookInfo:
        loadBookInfo()._futureMap(m);
        break;
      case MessageDatabase.loadFromDb:
        final bookid = m.args[0];
        final contentid = m.args[1];
        loadFromDb(bookid, contentid)._futureMap(m);
        break;
      case MessageDatabase.sendIndexs:
        sendIndexs(m.args)._futureMap(m);
        break;
      case MessageDatabase.updateBookIsTop:
        int id = m.args[0];
        int isTop = m.args[1];
        updateBookIsTop(id, isTop)._futureNull(m);
        break;

      case MessageDatabase.updateCname:
        int id = m.args[0];
        String cname = m.args[1];
        String updateTime = m.args[2];
        updateCname(id, cname, updateTime)._futureNull(m);
        break;

      case MessageDatabase.updateMainInfo:
        int id = m.args[0];
        int cid = m.args[1];
        int page = m.args[2];
        updateMainInfo(id, cid, page)._futureNull(m);
        break;
      case MessageDatabase.load:
        int bookid = m.args[0];
        int contentid = m.args[1];
        int words = m.args[2];
        bool update = m.args[3];
        load(bookid, contentid, words, update: update).then(
          (value) => m.sp.send(IsolateReceiveMessage(data: value)),
          onError: (e) => m.sp.send(IsolateReceiveMessage(data: const RawContentLines(), result: Result.failed)),
        );
        break;
      default:
        Future<void>.value()._futureNull(m);
    }
  }
}

// 验证平台，判断是否可以开启隔离任务
class BookEventMain extends BookEvent with BookEventDelegateMixin {
  BookEventMain({required Repository repository}) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        target = InnerBookEventMainIsolate(repository);
        break;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        target = InnerDatabaseIsoateTransformer(repository);
        break;
      default:
    }
  }
}

extension _FutureMap on Future<List<Map<String, Object?>>> {
  void _futureMap(IsolateSendMessage m) {
    then(
      (value) => m.sp.send(IsolateReceiveMessage(data: value)),
      onError: (_) => m.sp.send(IsolateReceiveMessage(data: const <Map<String, Object?>>[], result: Result.failed)),
    );
  }
}

extension _FutureNull on Future<void> {
  void _futureNull(IsolateSendMessage m) {
    then(
      (_) => m.sp.send(IsolateReceiveMessage(data: null)),
      onError: (_) => m.sp.send(IsolateReceiveMessage(data: null, result: Result.failed)),
    );
  }
}

class MessageFunc {
  MessageFunc(this.appPath);

  Future<void> init() async {
    dio = dioCreater();

    Hive.init(appPath + '/hive');

    final d = Directory('$appPath/shudu/images');

    imageUpdate = await Hive.openBox<int>('imageUpdate');
    final exits = await d.exists();

    if (imageUpdate.get('_version_', defaultValue: -1) == -1) {
      await imageUpdate.deleteFromDisk();

      imageUpdate = await Hive.openBox<int>('imageUpdate');

      await imageUpdate.put('_version_', 1);
      if (exits) {
        await d.delete(recursive: true);
        await d.create(recursive: true);
        return;
      }
    }

    if (!exits) {
      await d.create(recursive: true);
    }
  }

  String appPath;
  late Dio dio;
  late Box<int> imageUpdate;

  static const int threeDays = 1000 * 60 * 60 * 24 * 3;
  static const int thirtySeconds = 1000 * 30;
  static final errorLoading = <String, int>{};
  static const errorImg = 'guizhenwuji.jpg';

  String get imageLocalPath => '$appPath/shudu/images/';

  static final reg = RegExp('\u0009|\u000B|\u000C|\u000D|\u0020|'
      '\u00A0|\u1680|\uFEFF|\u205F|\u202F|\u2028|\u2000|\u2001|\u2002|'
      '\u2003|\u2004|\u2005|\u2006|\u2007|\u2008|\u2009|\u200A|(&nbsp;)+');

  Future<T> common<T>(dynamic url, {required T Function(Map<String, dynamic>) onSuccess}) async {
    var str = '';
    try {
      var respone = await dio.get<String>(url);
      str = respone.data ?? str;
      Map<String, dynamic> map = jsonDecode(str);

      return onSuccess(map);
    } catch (e) {
      // 从错误通道发送 `str`
      Log.i('common, $url');
      throw str;
    }
  }

  Future<List<List>> mainList(args) async {
    var bookIndexShort = <List>[];
    try {
      final map = BookIndexRoot.fromJson(jsonDecode(args)).data!;
      for (var bookVol in map.list!) {
        final _inl = <dynamic>[bookVol.name];
        for (var bookChapter in bookVol.list!) {
          _inl.add(BookIndexShort(map.name, bookChapter.name, bookChapter.id));
        }
        bookIndexShort.add(_inl);
      }
      return bookIndexShort;
    } catch (e) {
      Log.e('url:$args, $e', name: '_isolate');
      rethrow;
    }
  }

  Future<List<BookList>> bookList(args) async {
    final String c = args;
    String? data;
    count++;
    if (box == null || box!.isOpen) {
      box = await Hive.openBox('shudanlist');
    }
    switch (c) {
      case 'new':
        data = box!.get('shudanNewList');
        break;
      case 'hot':
        data = box!.get('shudanHotList');
        break;
      case 'collect':
        data = box!.get('shudanCollectList');
        break;
    }
    if (count == 1) await box!.close();
    count--;

    if (data == null) {
      throw Exception('data == null');
    } else {
      try {
        return BookListRoot.fromJson(jsonDecode(data)).data ?? const <BookList>[];
      } catch (e) {
        Log.e('url:$args, $e', name: '_isolate');
        rethrow;
      }
    }
  }

  Future<BookInfoRoot> info(url) async {
    return common(url, onSuccess: (map) {
      return BookInfoRoot.fromJson(map);
    });
  }

  Future<BookListDetailData> shudanDetail(url) async {
    return common(url, onSuccess: (map) => BookListDetailRoot.fromJson(map).data ?? const BookListDetailData());
  }

  Future<String> indexs(url) async {
    try {
      var respone = await dio.get(url);
      return respone.data.replaceAll('},]', '}]');
    } catch (e) {
      Log.e('load indexs: failed, $url');
      rethrow;
    }
  }

  String trim(String text) {
    var _text = text.replaceAll(reg, '').replaceAll(RegExp('([(\n|<br/>)\u3000*]+(\n|<br/>))|(<br/>)'), '\n');
    if (_text.startsWith(RegExp('\n'))) {
      _text = _text.replaceFirst(RegExp('\n'), '');
    }
    if (!_text.startsWith(RegExp('\u3000'))) {
      _text = '\u3000\u3000' + _text;
    }
    return _text;
  }

  Future<BookContent> content(args) async {
    return common(
      args,
      onSuccess: (map) {
        final data = BookContentRoot.fromJson(map).data;
        if (data != null && data.content != null) {
          final text = trim(data.content!);
          return data.copyWith(content: text);
        }
        throw Exception('');
      },
    ).catchError((str) {
      if (str is String && str.isNotEmpty) {
        var cid = -1;
        var cname = '';
        var content = '';
        var hasContent = -1;
        var id = -1;
        var name = '';
        var nid = -1;
        var pid = -1;
        final now = Stopwatch()..start();

        str.replaceAllMapped(
            RegExp(r'"id":([0-9]+),"name":"(.*?)","cid":(.*?),"cname":"(.*?)","pid":(.*?),'
                r'"nid":(.*?),"content":"(.*?)","hasContent":(.*?)}'), (match) {
          final count = match.groupCount;
          for (var i = 1; i <= count; i++) {
            Log.i('match :${match[i]}');
          }
          id = int.tryParse(match[1]!) ?? id;
          name = match[2] ?? name;
          cid = int.tryParse(match[3]!) ?? cid;
          cname = match[4] ?? cname;

          pid = int.tryParse(match[5]!) ?? pid;
          nid = int.tryParse(match[6]!) ?? nid;
          content = match[7] ?? content;
          hasContent = int.tryParse(match[8]!) ?? hasContent;
          ;
          return '';
        });
        now.stop();
        Log.i('bookContent map : ${now.elapsedMilliseconds}ms ,$args');

        if (id != -1 && content.isNotEmpty && name.isNotEmpty && cname.isNotEmpty) {
          content = trim(content);
          return BookContent(
            id: id,
            name: name,
            cid: cid,
            pid: pid,
            nid: nid,
            content: content,
            hasContent: hasContent,
            cname: cname,
          );
        }
      }
      Log.e('load content: faild');
      throw Exception('load content faild');
    });
  }

  Box? box;
  int count = 0;
  Future<List<BookList>> shudan(args) async {
    try {
      final String c = args[0];
      final int index = args[1];
      var respone = await dio.get(c);
      final data = respone.data!;
      Timer.run(() async {
        final splits = c.split('/');
        final str = splits[splits.length - 2];
        if (index == 1) {
          count++;
          if (box == null || !box!.isOpen) {
            box = await Hive.openBox('shudanlist');
          }
          switch (str) {
            case 'new':
              await box!.put('shudanNewList', data);
              break;
            case 'hot':
              await box!.put('shudanHotList', data);
              break;
            case 'collect':
              await box!.put('shudanCollectList', data);
              break;
          }
          if (count == 1) await box!.close();
          count--;
        }
      });
      return BookListRoot.fromJson(jsonDecode(data)).data ?? const <BookList>[];
    } catch (e) {
      Log.e('url:$args, $e', name: '_isolate');
      rethrow;
    }
  }

  Future<SearchList> searchWithKey(url) async {
    return common(url, onSuccess: (map) => SearchList.fromJson(map));
  }

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

  Future<String> saveImage(String img) async {
    final imgResolve = imageUrlResolve(img);
    final imgName = imgResolve[1];

    final imgPath = '$imageLocalPath$imgName';
    final imgdateTime = imageUpdate.get(imgName.hashCode);
    final shouldUpdate = imgdateTime == null ? true : imgdateTime + threeDays < DateTime.now().millisecondsSinceEpoch;
    final exits = await File(imgPath).exists();
    if (!shouldUpdate && exits) {
      return imgPath;
    }

    return getImageFromNet(img);
  }

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
        if (img != errorImg) {
          return saveImage(errorImg);
        }
        return imgPath;
      }
    }

    var success = false;
    try {
      await dio.download(url, (Headers header) {
        final contentType = header.value(HttpHeaders.contentTypeHeader);
        if (contentType != null && contentType.contains(RegExp('image/*'))) {
          success = true;
          assert(Log.i('..识别正确..$imgName'));
        } else {
          success = false;
          assert(Log.w('..无法识别..$imgName'));
        }
        return imgPath;
      });

      if (success) {
        errorLoading.remove(imgName);
        await imageUpdate.put(imgName.hashCode, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      errorLoading[imgName] = DateTime.now().millisecondsSinceEpoch;
      assert(Log.w('$imgName, $e !!!'));
    }

    final exists = await File(imgPath).exists();

    if (!success) {
      if (!exists) {
        await imageUpdate.delete(imgName.hashCode);
      }
    }

    if (!exists && img != errorImg) {
      return saveImage(errorImg);
    }

    return imgPath;
  }

  bool resolve(IsolateSendMessage m) {
    if (m.type is! MessageType) return false;
    switch (m.type) {
      case MessageType.info:
        info(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: const BookInfoRoot(), result: Result.failed));
        });

        break;
      case MessageType.shudanDetail:
        shudanDetail(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: const BookListDetailData(), result: Result.failed));
        });

        break;
      case MessageType.indexs:
        indexs(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
        });

        break;
      case MessageType.content:
        Timer.run(() async {
          if (frequency >= 6) {
            Log.i('await content.....');
            await Future.delayed(Duration(seconds: 2));
          }

          frequency++;

          Future.delayed(Duration(seconds: 8), () {
            if (frequency > 0) frequency--;
          });

          if (frequency > 2) {
            await Future.delayed(Duration(milliseconds: 500));
          }

          content(m.args).then((value) {
            m.sp.send(IsolateReceiveMessage(data: value));
          }, onError: (e) {
            m.sp.send(IsolateReceiveMessage(data: const BookContent(), result: Result.failed));
          });
        });

        break;
      case MessageType.shudan:
        shudan(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: const <BookList>[], result: Result.failed));
        });

        break;
      case MessageType.bookList:
        bookList(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: const <BookList>[], result: Result.failed));
        });

        break;
      case MessageType.mainList:
        mainList(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: const <List>[], result: Result.failed));
        });

        break;
      case MessageType.searchWithKey:
        searchWithKey(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: const SearchList(), result: Result.failed));
        });

        break;
      case MessageType.restartClient:
        Log.i('restartClient....', name: 'restartClient');
        dio.close();
        dio = dioCreater();
        m.sp.send(IsolateReceiveMessage(data: ''));

        break;
      case MessageType.saveImage:
        saveImage(m.args).then(
          (path) => m.sp.send(IsolateReceiveMessage(data: path)),
          onError: (e, t) {
            m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
          },
        );

        break;
      case MessageType.divText:
        //TransferableTypedData
        //
        //   final list = (m.args as TransferableTypedData).materialize();
        //   var start = 0;
        //   print(list.lengthInBytes);
        //   final sizediv = list.asInt32List(start, 2);
        //   print('sizediv $sizediv');
        //   start += 8;
        //   final words = list.asInt32List(start, 1);
        //   start += 4;
        //   final text = list.asUint8List(start, sizediv[0]);
        //   start += sizediv[0];
        //   final cname = list.asUint8List(start, sizediv[1]);

        //   print('aaa: ${text.lengthInBytes}, ${cname.lengthInBytes}, ${words.lengthInBytes}');
        //   final pages = divText(utf8.decode(text), utf8.decode(cname), words.first);
        //   m.sp.send(IsolateReceiveMessage(data: pages));
        final text = m.args[0];
        final cname = m.args[1];
        // final words = m.args[2];
        final pages = divText(text, cname);
        m.sp.send(IsolateReceiveMessage(data: pages));
        break;
      default:
        return false;
    }
    return true;
  }

  var frequency = 0;
}
