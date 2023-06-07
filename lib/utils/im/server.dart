import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nop/utils.dart';

class ServerBase {
  HttpServer? s;
  final users = <String, WebSocket>{};

  Future<void> bindServer() async {
    s ??= await HttpServer.bind(ConnectURI.host, ConnectURI.port)
      ..listen((req) async {
        if (req.uri.path == ConnectURI.path) {
          final args = req.uri.queryParameters;
          final key = '${args['name']}_${args['password']}';

          var socket = await WebSocketTransformer.upgrade(req);
          users[key]?.close();
          users[key] = socket;
          socket.listen((data) {
            // socket.add('receive #${shortHash(socket)}: $data');

            if (data == 'close') {
              socket.add('收到了，关闭连接');
              socket.close();
              return;
            }
            handleMessager(data, key);
          }, onDone: () {
            users.remove(key);
          }, onError: (error) {
            users.remove(key);

            Log.i('$error');
          });
        }
      });
  }

  void handleMessager(data, key) {
    users.forEach((key, socket) {
      socket.add(data);
    });
  }

  void close() {
    s?.close();
  }
}

// 事件转换
class _MessageTransformer extends StreamTransformerBase implements EventSink {
  EventSink<Message>? _eventSink;
  @override
  Stream<Message> bind(Stream stream) {
    return Stream.eventTransformed(stream, (sink) {
      _eventSink = sink;
      return this;
    });
  }

  @override
  void add(data) {
    Message? _data;
    try {
      _data = Message.formJson(jsonDecode(data));
      if (_data != null) _eventSink?.add(_data);
    } catch (e) {
      Log.i('send: $e');
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _eventSink?.addError(error, stackTrace);
  }

  @override
  void close() {
    _eventSink?.close();
  }
}

abstract class ConnectURI {
  static String host = '127.0.0.1';
  static int port = 9999;
  static String path = '/ws';

  static String uriString(String name, String pwd) =>
      'ws://$host:$port$path?name=$name&password=$pwd';
}

class User {
  final String name;
  final String pwd;
  WebSocket? _webSocket;
  late UserSink _userConsumer;
  Stream<Message>? stream;

  User({required this.name, required this.pwd});

  Future<User> init() async {
    if (_webSocket != null && _webSocket!.readyState < 2) return this;

    final webSocket =
        _webSocket = await WebSocket.connect(ConnectURI.uriString(name, pwd));
    _userConsumer = UserSink(webSocket, this);
    stream = _MessageTransformer().bind(webSocket);
    return this;
  }

  Future<StreamSubscription<Message>> listen(void Function(dynamic)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) async {
    if (stream == null) await init();
    return stream!.listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  Sink get sink => _userConsumer;
  void add(data) {
    sink.add(data);
  }

  Future close() {
    return _userConsumer.close();
  }
}

class Message {
  Message(this.data, this.date, this.type, this.user);
  final DateTime date;
  final String user;
  final int type;
  final dynamic data;

  Map<String, Object> toJson() {
    return <String, Object>{
      'date': date.toString(),
      'type': type,
      'data': data.toString(),
      'user': user
    };
  }

  static Message? formJson(Map map) {
    final _list = ['date', 'type', 'data', 'user'];
    for (final e in _list) {
      if (!map.containsKey(e)) {
        return null;
      }
    }

    final date = DateTime.tryParse(map['date'] as String);
    if (date == null) return null;
    final type = map['type'] as int;
    final user = map['user'] as String;
    final data = map['data'];
    return Message(data, date, type, user);
  }
}

class UserSink implements EventSink {
  UserSink(this._target, this.user);
  final WebSocket _target;
  final User user;
  bool closed = false;
  @override
  Future close() {
    if (closed) return Future.value();
    closed = true;
    return _controller.close();
  }

  @override
  void add(data) {
    if (closed) return;
    final msg = Message(data, DateTime.now(), 0, user.name).toJson();
    _controller.add(jsonEncode(msg));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (closed) return;
    _controller.addError(error, stackTrace);
  }

  StreamController? _controllerInstance;

  StreamController get _controller {
    if (_controllerInstance == null) {
      final controller = _controllerInstance = StreamController(sync: true);
      _target.addStream(controller.stream).then((_) {
        _closeTarget();
      }, onError: (error) {
        _closeTarget();
      });
    }
    return _controllerInstance!;
  }

  void _closeTarget() {
    closed = true;
    _target.close();
  }
}
