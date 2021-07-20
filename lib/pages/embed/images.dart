import 'dart:async';
import 'dart:io';

// import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shudu/utils/utils.dart';

import '../../event/event.dart';
import '../../utils/binding/widget_binding.dart';
import '../../utils/widget/image_shadow.dart';
import '../../widgets/draw_picture.dart';
import '../../widgets/picture_info.dart';

typedef ImageBuilder = Widget Function(Widget image, bool hasImage);

class ImageResolve extends StatefulWidget {
  const ImageResolve(
      {Key? key,
      this.img,
      this.builder,
      this.error,
      this.boxFit = BoxFit.fitWidth,
      this.shadow = true})
      : super(key: key);
  final String? img;
  final Widget Function(Widget)? builder;
  final BoxFit boxFit;
  final bool shadow;
  final ImageProvider? error;
  @override
  State<ImageResolve> createState() => _ImageResolveState();
}

class _ImageResolveState extends State<ImageResolve> {
  late Repository repository;

  @override
  Widget build(BuildContext context) {
    var _img = widget.img;
    Widget child;

    if (_img == null)
      child = _errorBuilder(true);
    else
      child = _futureBuilder(getPath(_img));

    return RepaintBoundary(child: Center(child: child));
  }

  Future<String?> getPath(String img) {
    return Future.value(repository.bookEvent.customEvent.getImagePath(img));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = context.read<Repository>();
  }

  Widget _futureBuilder(FutureOr<String?> _future, {isFirst = true}) {
    // final ratio = ui.window.devicePixelRatio;
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder(
        future: Future.value(_future),
        builder: (context, AsyncSnapshot<String?> snap) {
          if (snap.hasData) {
            if (snap.data!.isEmpty) {
              return _errorBuilder(isFirst);
            } else {
              // return Image.file(
              //   File(snap.data!),
              //   // cacheHeight: (constraints.maxHeight * ratio).toInt(),
              //   cacheWidth: (constraints.maxWidth * ratio).toInt(),
              //   fit: BoxFit.fitHeight,
              //   frameBuilder: (context, child, count, sync) {
              //     return _imageBuilder(child, sync, count != null);
              //   },
              //   errorBuilder:
              //       (context, Object exception, StackTrace? stackTrace) {
              //     return _errorBuilder(isFirst);
              //   },
              // );
              return _Image(
                f: File(snap.data!),
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                boxFit: widget.boxFit,
                builder: (child, hasImage) =>
                    _imageBuilder(child, false, hasImage),
                errorBuilder: (_) => _errorBuilder(isFirst),
              );
            }
          }
          return const SizedBox();
        },
      );
    });
  }

  Widget _errorBuilder(bool isFirst) {
    if (isFirst) {
      final error = widget.error;
      return error != null
          ? Image(image: error, fit: widget.boxFit)
          : _futureBuilder(getPath(errorImg), isFirst: false);
    }
    return const SizedBox();
  }

  Widget _imageBuilder(Widget child, bool sync, bool hasImage) {
    if (hasImage) {
      if (widget.builder != null) child = widget.builder!(child);
      if (widget.shadow) child = ImageShadow(child: child);
      if (sync) return child;
    }
    return child;
    // return AnimatedOpacity(
    //     opacity: hasImage ? 1 : 0,
    //     duration: const Duration(milliseconds: 300),
    //     child: child);
  }
}

class _Image extends StatefulWidget {
  const _Image(
      {Key? key,
      this.builder,
      this.errorBuilder,
      required this.f,
      required this.height,
      required this.width,
      this.boxFit = BoxFit.fitHeight})
      : super(key: key);

  final File f;
  final BoxFit boxFit;
  final ImageBuilder? builder;
  final double height;
  final double width;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  ImageState createState() => ImageState();
}

class ImageState extends State<_Image> {
  final nop = NopWidgetsFlutterBinding.instance!;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sub();
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.f.path != oldWidget.f.path ||
        widget.height != oldWidget.height ||
        widget.width != oldWidget.width) {
      _sub();
    }
  }

  PictureInfo? pictureInfo;
  PictureStream? listener;

  void _sub() {
    final _ofile = widget.f;

    final width = widget.width;
    final height = widget.height;
    final _listener =
        nop.preCache(_ofile, cacheWidth: width, cacheHeight: height);

    if (listener != _listener) {
      listener?.removeListener(PictureListener(onListener, load: onDefLoad));
      // Log.w('removeListener  ${listener.hashCode}');

      _listener.addListener(PictureListener(onListener, load: onDefLoad));
      listener = _listener;
      // Log.w('addListener  ${listener.hashCode}');
    }
  }

  var _error = false;
  void onListener(PictureInfo? img, bool error, bool sync) {
    assert(mounted);

    _notifier.value = !_notifier.value;
    setState(() {
      pictureInfo?.dispose();
      pictureInfo = img;
      _error = error;
    });
  }

  final _notifier = ValueNotifier(false);

  bool onDefLoad() =>
      mounted && Scrollable.recommendDeferredLoadingForContext(context);

  @override
  void dispose() {
    listener?.removeListener(PictureListener(onListener, load: onDefLoad));
    // Log.w('dispose  ${listener.hashCode}');
    listener = null;

    pictureInfo?.dispose();
    pictureInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = PictureWidget(info: pictureInfo);
    // final imageRaw = RawImage(image: );
    // AnimatedBuilder(
    //     animation: _notifier,
    //     builder: (context, _) {
    //       return PictureWidget(info: pictureInfo);
    //     });
    if (_error) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context);
      }
    } else {
      if (widget.builder != null) {
        return widget.builder!(image, pictureInfo != null);
      }
    }

    return image;
  }
}
