import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../tools/event_callback_looper.dart';
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

  static NopWidgetsFlutterBinding? get instance => _instance;
  static NopWidgetsFlutterBinding? _instance;

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) NopWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }

  // images cache loading queue
  final imageLooper = EventLooper();
  final imagesTasks = <Object, Future>{};

  ResizeImage getResize(ImageProvider key) {
    return ResizeImage(key, width: 160);
  }

  Future<void> preCacheImage(ImageProvider provider) {
    return provider.obtainKey(ImageConfiguration.empty).then((_key) {
      final contain = imageCache?.containsKey(_key) ?? false;

      if (!contain) {
        return imagesTasks.putIfAbsent(
          _key,
          () => imageLooper.addEventTask(
            () async {
              // await imageLooper.wait();
              if (imageCache?.containsKey(_key) ?? false) return;
              await _preImage(provider);
              await releaseUI;
            },
          ),
        )..whenComplete(() => imagesTasks.remove(_key));
      }
    });
    // }
  }

  ImageStream resolve(ImageProvider provider) {
    return provider.resolve(ImageConfiguration.empty);
  }

  Future<void> _preImage(ImageProvider provider) {
    final completer = Completer<void>();
    final stream = provider.resolve(ImageConfiguration.empty);
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo? image, bool sync) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    stream.addListener(listener);
    return completer.future
      ..whenComplete(() => stream.removeListener(listener!));
  }
}
