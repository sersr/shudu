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

import '../../widgets/async_text.dart';
import '../../widgets/draw_picture.dart';
import '../tools/event_callback_looper.dart';
import '../utils.dart';
import 'binding.dart';

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
  }

  @override
  void handleMemoryPressure() {
    super.handleMemoryPressure();
    clear();
  }

  static NopWidgetsFlutterBinding? get instance => _instance;
  static NopWidgetsFlutterBinding? _instance;

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) NopWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }

  // images cache loading queue
  // final imageLooper = EventLooper();
  // final imagesTasks = <Object, Future>{};

  // Future<void> preCacheResizeImage(ImageProvider provider) {
  //   final resize = getResize(provider);
  //   return preCacheImage(resize);
  // }

  // ResizeImage getResize(ImageProvider key) {
  //   return ResizeImage(key, width: 160);
  // }

  // /// [FileImage] 缓存
  // Future<void> preCacheImage(ImageProvider provider) {
  //   return provider.obtainKey(ImageConfiguration.empty).then((_key) {
  //     final contain = imageCache?.containsKey(_key) ?? false;

  //     if (!contain) {
  //       return imagesTasks.putIfAbsent(
  //         _key,
  //         () => imageLooper.addEventTask(
  //           () async {
  //             await releaseUI;
  //             if (imageCache?.containsKey(_key) ?? false) return;
  //             await _preImage(provider);
  //             await imageLooper.scheduler.endOfFrame;
  //           },
  //         ),
  //       )..whenComplete(() => imagesTasks.remove(_key));
  //     } else {
  //       return SynchronousFuture(null);
  //     }
  //   });
  //   // }
  // }

  // ImageStream resolve(ImageProvider provider) {
  //   return provider.resolve(ImageConfiguration.empty);
  // }

  // Future<void> _preImage(ImageProvider provider) {
  //   final completer = Completer<void>();
  //   final stream = resolve(provider);
  //   ImageStreamListener? listener;

  //   listener = ImageStreamListener(
  //     (ImageInfo? image, bool sync) {
  //       if (!completer.isCompleted) {
  //         completer.complete();
  //       }
  //       imageLooper.scheduler.addPostFrameCallback((_) {
  //         stream.removeListener(listener!);
  //       });
  //     },
  //     onError: (Object exception, StackTrace? stackTrace) {
  //       if (!completer.isCompleted) {
  //         completer.complete();
  //       }
  //       stream.removeListener(listener!);
  //     },
  //   );

  //   stream.addListener(listener);
  //   return completer.future;
  // }

  Future<ui.Image> _decode(Uint8List bytes,
      {int? cacheWidth, int? cacheHeight}) async {
    final codec = await PaintingBinding.instance!.instantiateImageCodec(bytes,
        cacheHeight: cacheHeight, cacheWidth: cacheWidth);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static final _pictures = <ListKey, PictureListener>{};
  static final _imgLooper = EventLooper();
  // static final _imageTask = <ListKey, Future>{};
  PictureListener? getImage(ListKey key) {
    final listener = _pictures[key];
    return listener;
  }

  final _paint = Paint();

  PictureListener preCache(File f,
      {required double cacheWidth,
      required double cacheHeight,
      BoxFit fit = BoxFit.fitHeight}) {
    final key = ListKey([f.path, cacheWidth, cacheHeight, fit]);
    final _img = getImage(key);

    if (_img != null) return _img;

    if (_pictures.length > 700) {
      clear();
      print('clear....${_pictures.length}');
    }
    final listener = _pictures[key] = PictureListener();
    final w = ui.window;

    _imgLooper.addEventTask(() async {
      PictureInfo? picture;
      ui.Image? image;

      var error = false;

      try {
        final bytes = await f.readAsBytes();

        if (fit == BoxFit.fitHeight) {
          image = await _decode(bytes,
              cacheHeight: (cacheHeight * w.devicePixelRatio).toInt());
        } else {
          image = await _decode(bytes,
              cacheWidth: (cacheWidth * w.devicePixelRatio).toInt());
        }

        await releaseUI;

        final recoder = ui.PictureRecorder();
        final canvas = Canvas(recoder);

        final imageWidth = image.width.toDouble();
        final imageHeight = image.height.toDouble();

        var height = cacheHeight.toDouble();
        var width = cacheWidth.toDouble();

        final constraints = BoxConstraints(maxHeight: height, maxWidth: width);

        final dst = constraints.constrainSizeAndAttemptToPreserveAspectRatio(
            Size(imageWidth, imageHeight));
        Log.w(
            'Width: $width, $height | $cacheWidth, $cacheHeight | $imageWidth, $imageHeight');

        final dstRect = Offset.zero & dst;
        final imageRect = Rect.fromLTWH(0.0, 0.0, imageWidth, imageHeight);

        canvas.drawImageNine(image, imageRect, dstRect, _paint);

        picture = PictureInfo(PictureMec(recoder.endRecording(), dst));
      } catch (e) {
        error = true;
      } finally {
        if (!listener._dispose && _pictures.containsKey(key)) {
          listener.setPicture(picture?.clone(), error);
        }
        image?.dispose();
        picture?.dispose();
      }
    });
    return listener;
  }

  void clear() {
    _pictures.values.forEach((e) => e.dispose());
    _pictures.clear();
  }
}

// typedef ImageListenerCallback = void Function(ui.Image? image, bool error);

// class ImageFileListener {
//   ImageFileListener();
//   ui.Image? _image;
//   bool _error = false;

//   void setImage(ui.Image? img, [bool error = false]) {
//     final list = List.of(_list);
//     _list.clear();
//     _error = error;

//     list.forEach((element) => element(img?.clone(), error));
//     if (_dispose) {
//       img?.dispose();
//       return;
//     } else {
//       _image = img;
//     }
//   }

//   final _list = <ImageListenerCallback>[];
//   void addListener(ImageListenerCallback callback) {
//     if (_image == null && !_error) {
//       _list.add(callback);
//       return;
//     }
//     callback(_image?.clone(), _error);
//   }

//   void removeListener(ImageListenerCallback callback) {
//     _list.remove(callback);
//   }

//   bool get hasListener => _list.isNotEmpty;

//   bool _dispose = false;
//   void dispose() {
//     if (_dispose) return;
//     _dispose = true;
//     _image?.dispose();
//   }
// }

typedef PictureListenerCallback = void Function(PictureInfo? image, bool error);

class PictureListener {
  PictureListener();
  PictureInfo? _image;
  bool _error = false;

  void setPicture(PictureInfo? img, [bool error = false]) {
    final list = List.of(_list);
    _list.clear();
    _error = error;

    list.forEach((element) => element(img?.clone(), error));
    if (_dispose) {
      img?.dispose();
      return;
    } else {
      _image = img;
    }
  }

  final _list = <PictureListenerCallback>[];
  void addListener(PictureListenerCallback callback) {
    if (_image == null && !_error) {
      _list.add(callback);
      return;
    }
    callback(_image?.clone(), _error);
  }

  void removeListener(PictureListenerCallback callback) {
    _list.remove(callback);
  }

  bool get hasListener => _list.isNotEmpty;

  bool get close => _dispose;

  bool _dispose = false;
  void dispose() {
    if (_dispose) return;
    _dispose = true;
    _image?.dispose();
  }
}
