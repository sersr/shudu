import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../event/event.dart';
import '../../utils/binding/widget_binding.dart';
import '../../widgets/draw_picture.dart';
import '../../widgets/picture_info.dart';
import 'images.dart';

class ImageFuture extends StatefulWidget {
  const ImageFuture(
      {Key? key,
      this.builder,
      this.errorBuilder,
      required this.url,
      required this.height,
      required this.width,
      this.boxFit = BoxFit.fitWidth})
      : super(key: key);

  final String url;
  final BoxFit boxFit;
  final ImageBuilder? builder;
  final double height;
  final double width;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  ImageState createState() => ImageState();
}

class ImageState extends State<ImageFuture> {
  late Repository repository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = context.read<Repository>();
    _sub();
  }

  @override
  void didUpdateWidget(covariant ImageFuture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url ||
        widget.height != oldWidget.height ||
        widget.width != oldWidget.width ||
        _error) {
      _sub();
    }
  }

  PictureInfo? pictureInfo;
  PictureStream? listener;

  void _sub() {
    final url = widget.url;
    final width = widget.width;
    final height = widget.height;

    final _listener = imageCacheLoop!.preCacheUrl(url,
        getPath: repository.bookEvent.getImagePath,
        cacheWidth: width,
        cacheHeight: height,
        fit: widget.boxFit);

    if (listener != _listener) {
      final l = PictureListener(onListener, load: onDefLoad);
      listener?.removeListener(l);
      _listener.addListener(l);
      listener = _listener;
    }
  }

  var _error = false;
  void onListener(PictureInfo? img, bool error, bool sync) {
    assert(mounted);

    setState(() {
      pictureInfo?.dispose();
      pictureInfo = img;
      _error = error;
    });
  }

  bool onDefLoad() =>
      mounted && Scrollable.recommendDeferredLoadingForContext(context);

  @override
  void dispose() {
    listener?.removeListener(PictureListener(onListener, load: onDefLoad));
    listener = null;

    pictureInfo?.dispose();
    pictureInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
