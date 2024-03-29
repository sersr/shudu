import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:nop/nop.dart';
import 'package:path/path.dart';

import '../../../api/api.dart';
import '../../../data/data.dart';
import '../../../database/database.dart';
import '../../../utils/type_adapter.dart';
import '../../base/export.dart';
import 'constants.dart';

class DioTor extends Interceptor {
  DioTor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
    this.logPrint = print,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  ///```dart
  ///  var file=File("./log.txt");
  ///  var sink=file.openWrite();
  ///  dio.interceptors.add(LogInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  void Function(Object object) logPrint;

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    handler.next(options);

    logPrint('*** Request ***');
    _printKV('uri', options.uri);
    //options.headers;

    if (request) {
      _printKV('method', options.method);
      _printKV('responseType', options.responseType.toString());
      _printKV('followRedirects', options.followRedirects);
      _printKV('connectTimeout', options.connectTimeout);
      _printKV('sendTimeout', options.sendTimeout);
      _printKV('receiveTimeout', options.receiveTimeout);
      _printKV(
          'receiveDataWhenStatusError', options.receiveDataWhenStatusError);
      _printKV('extra', options.extra);
    }
    if (requestHeader) {
      logPrint('headers:');
      options.headers.forEach((key, v) => _printKV(' $key', v));
    }
    if (requestBody) {
      logPrint('data:');
      _printAll(options.data is FormData
          ? json.encode(Map.fromEntries((options.data as FormData).fields))
          : json.encode(options.data));
    }
    logPrint('');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    handler.next(response);

    logPrint('*** Response ***');
    _printResponse(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (error) {
      logPrint('*** DioError ***:');
      logPrint('uri: ${err.requestOptions.uri}');
      logPrint('$err');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      logPrint('');
    }

    handler.next(err);
  }

  void _printResponse(Response response) {
    _printKV('uri', response.requestOptions.uri);
    if (responseHeader) {
      _printKV('statusCode', response.statusCode);
      if (response.isRedirect == true) {
        _printKV('redirect', response.realUri);
      }

      logPrint('headers:');
      response.headers.forEach((key, v) => _printKV(' $key', v.join('\r\n\t')));
    }
    if (responseBody) {
      logPrint('Response Text:');
      _printAll(response.toString());
    }
    logPrint('');
  }

  void _printKV(String key, Object? v) {
    logPrint('$key: $v');
  }

  void _printAll(msg) {
    // msg.toString().split('\n').forEach(logPrint);
    try {
      debugPrintSynchronously(msg);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

mixin HiveDioMixin on Resolve {
  late Dio dio;
  String get appPath;

  FutureOr<void> _initNet() {
    dio = dioCreater();
    dio.interceptors.add(LogInterceptor());
    Hive.init(join(appPath, 'hive'));
  }

  @override
  void initStateListen(add) {
    super.initStateListen(add);
    add(_initNet());
  }

  @override
  FutureOr<void> onClose() {
    dio.close(force: true);
    return super.onClose();
  }
}

mixin NetworkMixin on HiveDioMixin, CustomEvent, CustomEventResolve {
  var frequency = 0;

  late Box imageUpdate;

  String get cachePath;

  @override
  void initStateListen(add) {
    super.initStateListen(add);
    add(_init());
  }

  Timer? frequencyTimer;

  @override
  Future<String> getIndexsNet(int id) {
    return _loadIndexs(id);
  }

  /// 章节内容
  /// 从网络数据格式转换成数据库格式
  @override
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
      }
    });

    return _loadContent(bookid, contentid).then(BookContentDb.fromBookContent);
  }

  @override
  Future<Uint8ListType> getImageBytesDynamic(String img) async {
    return getImageBytes(img).then(Uint8ListType.wrap);
  }

  LazyBox? box;

  final _errorLoading = <String, int>{};

  Future<T> imageTasks<T>(EventCallback<T> task) {
    return EventQueue.run(imageTasks, task, channels: 5);
  }

  late final String imageLocalPath = join(cachePath, 'shudu', 'images');

  Future<void> _init() async {
    imageUpdate = await Hive.openBox('imageUpdate');
    if (!kIsWeb) {
      final d = Directory(imageLocalPath);
      final exists = d.existsSync();

      if (imageUpdate.get('_version_', defaultValue: -1) == -1) {
        await imageUpdate.deleteFromDisk();

        imageUpdate = await Hive.openBox('imageUpdate');

        await imageUpdate.put('_version_', 1);
        if (exists) {
          d.deleteSync(recursive: true);
          d.createSync(recursive: true);
        }
      }

      if (!exists) {
        d.createSync(recursive: true);
      }
    }
  }

  Future<T> _decode<T>(dynamic url,
      {required T Function(Map<String, dynamic>) onSuccess}) async {
    var str = '';
    try {
      var respone = await dio.get<String>(url);
      str = respone.data ?? str;
      Map<String, dynamic> map = jsonDecode(str);

      return onSuccess(map);
    } catch (e) {
      /// 可能的错误: json 解码错误
      throw str;
    }
  }

  @override
  Future<BookInfoRoot> getInfoNet(int id) async {
    final url = Api.infoUrl(id);
    return _decode(url, onSuccess: (map) {
      return BookInfoRoot.fromJson(map);
    });
  }

  @override
  Future<BookListDetailData> getShudanDetail(int index) async {
    final url = Api.shudanDetailUrl(index);

    return _decode(url,
        onSuccess: (map) =>
            BookListDetailRoot.fromJson(map).data ??
            const BookListDetailData());
  }

  @override
  Future<List<BookCategoryData>> getCategoryData() async {
    final url = Api.bookCategory();
    return _decode(url,
        onSuccess: (map) => BookCategoryAll.fromJson(map).data ?? const []);
  }

  @override
  Future<SearchList> getSearchData(String key) async {
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

  @override
  Future<List<BookList>> getHiveShudanLists(String args) async {
    String? data;

    if (box == null || !box!.isOpen) {
      box = await Hive.openLazyBox('shudanlist');
    }
    switch (args) {
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
      return const [];
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

  @override
  Future<List<BookList>> getShudanLists(String c, int index) async {
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

  Future<BookTopData> _getTopLists(String url) async {
    try {
      var respone = await dio.get(url);
      final data = respone.data!;

      return BookTopWrap.fromJson(jsonDecode(data)).data ?? const BookTopData();
    } on DioError catch (e) {
      Log.w('statusCode: ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) {
        return BookTopData(hasNext: false);
      }
      rethrow;
    } catch (e) {
      // failed
      return const BookTopData();
    }
  }

  @override
  Future<BookTopData> getTopLists(String c, String date, int index) {
    final url = Api.topUrl(c, date, index);
    return _getTopLists(url);
  }

  @override
  Future<BookTopData> getCategLists(int c, String date, int index) {
    final url = Api.categUrl(c, date, index);
    return _getTopLists(url);
  }

  String trim(String text) {
    var _text = text
        .replaceAll(trimReg, '')
        .replaceAll(RegExp('(?:(?:\n|<br/>)[\u3000 ]*)*(?:\n|<br/>)'), '\n');
    if (_text.startsWith('\n')) {
      _text = _text.replaceFirst(RegExp('\u3000| '), '');
    }
    if (!_text.startsWith(RegExp('\u3000| '))) {
      _text = '\u3000\u3000$_text';
    }
    return _text;
  }

  Future<BookContent> _loadContent(int id, int cid) async {
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
          content = match[7]!;
          hasContent = int.tryParse(match[8]!) ?? hasContent;

          return '';
        });

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
    if (img.startsWith(RegExp('https?://'))) {
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

  @pragma('vm:prefer-inline')
  bool _isValid(Headers header) {
    final contentType = header.value(HttpHeaders.contentTypeHeader);
    return _isValidhttp(contentType);
  }

  bool _isValidhttp(String? contentType) {
    if (contentType != null && contentType.contains(RegExp('image/*'))) {
      return true;
    } else {
      assert(Log.w('..无法识别.. $contentType'));
      return false;
    }
  }

  /// Uint8List
  @override
  Future<Uint8List?> getImageBytes(String img) async {
    final imgResolve = imageUrlResolve(img);
    final url = imgResolve[0];
    final imgName = imgResolve[1];

    final imgPath = join(imageLocalPath, imgName);
    final imageKey = base64Encode(utf8.encode(imgName));
    final imgdateTime = imageUpdate.get(imageKey);

    final now = DateTime.now().millisecondsSinceEpoch;
    final shouldUpdate = imgdateTime == null || imgdateTime + oneDay < now;
    final outOfDate = imgdateTime == null || imgdateTime + oneDay * 7 < now;

    Uint8List? _bytes;
    if (!kIsWeb) {
      final f = File(imgPath);
      final exits = await f.exists();
      if (exits) {
        if (!shouldUpdate) {
          _bytes = await f.readAsBytes();
        } else if (outOfDate) {
          await f.delete(recursive: true);
        }
      }
    }

    if (_bytes != null) return _bytes;

    if (_errorLoading.containsKey(imgName)) {
      final time = _errorLoading[imgName]!;
      if (time + thirtySeconds <= DateTime.now().millisecondsSinceEpoch) {
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
        }
        success = _isValid(data.headers);
      } catch (e) {
        success = false;
        assert(Log.w('error: $imgName | $url\n$e', lines: 10));
      } finally {
        if (success)
          _errorLoading.remove(imgName);
        else {
          Log.i('image:$url');
          _errorLoading[imgName] = DateTime.now().millisecondsSinceEpoch;
        }
      }
    });

    if (success && dataBytes.isNotEmpty) {
      if (!kIsWeb) {
        final temp = File('$imgPath.temp');
        try {
          await temp.create(recursive: true);
          var start = 0;
          final max = dataBytes.length;
          final o = await temp.open(mode: FileMode.write);
          while (start < max) {
            final end = math.min(start + 1024, max);
            await o.writeFrom(dataBytes, start, end);
            start = end;
          }
          await o.close();
          await temp.rename(imgPath);
        } catch (e) {
          success = false;
        } finally {
          if (success) {
            await imageUpdate.put(
                imageKey, DateTime.now().millisecondsSinceEpoch);
          } else {
            await imageUpdate.delete(imageKey);
          }
        }
      }

      return Uint8List.fromList(dataBytes);
    }
    return null;
  }
}
