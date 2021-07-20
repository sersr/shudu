import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'list_key.dart';

class TextCache {
  void clear() {
    clearDispose(_textDisposesCaches);
    clearDispose(_textDisposes);
    clearDispose(_textListeners);
    clearDisposeRef(_textRefDisposeCaches);
    clearDisposeRef(_textRefDispose);
    clearDisposeRef(_textRef);
  }

  void clearDispose(Map<ListKey, TextStream> map) {
    print('dispose: ${map.length}');
    map.values.forEach((stream) => stream.dispose());
    map.clear();
  }

  void clearDisposeRef(Map<ListKey, TextRef> map) {
    print('dispose: ${map.length}');
    map.clear();
  }

  final _textRef = <ListKey, TextRef>{};
  final _textRefDispose = <ListKey, TextRef>{};
  final _textRefDisposeCaches = <ListKey, TextRef>{};

  final _textLooper = EventLooper();
  final _textListeners = <ListKey, TextStream>{};
  final _textDisposes = <ListKey, TextStream>{};
  final _textDisposesCaches = <ListKey, TextStream>{};

  TextStream? getListener(ListKey key) {
    var listener = _textDisposesCaches.remove(key);
    if (listener != null) {
      assert(!_textDisposes.containsKey(key));
      assert(!_textListeners.containsKey(key));
      _textListeners[key] = listener;
    }
    if (listener == null) {
      listener ??= _textDisposes.remove(key);

      if (listener != null) {
        assert(!_textListeners.containsKey(key));
        _textListeners[key] = listener;
      }
    }

    listener ??= _textListeners[key];

    assert(!_textDisposes.containsKey(key));

    return listener;
  }

  TextInfo? getTextRef(ListKey key) {
    var textRef = _textRefDisposeCaches.remove(key);
    if (textRef != null) {
      assert(!_textDisposes.containsKey(key));
      assert(!_textRef.containsKey(key));
      _textRef[key] = textRef;
    }
    if (textRef == null) {
      textRef = _textRefDispose.remove(key);
      if (textRef != null) {
        assert(!_textRef.containsKey(key));

        _textRef[key] = textRef;
      }
    }
    textRef ??= _textRef[key];
    if (textRef != null) {
      return TextInfo.text(textRef);
    }
  }

  TextStream putIfAbsent(List keys,
      Future<void> Function(FindTextInfo find, AddTextRef addRef) callback) {
    final key = ListKey(keys);

    final _text = getListener(key);
    if (_text != null) return _text;

    final stream = _textListeners[key] = TextStream(onRemove: (stream) {
      assert(!_textDisposes.containsKey(key));

      if (_textListeners.containsKey(key)) {
        final _stream = _textListeners.remove(key);
        assert(_stream == stream);

        final disposeLength = _textDisposes.length;

        /// 缓存超过100，移到二级缓存，由二级缓存释放
        if (disposeLength >= 50) {
          if (_textDisposesCaches.length > 240) {
            clearDispose(_textDisposesCaches);
          }
          _textDisposesCaches.addAll(_textDisposes);
          _textDisposes.clear();
        }

        _textDisposes[key] = stream;
      } else {
        stream.dispose();
      }
    });

    _textLooper.addEventTask(() async {
      final _list = <ListKey, TextInfo>{};

      /// 确保数据安全
      ///
      /// 异步操作的数据都已被保存，确保 [find] 可以找到数据
      /// [clear] 会把数据清除，毕竟在异步中，无法确定程序的执行顺序
      /// [_textRef] 等缓存中的数据在异步中是不安全的
      TextInfo? innerGetTextRef(List keys) {
        final key = ListKey(keys);
        var info = _list[key];
        info ??= getTextRef(key);
        return info;
      }

      Future<void> add(List keys, TextPainterBuilder builder) async {
        final key = ListKey(keys);
        final _textInfo = innerGetTextRef(keys);

        if (_textInfo != null) {
          _list[key] = _textInfo;
        } else {
          final _text = _textRef[key] = TextRef(await builder(), (ref) {
            if (_textRef.containsKey(key)) {
              final text = _textRef.remove(key);
              assert(text == ref, '$text, $ref');

              if (_textRefDispose.length >= 50) {
                if (_textRefDisposeCaches.length > 100) {
                  _textRefDisposeCaches.clear();
                }
                _textRefDisposeCaches.addAll(_textRefDispose);
                _textRefDispose.clear();
              }
              _textRefDispose[key] = ref;
            }
          });
          _list[key] = TextInfo.text(_text);
        }
      }

      await releaseUI;
      await callback(innerGetTextRef, add);
      await releaseUI;
      stream.setTextInfo(_list.values.toList());
    });

    return stream;
  }
}

typedef AddTextInfo = void Function(TextInfo textInfo);
typedef FindTextInfo = TextInfo? Function(List keys);
typedef AddTextRef = Future<void> Function(List keys, TextPainterBuilder text);

typedef TextPainterBuilder = Future<TextPainter> Function();

typedef TextStreamRemove = void Function(TextStream);

class TextStream {
  TextStream({required this.onRemove});

  final TextStreamRemove onRemove;
  List<TextInfo>? _textInfos;

  bool _done = false;
  bool _error = false;
  void setTextInfo(List<TextInfo>? textInfos, [bool error = false]) {
    assert(!_done);

    _done = true;
    _error = error;

    final list = List.of(_lists);

    list.forEach((listener) => listener(_map(textInfos), error));

    if (_dispose) {
      textInfos?.forEach((info) => info.dispose());
    } else {
      _textInfos = textInfos;
    }
  }

  final _lists = <ListenerFunction>[];
  void addListener(ListenerFunction listener) {
    _lists.add(listener);
    if (!_done) return;

    listener(_map(_textInfos), _error);
  }

  List<TextInfo>? _map(List<TextInfo>? infos) {
    return infos?.map((e) => e.clone()).toList();
  }

  void removeListener(ListenerFunction listener) {
    _lists.remove(listener);

    if (_lists.isEmpty && !_dispose) {
      // 启动微任务
      scheduleMicrotask(() {
        if (_lists.isEmpty) onRemove(this);
      });
    }
  }

  bool _dispose = false;
  void dispose() {
    if (_dispose) return;
    _dispose = true;
    _textInfos?.forEach((info) => info.dispose());
    _textInfos = null;
  }
}

typedef ListenerFunction = void Function(List<TextInfo>? textInfo, bool error);

class TextInfo {
  TextInfo.text(this._text) {
    _text.add(this);
  }
  TextInfo._(this._text);

  final TextRef _text;

  Size get size => _text.text.size;
  TextPainter get painter => _text.text;

  void paint(Canvas canvas, Offset offset) {
    _text.text.paint(canvas, offset);
  }

  TextInfo clone() {
    assert(!_dispose);
    final _clone = TextInfo._(_text);
    _text.add(_clone);
    return _clone;
  }

  bool _dispose = false;
  void dispose() {
    // assert(!_dispose);
    if (_dispose) return;
    _dispose = true;
    _text.remove(this);
  }
}

class TextRef {
  TextRef(this.text, this.onDispose);
  final TextPainter text;
  final void Function(TextRef ref) onDispose;

  final _handle = <TextInfo>{};

  void add(TextInfo info) {
    _handle.add(info);
  }

  void remove(TextInfo info) {
    _handle.remove(info);
    if (_handle.isEmpty) onDispose(this);
  }
}
