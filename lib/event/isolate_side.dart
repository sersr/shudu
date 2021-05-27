import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../api/api.dart';
import '../bloc/bloc.dart';
import '../data/data.dart';
import '../database/book_database.dart';
import '../database/database_mixin.dart';
import '../utils/utils.dart';
import 'book_event.dart';
import 'book_repository.dart';
import 'constants.dart';
import 'event_mxins.dart';
import 'messages.dart';

class BookEventIsolate extends DatabaseEvent
    with
        //----base
        ComputeEvent,
        MessagerResolver,
        CustomEvent,
        //----dataBase
        BookDatabase,
        ComplexEventDatabase,
        DatabaseMixin,
        //----
        ComplexEventBase,
        //----NetWork
        NetwrokEvent,
        //----
        ComplexEvent {
  BookEventIsolate(this.appPath, this.sp);

  @override
  final SendPort sp;
  @override
  final String appPath;

  @override
  Future<void> initState() async {
    super.initState();
    return init();
  }

  @override
  Future<bool> resolve(IsolateSendMessage m) async {
    if (await super.resolve(m)) return false;

    Future? _f;
    switch (m.type) {
      case DatabaseMessage.addBook:
        _f = insertBook(m.args);
        break;
      case DatabaseMessage.insertBookInfo:
        final id = m.args[0];
        final indexs = m.args[1];
        _f = insertOrUpdateIndexs(id, indexs);
        break;

      case DatabaseMessage.deleteBook:
        _f = deleteBook(m.args);
        break;

      case DatabaseMessage.deleteCache:
        _f = deleteCache(m.args);
        break;
      case DatabaseMessage.loadBookInfo:
        _f = getMainBookListDb();
        break;

      case DatabaseMessage.getCacheContentsDb:
        _f = getCacheContentsCidDb(m.args);
        break;
      case DatabaseMessage.updateBookIsTop:
        int id = m.args[0];
        int isTop = m.args[1];
        int isShow = m.args[2];
        _f = updateBookStatusAndSetTop(id, isTop, isShow);
        break;

      case DatabaseMessage.updateCname:
        _f = _updateBookStatusAndSetNew(m);
        break;

      case DatabaseMessage.updateMainInfo:
        int id = m.args[0];
        int cid = m.args[1];
        int page = m.args[2];
        _f = updateBookStatusCustom(id, cid, page);
        break;

      case DatabaseMessage.getIndexDb:
        _f = getIndexsDb(m.args);
        break;

      case DatabaseMessage.getAllBookId:
        _f = getAllBookId();
        break;

      case DatabaseMessage.getCacheItem:
        _f = getCacheItem(m.args);
        break;

      default:
        _f = Future<void>.value();
    }

    _f._futureAutoSend(sp, m.messageId);

    return false;
  }

  Future<void> _updateBookStatusAndSetNew(IsolateSendMessage m) async {
    final l = (m.args as List).whereType<Object>().toList();
    if (l.length == 1) {
      int id = m.args[0];
      final rawData = await getInfo(id);
      final data = rawData.data;
      if (data != null) {
        final newCname = data.lastChapter;
        final lastTime = data.lastTime;
        if (newCname != null && lastTime != null) {
          return updateBookStatusAndSetNew(id, newCname, lastTime);
        }
      }
    } else {
      assert(l.length == 3);
      final id = l[0] as int;
      final cname = l[1] as String;
      final lastTime = l[2] as String;
      return updateBookStatusAndSetNew(id, cname, lastTime);
    }
  }
}

mixin MessagerResolver {
  @mustCallSuper
  Future<bool> resolve(IsolateSendMessage m) async => false;
}

// 网络任务
// 需要 数据库接口
mixin NetwrokEvent on MessagerResolver, CustomEvent, ComplexEventBase {
  var frequency = 0;

  String get appPath;
  SendPort get sp;

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

  @override
  Future<bool> resolve(IsolateSendMessage m) async {
    if (await super.resolve(m)) return true;

    if (m.type is! CustomMessage) return false;

    // Api.moveNext();
    switch (m.type) {
      case CustomMessage.info:
        _loadInfo(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.shudanDetail:
        _loadShudanDetail(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.indexs:
        _loadIndexs(m.args)._futureAutoSend(sp, m.messageId);

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

          _loadContent(m.args)._futureAutoSend(sp, m.messageId);
        });

        break;
      case CustomMessage.shudan:
        _loadShudanLists(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.bookList:
        _loadHiveShudanLists(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.mainList:
        _decodeIndexsLists(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.searchWithKey:
        _loadSearchData(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.restartClient:
        Log.i('restartClient....');
        dio.close();
        dio = dioCreater();
        sp.send(IsolateReceiveMessage(data: '', messageId: m.messageId));

        break;
      case CustomMessage.saveImage:
        _saveImage(m.args)._futureAutoSend(sp, m.messageId);

        break;
      case CustomMessage.getContent:
        int bookid = m.args[0];
        int contentid = m.args[1];
        bool update = m.args[2];
        getContent(bookid, contentid, update)
            .then<TransferableTypedData?>(RawContentLines.encode,
                onError: (_) => null)
            ._futureAutoSend(sp, m.messageId);
        break;
      default:
        return false;
    }
    // 任务已被处理
    return true;
  }

  @override
  Future<String> getIndexsNet(int id) async {
    return _loadIndexs(id).then((value) => value, onError: (_) => '');
  }

  /// 章节内容
  Future<BookContent> getContentNet(int bookid, int contentid) async {
    return _loadContent([bookid, contentid])
        .then((value) => value, onError: (_) => const BookContent());
  }

  @override
  Future<List<List>> getIndexsDecodeLists(String str) async {
    return _decodeIndexsLists(str)
        .then((value) => value, onError: (_) => const <List>[]);
  }

  @override
  Future<BookInfoRoot> getInfo(int id) async {
    return _loadInfo(id)
        .then((value) => value, onError: (_) => const BookInfoRoot());
  }

  @override
  Future<List<BookList>> getHiveShudanLists(String c) async {
    return _loadHiveShudanLists(c)
        .then((value) => value, onError: (_) => const <BookList>[]);
  }

  @override
  Future<List<BookList>> getShudanLists(String c, int index) async {
    return _loadShudanLists([c, index]).then(
      (value) => value,
      onError: (_) => const <BookList>[],
    );
  }

  @override
  Future<BookListDetailData> getShudanDetail(int index) async {
    return _loadShudanDetail(index)
        .then((value) => value, onError: (_) => const BookListDetailData());
  }

  @override
  Future<SearchList> getSearchData(String key) async {
    return _loadSearchData(key)
        .then((value) => value)
        .catchError((e) => const SearchList());
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
      Log.i('common: $e, $url');
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
      Log.e('url:$args, $e');
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
        Log.e('url:$args, $e');
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
      Log.e('url:$args, $e');
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
    Log.i('net: $url');
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
      assert(Log.w('$imgName,$url !!!'));
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

/// 自动返回消息
extension _FutureAutoSend<T> on Future<T> {
  void _futureAutoSend(SendPort sp, int messageId) {
    then(
      (value) => IsolateReceiveMessage(data: value, messageId: messageId),
      onError: (_) => IsolateReceiveMessage(
          data: null, messageId: messageId, result: Result.failed),
    ).then(sp.send);
  }
}
