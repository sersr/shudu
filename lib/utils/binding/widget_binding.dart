
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../widgets/text_stream.dart';
import 'binding.dart';
import 'image_cache.dart';

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
    _textCache = TextCache();
    _imageCacheLoop = ImageCacheLoop();
  }

  TextCache? _textCache;

  TextCache? get textCache => _textCache;

  ImageCacheLoop? _imageCacheLoop;
  ImageCacheLoop? get imageCacheLoop => _imageCacheLoop;

  @override
  void handleMemoryPressure() {
    super.handleMemoryPressure();
    _imageCacheLoop?.clear();
    _textCache?.clear();
  }

  static NopWidgetsFlutterBinding? get instance => _instance;
  static NopWidgetsFlutterBinding? _instance;

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) NopWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }
}

TextCache? get textCache => NopWidgetsFlutterBinding.instance?.textCache;
ImageCacheLoop? get imageCacheLoop =>
    NopWidgetsFlutterBinding.instance?.imageCacheLoop;
