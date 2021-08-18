import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../event/event.dart';
import '../provider/provider.dart';
import 'image_shadow.dart';

class ImageResolve extends StatefulWidget {
  const ImageResolve(
      {Key? key,
      this.img,
      this.builder,
      this.errorBuilder,
      this.placeholder,
      this.boxFit = BoxFit.fitWidth,
      this.shadow = true})
      : super(key: key);
  final String? img;
  final Widget Function(Widget)? builder;
  final Widget Function(BuildContext)? errorBuilder;
  final BoxFit boxFit;
  final bool shadow;
  final Widget? placeholder;

  @override
  State<ImageResolve> createState() => _ImageResolveState();
}

class _ImageResolveState extends State<ImageResolve> {
  @override
  Widget build(BuildContext context) {
    final child = _layoutBuilder();

    return RepaintBoundary(child: Center(child: child));
  }

  late Repository repository;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = context.read();
  }

  String? path;
  final ratio = ui.window.devicePixelRatio;

  Widget _layoutBuilder() {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      final _img = widget.img;

      return _img == null
          ? _errorBuilder(true, width, height)
          : Selector<OptionsNotifier, bool>(
              selector: (_, opt) => opt.options.useImageCache ?? false,
              builder: (context, useImageCache, _) {
                if (!useImageCache) {
                  final repository = context.read<Repository>();

                  final getImageBytes = repository.bookEvent.getImageBytes;
                  final rw = (width * ratio).toInt();
                  final plh = CallbackWithKeyImage(
                          keys: errorImg,
                          callback: () => getImageBytes(errorImg))
                      .resize(width: rw);
                  Widget child = FadeInImage(
                    // width: width,
                    fit: BoxFit.contain,
                    placeholder: plh,
                    image: CallbackWithKeyImage(
                        keys: _img,
                        callback: () => getImageBytes(_img)).resize(width: rw),
                    imageErrorBuilder: (_, o, s) {
                      return Image(image: plh, fit: BoxFit.contain);
                    },
                    placeholderErrorBuilder: (_, o, s) {
                      return const SizedBox();
                    },
                  );
                  if (widget.builder != null) child = widget.builder!(child);
                  // if (widget.shadow) child = ImageShadow(child: child);
                  return child;
                }

                return _useMemoryImage(_img, height, width);
              },
            );
    });
  }

  Widget _useMemoryImage(String _img, double height, double width) {
    final bookEvent = repository.bookEvent;
    final callback = bookEvent.getImageBytes;
    // final image = _errorBuilder(true, width, height);

    return ImageFuture.memory(
      imageKey: [_img, callback],
      height: height,
      width: width,
      boxFit: widget.boxFit,
      getMemory: () => callback(_img),
      builder: (child, hasImage) => _imageBuilder(child, false, hasImage),
      errorBuilder: (context) => _errorBuilder(true, width, height),
    );
  }

  Widget _errorBuilder(bool isFirst, double width, double height) {
    if (isFirst) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context);
      } else {
        final callback = repository.bookEvent.getImageBytes;
        return ImageFuture.memory(
          imageKey: [errorImg, callback],
          width: width,
          height: height,
          boxFit: widget.boxFit,
          getMemory: () => callback(errorImg),
          builder: (child, hasImage) => _imageBuilder(child, false, hasImage),
          errorBuilder: (context) => _errorBuilder(false, width, height),
        );
      }
    }
    return const SizedBox();
  }

  Widget _imageBuilder(Widget child, bool sync, bool hasImage) {
    if (hasImage) {
      if (widget.builder != null) child = widget.builder!(child);
      if (widget.shadow) child = ImageShadow(child: child);
      // if (sync) return child;
      // } else {
      //   return widget.placeholder ?? child;
    }
    // return child;
    // return AnimatedSwitcher(
    //     child: hasImage ? child : place,
    //     duration: const Duration(milliseconds: 500));
    return AnimatedOpacity(
        opacity: hasImage ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
