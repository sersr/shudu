import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../widgets/text_stream.dart';

import '../../widgets/list_key.dart';
import '../../widgets/picture_info.dart';
import '../tools/event_callback_looper.dart';
import '../utils.dart';
import 'binding.dart';

typedef DeffLoad = bool Function();

class NopWidgetsFlutterBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        NopGestureBinding,
        WidgetsBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    // _pictureCache = createPictureCache();
    _textCache = createTextCache();
  }

  // PictureCache? _pictureCache;
  TextCache? _textCache;

  // PictureCache? get pictureCache => _pictureCache;
  TextCache? get textCache => _textCache;

  // PictureCache createPictureCache() {
  //   return PictureCache();
  // }

  TextCache createTextCache() {
    return TextCache();
  }

  @override
  void handleMemoryPressure() {
    super.handleMemoryPressure();
    clear();
    _textCache?.clear();
    // _pictureCache?.clear();
  }

  static NopWidgetsFlutterBinding? get instance => _instance;
  static NopWidgetsFlutterBinding? _instance;

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) NopWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }

  Future<ui.Image> _decode(Uint8List bytes,
      {int? cacheWidth, int? cacheHeight}) async {
    await releaseUI;
    final codec = await imageCodec(bytes,
        cacheHeight: cacheHeight, cacheWidth: cacheWidth);
    final frameInfo = await codec.getNextFrame();
    await releaseUI;

    return frameInfo.image;
  }

  Future<ui.Codec> imageCodec(
    Uint8List list, {
    int? cacheWidth,
    int? cacheHeight,
    bool allowUpscaling = false,
  }) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(list);
    await releaseUI;

    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    await releaseUI;

    if (!allowUpscaling) {
      if (cacheWidth != null && cacheWidth > descriptor.width) {
        cacheWidth = descriptor.width;
      }
      if (cacheHeight != null && cacheHeight > descriptor.height) {
        cacheHeight = descriptor.height;
      }
    }
    buffer.dispose();
    return descriptor.instantiateCodec(
      targetWidth: cacheWidth,
      targetHeight: cacheHeight,
    );
  }

  static final _pictures = <ListKey, PictureStream>{};
  static final _imgLooper = EventLooper();

  final _pictureDisposes = <ListKey, PictureStream>{};
  final _pictureDisposesCaches = <ListKey, PictureStream>{};

  static EventLooper get imgDefLoading => _imgLooper;
  PictureStream? getImage(ListKey key) {
    var listener = _pictures[key];
    if (listener == null) {
      listener = _pictureDisposes.remove(key);

      if (listener != null) {
        assert(!_pictureDisposesCaches.containsKey(key));
        _pictures[key] = listener;
      }
    }
    if (listener == null) {
      listener = _pictureDisposesCaches.remove(key);
      if (listener != null) _pictures[key] = listener;
    }
    assert(!_pictureDisposes.containsKey(key));
    assert(!_pictureDisposesCaches.containsKey(key));

    return listener;
  }

  void clearDispose(Map<ListKey, PictureStream> map) {
    print('dispose: ${map.length}');
    map.values.forEach((stream) => stream.dispose());
    map.clear();
  }

  final _paint = Paint();

  PictureStream preCacheBuilder(
    List keys, {
    required Future<Size> Function(Canvas canvas) callback,
    BoxFit fit = BoxFit.fitWidth,
  }) {
    final key = ListKey(keys);
    final _img = getImage(key);

    if (_img != null) return _img;

    final stream = _pictures[key] = PictureStream(onRemove: (stream) {
      assert(!_pictureDisposes.containsKey(key));

      if (_pictures.containsKey(key)) {
        final _stream = _pictures.remove(key);
        Log.w('constains ,${stream.success}: ${stream.hasListener}');
        assert(_stream == stream);

        if (stream.success) {
          final disposeLength = _pictureDisposes.length;

          if (_pictureDisposesCaches.length > 670) {
            final keyFirst = _pictureDisposesCaches.keys.first;
            _pictureDisposesCaches.remove(keyFirst)?.dispose();
          }
          if (disposeLength >= 100) {
            // if (_pictureDisposesCaches.length > 400) {
            //   for (var i = 0; i <= 10; i++) {
            //     final keyFirst = _pictureDisposesCaches.keys.first;
            //     _pictureDisposesCaches.remove(keyFirst)?.dispose();
            //   }
            // }
            final keyFirst = _pictureDisposes.keys.first;

            final firstValue = _pictureDisposes.remove(keyFirst);
            if (firstValue != null) {
              _pictureDisposesCaches[keyFirst] = firstValue;
            }
          }

          _pictureDisposes[key] = stream;
        } else {
          stream.dispose();
        }
      } else {
        Log.e('严重错误：_pictures 没有此对象');
        stream.dispose();
      }
    });

    Future<void> _inner() async {
      await releaseUI;
      // stream.addListener 和 stream.removeListener 是 `同步关系` 的
      // stream.hasListener 不可能出现分歧
      //
      // 异步操作：stream.onRemove 可能先执行
      // 如果再次请求相同key的话，会 new 一个 PcitureStream
      //
      // 在判断 hasListener 之前，已经异步等待，
      // 如果判断成功，onRemove 应该已经成功执行
      if (!stream.hasListener) {
        // ignore: invalid_use_of_visible_for_testing_member
        assert(stream.schedule);

        if (_pictures.containsKey(key)) {
          Log.w('containsKey');

          final newStream = _pictures[key];
          // 匹对是否是同一个 对象
          assert(!identical(stream, newStream));
          if (identical(stream, newStream)) {
            Log.e('newStream 和 stream 是同一个对象, 严重错误！！！');
            _pictures.remove(key);
          }
        }

        // Log.w('no listener ${stream.hashCode}');
        return;
      }

      if (stream.defLoad) {
        //                              key: 标明这是一个新任务
        _imgLooper.addEventTask(_inner, key: Object());
        // _imgLooper.addEventTask(() => _inner());
        return;
      }
      PictureInfo? picture;

      var error = false;

      try {
        final recoder = ui.PictureRecorder();
        final canvas = Canvas(recoder);
        await releaseUI;
        final dst = await callback(canvas);
        picture = PictureInfo.picture(recoder.endRecording(), dst);
      } catch (e) {
        error = true;
      } finally {
        await releaseUI;
        stream.setPicture(picture?.clone(), error);
        await _imgLooper.scheduler.endOfFrame;
        picture?.dispose();
      }
    }

    _imgLooper.addEventTask(_inner);

    return stream;
  }

  PictureStream preCache(File f,
      {required double cacheWidth,
      required double cacheHeight,
      BoxFit fit = BoxFit.fitHeight}) {
    return preCacheBuilder([f.path, cacheWidth, cacheHeight, fit],
        callback: (canvas) async {
      final w = ui.window;
      ui.Image? image;

      try {
        await releaseUI;
        // final read = await f.open();
        // // await read.lock();
        // final end = await read.length();
        // final buffer = <int>[];
        // final each = end ~/ 5;
        // while (true) {
        //   final b = await read.read(each);
        //   if (b.isEmpty) break;
        //   buffer.addAll(b);
        //   await releaseUI;
        // }
        // await read.close();
        // final bytes = Uint8List.fromList(buffer);
        final bytes = await f.readAsBytes();
        await releaseUI;

        if (fit == BoxFit.fitHeight) {
          image = await _decode(bytes,
              cacheHeight: (cacheHeight * w.devicePixelRatio).toInt());
        } else {
          image = await _decode(bytes,
              cacheWidth: (cacheWidth * w.devicePixelRatio).toInt());
        }

        final imageHeight = image.height.toDouble();
        final imageWidth = image.width.toDouble();

        await releaseUI;

        final constraints =
            BoxConstraints(maxHeight: cacheHeight, maxWidth: cacheWidth);

        final dst = constraints.constrainSizeAndAttemptToPreserveAspectRatio(
            Size(imageWidth, imageHeight));

        final dstRect = Offset.zero & dst;

        final imageRect = Rect.fromLTWH(0.0, 0.0, imageWidth, imageHeight);
        canvas.drawImageRect(image, imageRect, dstRect, _paint);
        await releaseUI;

        return dst;
      } catch (e) {
        Log.e('e: $e');
        rethrow;
      } finally {
        image?.dispose();
      }
    });
  }

  void clear() {
    clearDispose(_pictureDisposesCaches);
    clearDispose(_pictureDisposes);
    clearDispose(_pictures);
  }
}

// PictureCache? get pictureCache =>
//     NopWidgetsFlutterBinding.instance?.pictureCache;

TextCache? get textCache => NopWidgetsFlutterBinding.instance?.textCache;
