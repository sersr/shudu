import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../event/event.dart';
import '../../utils/binding/widget_binding.dart';
import '../../utils/widget/image_shadow.dart';

typedef ImageBuilder = Widget Function(Widget image, bool hasImage);

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
    final repository = context.read<Repository>();
    var _img = img ?? errorImg;

    final _future = repository.bookEvent.customEvent.getImagePath(_img);
    return RepaintBoundary(child: _futureBuilder(_future));
  }

  Widget _futureBuilder(FutureOr<String?> _future, {bool isFirst = true}) {
    return FutureBuilder(
      future: Future.value(_future),
      builder: (context, AsyncSnapshot<String?> snap) {
        final repository = context.read<Repository>();

        if (snap.hasData) {
          if (snap.data!.isEmpty) {
            if (isFirst) {
              final _future =
                  repository.bookEvent.customEvent.getImagePath(errorImg);
              return _futureBuilder(_future, isFirst: false);
            }
          } else {
            return _Image(
              provider: FileImage(File(snap.data!)),
              boxFit: boxFit,
              builder: (child, hasImage) {
                if (hasImage) {
                  if (builder != null) child = builder!(child);
                  if (shadow) child = ImageShadow(child: child);
                }
                return RepaintBoundary(
                  child: AnimatedOpacity(
                      opacity: hasImage ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      child: child),
                );
              },
              errorBuilder: (context) {
                if (isFirst) {
                  final _future =
                      repository.bookEvent.customEvent.getImagePath(errorImg);
                  return _futureBuilder(_future, isFirst: false);
                }
                return const SizedBox();
              },
            );
          }
        }
        return const SizedBox();
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

  void _getImage() {
    final _oldImagestream = imageStream;
    final _provider = widget.provider;
    final _resize = nop.getResize(_provider);
    sync = null;

    /// [FileImage] 是同步状态的
    nop.preCacheImage(_resize).then((_) {
      if (!mounted || _provider != widget.provider) return;
      sync ??= true;

      imageStream = nop.resolve(_resize);

      if (_oldImagestream?.key != imageStream?.key) {
        final listener = ImageStreamListener(_update, onError: _errorc);
        _oldImagestream?.removeListener(listener);
        imageStream?.addListener(listener);
      }
    });

    sync ??= false;
  }

  bool? sync;
  // late final _loadLooper = EventLooper();

  void _update(ImageInfo image, bool _) {
    void _call() {
      setState(() {
        _error = false;
        imageInfo?.dispose();
        imageInfo = image;
      });
    }

    // if (sync != true)
    //   imageLooper.addEventTask(() {
    //     if (mounted && sync != true)
    //       _call();
    //     else
    //       image.dispose();
    //   });
    // else
    _call();
  }

  var _error = false;
  void _errorc(Object exception, StackTrace? stackTrace) {
    setState(() {
      _error = true;
    });
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

    if (_error) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context);
      }
    } else {
      if (widget.builder != null) {
        return widget.builder!(image, imageInfo?.image != null);
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
