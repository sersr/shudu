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

import '../../widgets/list_key.dart';
import '../../widgets/picture_info.dart';
import '../../widgets/text_builder.dart';
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
    _pictureCache = createPictureCache();
  }

  PictureCache? _pictureCache;

  PictureCache? get pictureCache => _pictureCache;

  PictureCache createPictureCache() {
    return PictureCache();
  }

  @override
  void handleMemoryPressure() {
    super.handleMemoryPressure();
    clear();
    _pictureCache?.clear();
  }

  static NopWidgetsFlutterBinding? get instance => _instance;
  static NopWidgetsFlutterBinding? _instance;

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) NopWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }

  Future<ui.Image> _decode(Uint8List bytes,
      {int? cacheWidth, int? cacheHeight}) async {
    final codec = await PaintingBinding.instance!.instantiateImageCodec(bytes,
        cacheHeight: cacheHeight, cacheWidth: cacheWidth);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static final _pictures = <ListKey, PictureListener>{};
  static final _imgLooper = EventLooper();
  static final _imgLoading = EventLooper();

  PictureListener? getImage(ListKey key) {
    final listener = _pictures[key];
    return listener;
  }

  final _paint = Paint();
  PictureListener preCacheBuilder(
    File f, {
    required double cacheWidth,
    required double cacheHeight,
    required Future<Size> Function(Canvas canvas) callback,
    BoxFit fit = BoxFit.fitHeight,
  }) {
    final key = ListKey([f.path, cacheWidth, cacheHeight, fit]);
    final _img = getImage(key);

    if (_img != null) return _img;

    if (_pictures.length > 700) {
      clear();
      print('clear....${_pictures.length}');
    }
    final listener = _pictures[key] = PictureListener();

    _imgLooper.addEventTask(() async {
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
        _imgLoading.addEventTask(
          () => _imgLoading.scheduler.endOfFrame.then((_) async {
            if (!listener.close && _pictures.containsKey(key)) {
              listener.setPicture(picture?.clone(), error);
            }
            picture?.dispose();
            await releaseUI;
          }),
        );
      }
    });
    return listener;
  }

  PictureListener preCache(File f,
      {required double cacheWidth,
      required double cacheHeight,
      BoxFit fit = BoxFit.fitHeight}) {
    return preCacheBuilder(f,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        fit: fit, callback: (canvas) async {
      final w = ui.window;
      ui.Image? image;

      try {
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

        var height = cacheHeight.toDouble();
        var width = cacheWidth.toDouble();

        await releaseUI;

        final constraints = BoxConstraints(maxHeight: height, maxWidth: width);

        final dst = constraints.constrainSizeAndAttemptToPreserveAspectRatio(
            Size(imageWidth, imageHeight));

        final dstRect = Offset.zero & dst;

        final imageRect = Rect.fromLTWH(0.0, 0.0, imageWidth, imageHeight);
        canvas.drawImageRect(image, imageRect, dstRect, _paint);

        return dst;
      } catch (e) {
        rethrow;
      } finally {
        image?.dispose();
      }
    });
  }

  void clear() {
    _pictures.values.forEach((e) => e.dispose());
    _pictures.clear();
  }
}

PictureCache? get pictureCache =>
    NopWidgetsFlutterBinding.instance?._pictureCache;
