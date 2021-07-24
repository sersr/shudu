import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../widgets/list_key.dart';
import '../../widgets/picture_info.dart';
import '../utils.dart';

class ImageCacheLoop {
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

  final _pictures = <ListKey, PictureStream>{};
  final _imgLooper = EventLooper();
  final _pathLooper = EventLooper(channels: 4);

  final _pictureDisposes = <ListKey, PictureStream>{};

  PictureStream? getImage(ListKey key) {
    var listener = _pictures[key];

    if (listener == null) {
      listener = _pictureDisposes.remove(key);

      if (listener != null) {
        _pictures[key] = listener;
      }
    }

    assert(!_pictureDisposes.containsKey(key));
    assert(listener == null || listener.success || !listener.done);
    return listener;
  }

  void clearDispose(Map<ListKey, PictureStream> map) {
    print('image dispose: ${map.length}');
    final _map = List.of(map.values);
    map.clear();

    Timer.run(() async {
      for (final stream in _map) {
        await releaseUI;
        stream.dispose();
      }
    });
  }

  PictureStream preCacheBuilder(
    List keys, {
    required Future<void> Function(Future<LoadStatus> Function(),
            Future<void> Function(ui.Image? image, bool error) picture)
        callback,
  }) {
    final key = ListKey(keys);
    final _img = getImage(key);

    if (_img != null) {
      Log.i('contains');
      return _img;
    }

    final stream = _pictures[key] = PictureStream(onRemove: (stream) {
      assert(!_pictureDisposes.containsKey(key));

      final _stream = _pictures[key];
      if (_stream == stream) _pictures.remove(key);

      if (stream.success) {
        if (_stream != null) {
          if (_pictureDisposes.length > 650) {
            final keyFirst = _pictureDisposes.keys.first;
            _pictureDisposes.remove(keyFirst)?.dispose();
          }

          _pictureDisposes[key] = stream;
        }
      } else {
        stream.dispose();
      }
    });
    Future<LoadStatus> _defLoad() async {
      await releaseUI;

      if (!stream.hasListener) {
        Log.e('stream：hasListener');
        assert(stream.close, '同步：应正确使用 addListener, removeListener 并至少使用一次');

        // 如果没有正确的使用 [addListener] 和 [removeListener]
        // 会一直保存引用
        //
        // 有可能已被移除，而又有相同的 [key] 添加
        // 添加验证
        if (_pictures.containsKey(key)) {
          final _stream = _pictures[key];
          if (stream == _stream) {
            _pictures.remove(key);
          }
        }
        return LoadStatus.inactive;
      }

      if (stream.defLoad) {
        //                              key: 标明这是一个新任务
        // _imgLooper.addEventTask(_inner, key: Object());
        return LoadStatus.defLoad;
      }
      return LoadStatus.active;
    }

    callback(_defLoad, (ui.Image? image, bool error) async {
      PictureInfo? picture;

      if (image != null) picture = PictureInfo.picture(image);

      await releaseUI;
      stream.setPicture(picture?.clone(), error);
      await _imgLooper.scheduler.endOfFrame;
      picture?.dispose();
    });

    return stream;
  }

  PictureStream preCache(File f,
      {required double cacheWidth,
      required double cacheHeight,
      BoxFit fit = BoxFit.fitHeight}) {
    return preCacheBuilder([f.path, cacheWidth, cacheHeight, fit],
        callback: (defLoad, setImage) async {
      final w = ui.window;
      Future<void> _getData() async {
        ui.Image? image;
        var error = false;

        try {
          await releaseUI;
          final bytes = await f.readAsBytes();
          await releaseUI;

          if (fit == BoxFit.fitHeight) {
            image = await _decode(bytes,
                cacheHeight: (cacheHeight * w.devicePixelRatio).toInt());
          } else {
            image = await _decode(bytes,
                cacheWidth: (cacheWidth * w.devicePixelRatio).toInt());
          }
          await releaseUI;
        } catch (e) {
          Log.e('e: $e');
          error = true;
        } finally {
          await setImage(image?.clone(), error);
          image?.dispose();
        }
      }

      _imgLooper.addEventTask(() => _def(_imgLooper, defLoad, _getData));
    });
  }

  Future<T?> _def<T>(EventLooper looper, Future<LoadStatus> Function() defLoad,
      FutureOr<T?> Function() callback) async {
    final _load = await defLoad();
    switch (_load) {
      case LoadStatus.defLoad:
        looper.currentTask?.loop = true;
        return null;
      case LoadStatus.inactive:
        return null;

      case LoadStatus.active:
      default:
    }
    return callback();
  }

  PictureStream preCacheUrl(String url,
      {required double cacheWidth,
      required double cacheHeight,
      required PathFuture getPath,
      BoxFit fit = BoxFit.fitHeight}) {
    return preCacheBuilder([url, cacheWidth, cacheHeight, fit],
        callback: (defLoad, setImage) async {
      final w = ui.window;

      final path = await _pathLooper
          .addEventTask(() => _def(_pathLooper, defLoad, () => getPath(url)));
      if (path == null) {
        Log.w('path == null');
        setImage(null, true);
        return;
      }

      final f = File(path);

      if (!await f.exists()) {
        Log.w('file not exists');
        setImage(null, true);
        return;
      }

      Future<void> _imageTask() async {
        ui.Image? image;
        var error = false;

        try {
          await releaseUI;
          final bytes = await f.readAsBytes();
          await releaseUI;
          if (fit == BoxFit.fitHeight) {
            image = await _decode(bytes,
                cacheHeight: (cacheHeight * w.devicePixelRatio).toInt());
          } else {
            image = await _decode(bytes,
                cacheWidth: (cacheWidth * w.devicePixelRatio).toInt());
          }
          await releaseUI;
        } catch (e) {
          Log.e(e);
          error = true;
        } finally {
          await setImage(image?.clone(), error);
          image?.dispose();
        }
      }

      _imgLooper.addEventTask(() => _def(_imgLooper, defLoad, _imageTask));
    });
  }

  void clear() {
    clearDispose(_pictureDisposes);
    clearDispose(_pictures);
  }
}

typedef PathFuture = FutureOr<String?> Function(String url);
enum LoadStatus {
  defLoad,
  inactive,
  active,
}
