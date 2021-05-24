// 本地
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../database/book_database.dart';

import '../api/api.dart';
import '../bloc/bloc.dart';
import '../data/data.dart';
import '../utils/utils.dart';
import 'book_event.dart';
import 'book_event_delegate.dart';
import 'book_event_messager.dart';
import 'book_repository.dart';
import 'constants.dart';
import 'messages.dart';

// 数据库 `Sqflite` Windows,Linux 是 FFI 实现的，可以在 Isolate 创建
// 所有网络任务都在 Isolate 运行
class InnerBookEventIsolate extends BookEvent
    with NetwrokFuncEvent, ContentDatabaseImpl, BookDatabase {
  InnerBookEventIsolate(this.appPath) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        isOn = true;
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      default:
        isOn = true;
      // sqlite3.openInMemory();
    }
  }

  @override
  final String appPath;
  late final bool isOn;
  @override
  Future<void> initState() async {
    // if (isOn) {
    await super.initState();
    // }
    return init();
  }
}

// 隔离任务
class BookEventIsolate extends BookEvent with BookEventDelegateMixin {
  BookEventIsolate(String appPath) {
    target = InnerBookEventIsolate(appPath);
  }

  @override
  late InnerBookEventIsolate target;

  // 函数路径处理
  void resolveFunc(IsolateSendMessage m) {
    if (target.resolve(m)) return;
    // if (!target.isOn) {
    //   Log.i('something was error');
    //   return;
    // }
    switch (m.type) {
      case DatabaseMessage.addBook:
        insertBook(m.args)._futureNull(m);
        break;
      case DatabaseMessage.cacheinnerdb:
        final id = m.args[0];
        final indexs = m.args[1];
        insertOrUpdateIndexs(id, indexs)._futureNull(m);
        break;
      case DatabaseMessage.deleteBook:
        deleteBook(m.args).then(
          (value) => m.sp.send(IsolateReceiveMessage(data: value)),
          onError: (_) =>
              m.sp.send(IsolateReceiveMessage(data: -1, result: Result.failed)),
        );
        break;
      case DatabaseMessage.deleteCache:
        deleteCache(m.args)._futureNull(m);
        break;
      case DatabaseMessage.loadBookInfo:
        getMainBookListDb()._futureMap(m);
        break;
      // case MessageDatabase.loadFromDb:
      //   final bookid = m.args[0];
      //   final contentid = m.args[1];
      //   getContentDb(bookid, contentid)._futureMap(m);
      // break;
      case DatabaseMessage.getCacheContentsDb:
        getCacheContentsDb(m.args)._futureMap(m);
        break;
      case DatabaseMessage.updateBookIsTop:
        int id = m.args[0];
        int isTop = m.args[1];
        int isShow = m.args[2];
        updateBookStatusAndSetTop(id, isTop, isShow)._futureNull(m);
        break;

      case DatabaseMessage.updateCname:
        int id = m.args[0];
        String cname = m.args[1];
        String updateTime = m.args[2];
        updateBookStatusAndSetNew(id, cname, updateTime)._futureNull(m);
        break;

      case DatabaseMessage.updateMainInfo:
        int id = m.args[0];
        int cid = m.args[1];
        int page = m.args[2];
        updateBookStatus(id, cid, page)._futureNull(m);
        break;
      case DatabaseMessage.getIndexDb:
        getIndexsDb(m.args)._futureMap(m);
        break;
      case DatabaseMessage.getAllBookId:
        getAllBookId().then(
          (value) => m.sp.send(IsolateReceiveMessage(data: value)),
          onError: (_) => m.sp.send(IsolateReceiveMessage(
              data: const <int>{}, result: Result.failed)),
        );
        break;
      default:
        Future<void>.value()._futureNull(m);
    }
  }
}

// 网络任务
/// see [BookEventMessager]
mixin NetwrokFuncEvent on BookEvent {
  var frequency = 0;

  String get appPath;
  late Dio dio;
  late Box<int> imageUpdate;

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

  bool resolve(IsolateSendMessage m) {
    if (m.type is! CustomMessage) return false;
    Api.moveNext();
    switch (m.type) {
      case CustomMessage.info:
        _loadInfo(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(
              data: const BookInfoRoot(), result: Result.failed));
        });

        break;
      case CustomMessage.shudanDetail:
        _loadShudanDetail(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(
              data: const BookListDetailData(), result: Result.failed));
        });

        break;
      case CustomMessage.indexs:
        _loadIndexs(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
        });

        break;
      case CustomMessage.content:
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

          _loadContent(m.args).then((value) {
            m.sp.send(IsolateReceiveMessage(data: value));
          }, onError: (e) {
            m.sp.send(IsolateReceiveMessage(
                data: const BookContent(), result: Result.failed));
          });
        });

        break;
      case CustomMessage.shudan:
        _loadShudanLists(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(
              data: const <BookList>[], result: Result.failed));
        });

        break;
      case CustomMessage.bookList:
        _loadHiveShudanLists(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(
              data: const <BookList>[], result: Result.failed));
        });

        break;
      case CustomMessage.mainList:
        _decodeIndexsLists(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(
              data: const <List>[], result: Result.failed));
        });

        break;
      case CustomMessage.searchWithKey:
        _loadSearchData(m.args).then((value) {
          m.sp.send(IsolateReceiveMessage(data: value));
        }, onError: (e) {
          m.sp.send(IsolateReceiveMessage(
              data: const SearchList(), result: Result.failed));
        });

        break;
      case CustomMessage.restartClient:
        Log.i('restartClient....', name: 'restartClient');
        dio.close();
        dio = dioCreater();
        m.sp.send(IsolateReceiveMessage(data: ''));

        break;
      case CustomMessage.saveImage:
        _saveImage(m.args).then(
          (path) => m.sp.send(IsolateReceiveMessage(data: path)),
          onError: (e, t) {
            m.sp.send(IsolateReceiveMessage(data: '', result: Result.failed));
          },
        );

        break;
      case CustomMessage.getContent:
        int bookid = m.args[0];
        int contentid = m.args[1];
        int words = m.args[2];
        bool update = m.args[3];
        getContent(bookid, contentid, words, update).then(
          (value) => m.sp.send(IsolateReceiveMessage(data: value)),
          onError: (e) => m.sp.send(IsolateReceiveMessage(
              data: const RawContentLines(), result: Result.failed)),
        );
        break;
      case CustomMessage.divText:
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
        // final cname = m.args[1];
        // final words = m.args[2];
        final pages = LineSplitter.split(text);

        m.sp.send(IsolateReceiveMessage(data: pages.toList()));
        break;
      default:
        return false;
    }
    return true;
  }

  @override
  Future<String> getIndexsNet(int id) async {
    late String bookIndexs;
    await _loadIndexs(id)
        .then((value) => bookIndexs = value, onError: (_) => bookIndexs = '');
    return bookIndexs;
  }

  // @override
  // Future<RawContentLines> getContent(int bookid, int contentid, int words,
  //     {bool update = false}) async {
  //   if (update) {
  //     return await getContentNet(bookid, contentid, words) ??
  //         await super.getContent(bookid, contentid, words);
  //   }
  //   final content =
  //       await super.getContent(bookid, contentid, words, update: update);

  //   if (content.contentIsEmpty) {
  //     return await getContentNet(bookid, contentid, words) ?? content;
  //   }
  //   return content;
  // }

  /// 默认实现
  // @override
  // Future<RawContentLines?> getContentNet(
  //     int bookid, int contentid, int words) async {
  //   assert(Log.i('loading Id: $contentid', stage: this, name: 'download'));

  //   final bookContent = await downloadContent(bookid, contentid);

  //   if (bookContent.content != null) {
  //     saveContent(bookContent);
  //     final lines =
  //         await textLayout(bookContent.content!, bookContent.cname!, words);

  //     if (lines.isNotEmpty) {
  //       return RawContentLines(
  //         pages: lines,
  //         nid: bookContent.nid,
  //         pid: bookContent.pid,
  //         cid: bookContent.cid,
  //         hasContent: bookContent.hasContent,
  //         cname: bookContent.cname,
  //       );
  //     }
  //   }
  //   return null;
  // }

  /// 章节内容
  @override
  Future<BookContent> getContentNet(int bookid, int contentid) async {
    late BookContent contents;
    await _loadContent([bookid, contentid]).then((value) => contents = value,
        onError: (_) => contents = const BookContent());
    return contents;
  }

  @override
  Future<List<List>> getIndexsDecodeLists(String str) async {
    late List<List> indexs;
    await _decodeIndexsLists(str).then((value) => indexs = value,
        onError: (_) => indexs = const <List>[]);
    return indexs;
  }

  @override
  Future<BookInfoRoot> getInfo(int id) async {
    late BookInfoRoot infoRoot;
    await _loadInfo(id).then((value) => infoRoot = value,
        onError: (_) => infoRoot = const BookInfoRoot());
    return infoRoot;
  }

  @override
  Future<List<BookList>> getHiveShudanLists(String c) async {
    late List<BookList> list;
    await _loadHiveShudanLists(c).then((value) => list = value,
        onError: (_) => list = const <BookList>[]);
    return list;
  }

  @override
  Future<List<BookList>> getShudanLists(String c, int index) async {
    late List<BookList> list;
    await _loadShudanLists([c, index]).then(
      (value) => list = value,
      onError: (_) => list = const <BookList>[],
    );
    return list;
  }

  @override
  Future<BookListDetailData> getShudanDetail(int index) async {
    late BookListDetailData data;
    await _loadShudanDetail(index).then((value) => data = value,
        onError: (_) => data = const BookListDetailData());
    return data;
  }

  @override
  Future<List<String>> textLayout(String text, String cname, int words) async =>
      divText(text, cname);

  @override
  Future<SearchList> getSearchData(String key) async {
    late SearchList searchList;

    await _loadSearchData(key)
        .then((value) => searchList = value)
        .catchError((e) => searchList = const SearchList());

    return searchList;
  }

  @override
  Future<String> getImagePath(String img) => _saveImage(img);

  /// ---------------- implementation ------------
  LazyBox? box;

  final errorLoading = <String, int>{};

  String get imageLocalPath => '$appPath/shudu/images/';

  Future<T> _decode<T>(dynamic url,
      {required T Function(Map<String, dynamic>) onSuccess}) async {
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

  Future<BookInfoRoot> _loadInfo(id) async {
    final url = Api.infoUrl(id);

    return _decode(url, onSuccess: (map) {
      return BookInfoRoot.fromJson(map);
    });
  }

  Future<BookListDetailData> _loadShudanDetail(index) async {
    final url = Api.shudanDetailUrl(index);

    return _decode(url,
        onSuccess: (map) =>
            BookListDetailRoot.fromJson(map).data ??
            const BookListDetailData());
  }

  Future<SearchList> _loadSearchData(String key) async {
    final url = Api.searchUrl(key);
    return _decode(url, onSuccess: (map) => SearchList.fromJson(map));
  }

  Future<String> _loadIndexs(int id) async {
    final url = Api.indexUrl(id);

    try {
      var respone = await dio.get(url);
      return respone.data.replaceAll('},]', '}]');
    } catch (e) {
      Log.e('load indexs: failed, $url');
      rethrow;
    }
  }

  Future<List<List>> _decodeIndexsLists(args) async {
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

  Future<List<BookList>> _loadHiveShudanLists(args) async {
    final String c = args;
    String? data;

    if (box == null || !box!.isOpen) {
      box = await Hive.openLazyBox('shudanlist');
    }
    switch (c) {
      case 'new':
        data = await box!.get('shudanNewList');
        break;
      case 'hot':
        data = await box!.get('shudanHotList');
        break;
      case 'collect':
        data = await box!.get('shudanCollectList');
        break;
    }

    if (data == null) {
      throw Exception('data == null');
    } else {
      try {
        return BookListRoot.fromJson(jsonDecode(data)).data ??
            const <BookList>[];
      } catch (e) {
        Log.e('url:$args, $e', name: '_isolate');
        rethrow;
      }
    }
  }

  Future<List<BookList>> _loadShudanLists(args) async {
    try {
      final String c = args[0];
      final int index = args[1];

      final url = Api.shudanUrl(c, index);

      var respone = await dio.get(url);
      final data = respone.data!;

      if (index == 1) {
        if (box == null || !box!.isOpen) {
          box = await Hive.openLazyBox('shudanlist');
        }
        switch (c) {
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
      }

      return BookListRoot.fromJson(jsonDecode(data)).data ?? const <BookList>[];
    } catch (e) {
      Log.e('url:$args, $e', name: '_isolate');
      rethrow;
    }
  }

  String trim(String text) {
    var _text = text
        .replaceAll(trimReg, '')
        .replaceAll(RegExp('([(\n|<br/>)\u3000*]+(\n|<br/>))|(<br/>)'), '\n');
    if (_text.startsWith(RegExp('\n'))) {
      _text = _text.replaceFirst(RegExp('\n'), '');
    }
    if (!_text.startsWith(RegExp('\u3000'))) {
      _text = '\u3000\u3000' + _text;
    }
    return _text;
  }

  Future<BookContent> _loadContent(args) async {
    final id = args[0];
    final cid = args[1];

    final url = Api.contentUrl(id, cid);

    Log.i(url);

    Api.moveNext();

    return _decode(
      url,
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
            RegExp(
                r'"id":([0-9]+),"name":"(.*?)","cid":(.*?),"cname":"(.*?)","pid":(.*?),'
                r'"nid":(.*?),"content":"(.*?)","hasContent":(.*?)}'), (match) {
          id = int.tryParse(match[1]!) ?? id;
          name = match[2] ?? name;
          cid = int.tryParse(match[3]!) ?? cid;
          cname = match[4] ?? cname;

          pid = int.tryParse(match[5]!) ?? pid;
          nid = int.tryParse(match[6]!) ?? nid;
          content = match[7] ?? content;
          hasContent = int.tryParse(match[8]!) ?? hasContent;

          return '';
        });
        now.stop();
        Log.i('bookContent map : ${now.elapsedMilliseconds}ms ,$args');

        if (id != -1 &&
            content.isNotEmpty &&
            name.isNotEmpty &&
            cname.isNotEmpty) {
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

  Future<String> _saveImage(String img) async {
    final imgResolve = imageUrlResolve(img);
    final imgName = imgResolve[1];

    final imgPath = '$imageLocalPath$imgName';
    final imgdateTime = imageUpdate.get(imgName.hashCode);
    final shouldUpdate = imgdateTime == null
        ? true
        : imgdateTime + threeDays < DateTime.now().millisecondsSinceEpoch;
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
          return _saveImage(errorImg);
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
        await imageUpdate.put(
            imgName.hashCode, DateTime.now().millisecondsSinceEpoch);
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
      return _saveImage(errorImg);
    }

    return imgPath;
  }
}

extension _FutureMap on Future<List<Map<String, Object?>>> {
  void _futureMap(IsolateSendMessage m) {
    then(
      (value) => m.sp.send(IsolateReceiveMessage(data: value)),
      onError: (_) => m.sp.send(IsolateReceiveMessage(
          data: const <Map<String, Object?>>[], result: Result.failed)),
    );
  }
}

extension _FutureNull on Future<void> {
  void _futureNull(IsolateSendMessage m) {
    then(
      (_) => m.sp.send(IsolateReceiveMessage(data: null)),
      onError: (_) =>
          m.sp.send(IsolateReceiveMessage(data: null, result: Result.failed)),
    );
  }
}
