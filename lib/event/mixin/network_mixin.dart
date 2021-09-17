import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:useful_tools/common.dart';
import 'package:useful_tools/event_queue.dart';

import '../../api/api.dart';
import '../../data/data.dart';
import '../../database/database.dart';
import '../base/book_event.dart';
import '../base/constants.dart';
import '../base/type_adapter.dart';

mixin NetworkMixin implements CustomEvent {
  var frequency = 0;
  late Dio dio;

  late Box<int> imageUpdate;

  String get appPath;
  String get cachePath;

  Future<void> netEventInit() => _init();
  Timer? frequencyTimer;

  Future<String> getIndexsNet(int id) {
    return _loadIndexs(id);
  }

  /// 章节内容
  /// 从网络数据格式转换成数据库格式
  Future<BookContentDb> getContentNet(int bookid, int contentid) async {
    if (frequency >= 6) {
      await Future.delayed(const Duration(seconds: 1));
    } else if (frequency > 2) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    frequency++;
    frequencyTimer ??=
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (frequency > 0) {
        frequency--;
      } else {
        timer.cancel();
        frequencyTimer = null;
        assert(Log.w('frequency: cancel'));
      }
    });

    return _loadContent([bookid, contentid])
        .then((v) => BookContentDb.fromBookContent(v));
  }

  // @override
  NetBookIndex getIndexsDecodeLists(String str) => _decodeIndexsLists(str);

  Future<BookInfoRoot> getInfoNet(int id) => _loadInfo(id);

  @override
  Future<List<BookList>> getHiveShudanLists(String c) =>
      _loadHiveShudanLists(c);

  @override
  Future<List<BookList>> getShudanLists(String c, int index) =>
      _loadShudanLists(c, index);
  @override
  Future<BookTopData> getTopLists(String c, String date, int index) =>
      _loadTopLists(c, date, index);

  @override
  Future<BookListDetailData> getShudanDetail(int index) =>
      _loadShudanDetail(index);

  @override
  Future<SearchList> getSearchData(String key) => _loadSearchData(key);

  @override
  Future<BookTopData> getCategLists(int c, String date, int index) =>
      _getCategLists(c, date, index);

  @override
  Future<String> getImagePath(String img) => _getImagePath(img);

  @override
  Future<Uint8List?> getImageBytes(String img) => _getImageBytes(img);

  // @override
  // Future<Uint8List?> getImageFromNetMemory(String img) =>
  //     _getImageFromNetMemory(img);

  @override
  Future<List<BookCategoryData>> getCategoryData() => _getCategoryData();

  LazyBox? box;

  final _errorLoading = <String, int>{};

  final _e = RegExp('(?:(?:\n|<br/>)[\u3000 ]*)*(?:\n|<br/>)');
  final _en = RegExp('\n');
  final _es = RegExp('\u3000| ');

  final _em = RegExp(
      r'"id":([0-9]+),"name":"(.*?)","cid":(.*?),"cname":"(.*?)","pid":(.*?),'
      r'"nid":(.*?),"content":"(.*?)","hasContent":(.*?)}');

  final _ei = RegExp('https?://');
  final _e2f = RegExp('/|%2F');
  
  @pragma('vm:prefer-inline')
  Future<T> imageTasks<T>(EventCallback<T> task) {
    return EventQueue.runTaskOnQueue(imageTasks, task, channels: 10);
  }

  @pragma('vm:prefer-inline')
  Future<T> ioTasks<T>(EventCallback<T> task) {
    return EventQueue.runTaskOnQueue(ioTasks, task);
  }
}

/// 以扩展的形式实现
extension _NetworkImpl on NetworkMixin {
  String get imageLocalPath => join(cachePath, 'shudu', 'images');

  Future<void> _init() async {
    dio = dioCreater();
    Hive.init(join(appPath, 'hive'));
    final d = Directory(imageLocalPath);

    imageUpdate = await Hive.openBox<int>('imageUpdate');
    final exists = await d.exists();

    if (imageUpdate.get('_version_', defaultValue: -1) == -1) {
      await imageUpdate.deleteFromDisk();

      imageUpdate = await Hive.openBox<int>('imageUpdate');

      await imageUpdate.put('_version_', 1);
      if (exists) {
        await d.delete(recursive: true);
        await d.create(recursive: true);
      }
    }

    if (!exists) {
      d.createSync(recursive: true);
    }
    // assert(Log.w((await d.list().toList()).join(' | img.\n')));

    // final now = DateTime.now().millisecondsSinceEpoch;
    // var map = imageUpdate.toMap();
    // for (final m in map.entries) {
    //   final key = m.key;
    //   final value = m.value;
    //   if (key == '_version_') continue;

    //   if (value + oneDay / 2 < now) {
    //     await imageUpdate.delete(key);
    //   }
    // }

    // images = await Hive.openBox<String>('images');
    // map = imageUpdate.toMap();

    // final _img = images.toMap().entries;
    // final tasks = <Future>[];
    // for (final e in _img) {
    //   final key = e.key;
    //   final value = e.value;
    //   if (key == '_version_') return;

    //   if (!map.containsKey(key)) {
    //     tasks.add(images.delete(key));

    //     final f = File(join(imageLocalPath, value));
    //     tasks.add(f.exists().then((exists) {
    //       if (exists) return f.delete(recursive: true);
    //     }));
    //   }
    // }
    // iOTask.awaitEventTask(() => Future.wait(tasks));
  }

  Future<T> _decode<T>(dynamic url,
      {required T Function(Map<String, dynamic>) onSuccess}) async {
    var str = '';
    try {
      var respone = await dio.get<String>(url);
      str = respone.data ?? str;
      Map<String, dynamic> map = jsonDecode(str);

      return onSuccess(map);
    } on DioError catch (e) {
      // 从错误通道发送 `str`
      Log.i('$e, $url');
      throw str;
    } catch (e) {
      /// 可能的错误：json 解码错误
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

  Future<List<BookCategoryData>> _getCategoryData() async {
    final url = Api.bookCategory();
    return _decode(url,
        onSuccess: (map) => BookCategoryAll.fromJson(map).data ?? const []);
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

  NetBookIndex _decodeIndexsLists(args) {
    // var bookIndexShort = <List>[];
    try {
      return BookIndexRoot.fromJson(jsonDecode(args)).data ??
          const NetBookIndex();

      // for (var bookVol in map.list!) {
      //   final _inl = <dynamic>[bookVol.name];
      //   for (var bookChapter in bookVol.list!) {
      //     _inl.add(BookIndexShort(map.name, bookChapter.name, bookChapter.id));
      //   }
      //   bookIndexShort.add(_inl);
      // }
      // return bookIndexShort;
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

  Future<List<BookList>> _loadShudanLists(String c, int index) async {
    final url = Api.shudanUrl(c, index);
    try {
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
      Log.e('url:$url, $e');
      rethrow;
    }
  }

  Future<BookTopData> _loadTopLists(String c, String date, int index) async {
    final url = Api.topUrl(c, date, index);
    try {
      var respone = await dio.get(url);
      final data = respone.data!;

      return BookTopWrap.fromJson(jsonDecode(data)).data ?? const BookTopData();
    } on DioError catch (e, _) {
      if (e.type == DioErrorType.response) {
        Log.e('url:$url, $e');
        // error: return null;
        rethrow;
      }
      // failed
      return const BookTopData();
    } catch (e) {
      // failed
      return const BookTopData();
    }
  }

  Future<BookTopData> _getCategLists(int c, String date, int index) async {
    final url = Api.categUrl(c, date, index);
    try {
      var respone = await dio.get(url);
      final data = respone.data!;

      return BookTopWrap.fromJson(jsonDecode(data)).data ?? const BookTopData();
    } catch (e) {
      Log.e('url:$url, $e');
      rethrow;
    }
  }

  String trim(String text) {
    var _text = text.replaceAll(trimReg, '').replaceAll(_e, '\n');
    if (_text.startsWith(_en)) {
      _text = _text.replaceFirst(_en, '');
    }
    if (!_text.startsWith(_es)) {
      _text = '\u3000\u3000$_text';
    }
    return _text;
  }

  Future<BookContent> _loadContent(args) async {
    final id = args[0];
    final cid = args[1];

    final url = Api.contentUrl(id, cid);

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
      /// 手动处理json解析失败的情况
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

        str.replaceAllMapped(_em, (match) {
          id = int.tryParse(match[1]!) ?? id;
          name = match[2] ?? name;
          cid = int.tryParse(match[3]!) ?? cid;
          cname = match[4] ?? cname;

          pid = int.tryParse(match[5]!) ?? pid;
          nid = int.tryParse(match[6]!) ?? nid;
          content = match[7]!;
          hasContent = int.tryParse(match[8]!) ?? hasContent;

          return '';
        });
        now.stop();
        Log.i('bookContent map : ${now.elapsedMilliseconds}ms ,$args');

        if (id != -1 &&
            content.isNotEmpty &&
            name.isNotEmpty &&
            cname.isNotEmpty) {
          final _content =
              trim(content.replaceAll(RegExp(r'\\r\\n|\\f\\t\\n'), '\n'));

          return BookContent(
            id: id,
            name: name,
            cid: cid,
            pid: pid,
            nid: nid,
            content: _content,
            hasContent: hasContent,
            cname: cname,
          );
        }
      }
      throw Exception('load content failed');
    });
  }

  List<String> imageUrlResolve(String img) {
    var imgName = '';
    String url;
    if (img.startsWith(_ei)) {
      final splist = img.split(_e2f);
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

  Future<String> _getImagePath(String img) async {
    final imgResolve = imageUrlResolve(img);
    final imgName = imgResolve[1];

    final imgPath = join(imageLocalPath, imgName);

    final imgdateTime = imageUpdate.get(imgName.hashCode);
    final f = File(imgPath);

    final exits = await f.exists();

    final now = DateTime.now().millisecondsSinceEpoch;
    final shouldUpdate = imgdateTime == null || imgdateTime + oneDay / 2 < now;
    if (exits && !shouldUpdate) {
      return imgPath;
    }

    return getImagePathFromNet(img);
  }

  @pragma('vm:prefer-inline')
  bool _isValid(Headers header) {
    final contentType = header.value(HttpHeaders.contentTypeHeader);
    if (contentType != null && contentType.contains(RegExp('image/*'))) {
      return true;
    } else {
      assert(Log.w('..无法识别..'));
      return false;
    }
  }

  Future<String> getImagePathFromNet(String img) async {
    final imgResolve = imageUrlResolve(img);
    final url = imgResolve[0];
    final imgName = imgResolve[1];

    final imgPath = join(imageLocalPath, imgName);

    // 避免太过频繁访问网络
    if (_errorLoading.containsKey(imgName)) {
      final time = _errorLoading[imgName]!;
      if (time + thirtySeconds <= DateTime.now().millisecondsSinceEpoch) {
        // 再次发送网络请求
        _errorLoading.remove(imgName);
      } else {
        return imgPath;
      }
    }

    var success = false;

    List<Uint8List>? imgData;
    await imageTasks(() async {
      try {
        final data = await dio.get<ResponseBody>(url,
            options: Options(responseType: ResponseType.stream));

        imgData = (await data.data?.stream.toList());

        success = imgData != null && _isValid(data.headers);
      } catch (e) {
        success = false;
        _errorLoading[imgName] = DateTime.now().millisecondsSinceEpoch;
        assert(Log.w('$imgName,$url !!!'));
      }
    });

    final data = imgData;
    if (data != null && success) {
      try {
        await ioTasks(() async {
          final temp = File('$imgPath.temp');
          await temp.create(recursive: true);
          final o = await temp.open(mode: FileMode.writeOnly);

          for (final d in data) {
            await o.writeFrom(d);
          }

          await o.close();
          await temp.rename(imgPath);
        });

        _errorLoading.remove(imgName);
        await imageUpdate.put(
            imgName.hashCode, DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        success = false;
      }
    }

    final exists = await File(imgPath).exists();

    if (!exists) {
      await imageUpdate.delete(imgName.hashCode);
    }

    return imgPath;
  }

  /// Uint8List
  Future<Uint8List?> _getImageBytes(String img) async {
    final imgResolve = imageUrlResolve(img);
    final imgName = imgResolve[1];

    final imgPath = join(imageLocalPath, imgName);

    final imgdateTime = imageUpdate.get(imgName.hashCode);

    final now = DateTime.now().millisecondsSinceEpoch;
    final shouldUpdate = imgdateTime == null || imgdateTime + oneDay < now;
    final outOfDate = imgdateTime == null || imgdateTime + oneDay * 7 < now;

    Uint8List? _bytes;
    final f = File(imgPath);
    final exits = await f.exists();
    if (exits) {
      if (!shouldUpdate) {
        _bytes = await f.readAsBytes();
      } else if (outOfDate) {
        await f.delete(recursive: true);
      }
    }

    if (_bytes != null) return _bytes;

    return getImageBytesFromNet(img);
  }

  Future<Uint8List?> getImageBytesFromNet(String img) async {
    final imgResolve = imageUrlResolve(img);
    final url = imgResolve[0];
    final imgName = imgResolve[1];

    final imgPath = join(imageLocalPath, imgName);
    // 避免太过频繁访问网络
    if (_errorLoading.containsKey(imgName)) {
      final time = _errorLoading[imgName]!;
      if (time + thirtySeconds <= DateTime.now().millisecondsSinceEpoch) {
        // 再次发送网络请求
        _errorLoading.remove(imgName);
      } else {
        return null;
      }
    }

    var success = false;

    List<int> dataBytes = <int>[];

    await imageTasks(() async {
      try {
        final data = await dio.get<ResponseBody>(url,
            options: Options(responseType: ResponseType.stream));

        final stream = data.data?.stream;
        if (stream != null) {
          await for (final data in stream) {
            dataBytes.addAll(data);
          }
          success = _isValid(data.headers);
        } else {
          success = false;
        }
      } catch (e) {
        success = false;
        assert(Log.w('error: $imgName | $url'));
      } finally {
        if (success)
          _errorLoading.remove(imgName);
        else
          _errorLoading[imgName] = DateTime.now().millisecondsSinceEpoch;
      }
    });

    if (success && dataBytes.isNotEmpty) {
      ioTasks(() async {
        final temp = File('$imgPath.temp');
        try {
          await temp.create(recursive: true);
          final o = await temp.open(mode: FileMode.writeOnly);
          const sizes = 1024;
          var start = 0;
          var end = 0;
          final max = dataBytes.length;
          while (start < max) {
            end = math.min(start + sizes, max);
            await o.writeFrom(dataBytes, start, end);
            await releaseUI;
            start = end;
          }

          await o.close();
          await temp.rename(imgPath);
        } catch (e) {
          success = false;
        } finally {
          if (success) {
            await imageUpdate.put(
                imgName.hashCode, DateTime.now().millisecondsSinceEpoch);
          } else {
            await imageUpdate.delete(imgName.hashCode);
          }
        }
      });
      return Uint8List.fromList(dataBytes);
    }
  }
}
