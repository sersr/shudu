import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/binding/widget_binding.dart';

import '../../event/event.dart';
import '../../utils/widget/image_shadow.dart';

typedef ImageBuilder = Widget Function(Widget image);

class ImageResolve extends StatelessWidget {
  const ImageResolve(
      {Key? key,
      this.img,
      this.builder,
      this.boxFit = BoxFit.fitWidth,
      this.shadow = true})
      : super(key: key);
  final String? img;
  final Widget Function(Widget)? builder;
  final BoxFit boxFit;
  final bool shadow;
  @override
  Widget build(BuildContext context) {
    if (img == null) return Container();
    final repository = Provider.of<Repository>(context);
    final _future = repository.bookEvent.customEvent.getImagePath(img!);
    return RepaintBoundary(
      child: _futureBuilder(_future),
    );
  }

  Widget _futureBuilder(FutureOr<String?> _future, {bool isFirst = true}) {
    return FutureBuilder(
      future: Future.value(_future),
      builder: (context, AsyncSnapshot<String?> snap) {
        if (snap.hasData) {
          if (snap.data!.isEmpty) return const SizedBox();

          return _Image(
            provider: FileImage(File(snap.data!)),
            boxFit: boxFit,
            builder: (child) {
              if (builder != null) child = builder!(child);
              if (shadow) child = ImageShadow(child: child);
              return child;
            },
            errorBuilder: (context) {
              final repository = Provider.of<Repository>(context);
              final _future =
                  repository.bookEvent.customEvent.getImagePath(errorImg);
              if (isFirst) {
                return _futureBuilder(_future, isFirst: false);
              }
              return ColoredBox(color: Colors.grey.shade300);
            },
          );
        }
        return Container();
      },
    );
  }
}

class _Image extends StatefulWidget {
  const _Image(
      {Key? key,
      this.builder,
      this.errorBuilder,
      required this.provider,
      this.boxFit = BoxFit.fitHeight})
      : super(key: key);
  final ImageProvider provider;
  final BoxFit boxFit;
  final ImageBuilder? builder;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  ImageState createState() => ImageState();
}

class ImageState extends State<_Image> {
  ImageStream? imageStream;
  ImageInfo? imageInfo;
  final nop = NopWidgetsFlutterBinding.instance!;
  late final imageLooper = nop.imageLooper;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider != oldWidget.provider) {
      _getImage();
    }
  }

  void _getImage() async {
    final _oldImagestream = imageStream;
    final _provider = widget.provider;
    final _resize = nop.getResize(_provider);

    await nop.preCacheImage(_resize);
    if (!mounted || _provider != widget.provider) return;

    imageStream = nop.resolve(_resize);

    if (_oldImagestream?.key != imageStream?.key) {
      final listener = ImageStreamListener(_update, onError: _errorc);
      _oldImagestream?.removeListener(listener);
      imageStream?.addListener(listener);
    }
  }

  void _update(ImageInfo image, bool synchronousCall) {
    setState(() {
      _error = false;
      imageInfo?.dispose();
      imageInfo = image;
    });
  }

  var _error = false;
  void _errorc(Object exception, StackTrace? stackTrace) {
    _error = true;
  }

  @override
  void dispose() {
    imageStream?.removeListener(ImageStreamListener(_update, onError: _errorc));
    imageInfo?.dispose();
    imageInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _ImageWidget(image: imageInfo?.image);

    return imageInfo != null && widget.builder != null
        ? widget.builder!(image)
        : _error && widget.errorBuilder != null
            ? widget.errorBuilder!(context)
            : image;
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
  void paint(PaintingContext context, ui.Offset offset) {
    final canvas = context.canvas;
    if (image != null) {
      final rect = offset & size;
      final imgRect =
          Offset.zero & Size(image!.width.toDouble(), image!.height.toDouble());
      canvas.drawImageRect(image!, imgRect, rect, Paint());

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
