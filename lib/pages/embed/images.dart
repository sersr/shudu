import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../event/event.dart';
import '../../utils/binding/widget_binding.dart';
import '../../utils/widget/image_shadow.dart';
import '../../widgets/draw_picture.dart';

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

    return RepaintBoundary(child: child);
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
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder(
        future: Future.value(_future),
        builder: (context, AsyncSnapshot<String?> snap) {
          if (snap.hasData) {
            if (snap.data!.isEmpty) {
              return _errorBuilder(isFirst);
            } else {
              return _Image(
                f: File(snap.data!),
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                boxFit: widget.boxFit,
                builder: _imageBuilder,
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

  Widget _imageBuilder(Widget child, bool hasImage) {
    if (widget.builder != null) child = widget.builder!(child);
    if (widget.shadow)
      child = ImageShadow(child: RepaintBoundary(child: child));

    // return child;
    return RepaintBoundary(
      child: AnimatedOpacity(
          opacity: hasImage ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: RepaintBoundary(child: child)),
    );
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
      // required this.provider,
      this.boxFit = BoxFit.fitHeight})
      : super(key: key);
  // final ImageProvider provider;
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
  // late final imageLooper = nop.imageLooper;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _getImage();
    _sub();
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.provider != oldWidget.provider) {
    //   _getImage();
    // }
    if (widget.f.path != oldWidget.f.path ||
        widget.height != oldWidget.height ||
        widget.width != oldWidget.width) {
      _sub();
    }
  }

  PictureInfo? pictureInfo;
  PictureListener? listener;

  void _sub() {
    final _ofile = widget.f;

    final width = widget.width;
    final height = widget.height;
    final _listener =
        nop.preCache(_ofile, cacheWidth: width, cacheHeight: height);
    if (listener != _listener) {
      listener?.removeListener(onListener);
      listener = _listener;
      _listener.addListener(onListener);
    }
  }

  var _error = false;
  void onListener(PictureInfo? img, bool error) {
    setState(() {
      pictureInfo?.dispose();
      pictureInfo = img;
      _error = error;
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener?.removeListener(onListener);
    pictureInfo?.dispose();
    pictureInfo = null;
  }

  @override
  Widget build(BuildContext context) {
    // final image = _ImageWidget(image: this.image);
    final image = PictureWidget(info: pictureInfo);
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

class _ImageWidget extends LeafRenderObjectWidget {
  _ImageWidget({this.image});

  final ui.Image? image;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ImageRender(image: image?.clone());
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _ImageRender renderObject) {
    renderObject..image = image?.clone();
  }
}

class _ImageRender extends RenderBox {
  _ImageRender({ui.Image? image}) : _image = image;

  ui.Image? _image;
  ui.Image? get image => _image;
  set image(ui.Image? i) {
    if (i != null && _image != null && i.isCloneOf(_image!)) {
      i.dispose();
      return;
    }
    _image?.dispose();

    _image = i;
    markNeedsLayout();
  }

  Size _sizeForConstraints(BoxConstraints constraints) {
    if (_image == null) return constraints.smallest;

    return constraints.constrainSizeAndAttemptToPreserveAspectRatio(Size(
      _image!.width.toDouble(),
      _image!.height.toDouble(),
    ));
  }

  @override
  ui.Size computeDryLayout(BoxConstraints constraints) {
    return _sizeForConstraints(constraints);
  }

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    _paint(context, offset);
  }

  final cPaint = Paint();
  void _paint(PaintingContext context, ui.Offset offset) {
    final canvas = context.canvas;
    final _image = image;
    if (_image != null) {
      final rect = offset & size;
      final imgRect = Rect.fromLTWH(
          0, 0, _image.width.toDouble(), _image.height.toDouble());
      canvas.drawImageRect(_image, imgRect, rect, cPaint);

      // canvas.drawRect(rect, Paint()..color = Colors.yellow);
      // canvas.drawRect(imgRect, Paint()..color = Colors.cyan);
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    _image = null;
    super.dispose();
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;
}
