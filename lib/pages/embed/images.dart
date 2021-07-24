import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../event/event.dart';
import '../../provider/provider.dart';
import '../../utils/widget/image_shadow.dart';
import 'image_future.dart';

typedef ImageBuilder = Widget Function(Widget image, bool hasImage);

class ImageResolve extends StatelessWidget {
  ImageResolve(
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
  Widget build(BuildContext context) {
    final child = _layoutBuilder();

    return RepaintBoundary(child: Center(child: child));
  }

  Widget _layoutBuilder() {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      final _img = img;
      final ratio = ui.window.devicePixelRatio;
      return _img == null
          ? _errorBuilder(true, width, height, context)
          : Selector<OptionsNotifier, bool>(
              selector: (_, opt) => opt.options.useImageCache ?? false,
              builder: (context, useImageCache, _) {
                if (!useImageCache) {
                  final repository = context.read<Repository>();
                  final path = repository.bookEvent.getImagePath(_img);
                  return FutureBuilder<String?>(
                      future: Future.value(path),
                      builder: (context, snap) {
                        final data = snap.data;
                        if (data != null && data.isNotEmpty) {
                          final f = File(snap.data!);
                          return Image.file(
                            f,
                            // cacheHeight: (constraints.maxHeight * ratio).toInt(),
                            cacheWidth: (width * ratio).toInt(),
                            fit: boxFit,
                            frameBuilder: (_, child, frame, sync) {
                              return _imageBuilder(child, sync, frame != null);
                            },
                            errorBuilder: (context, __, ___) =>
                                _errorBuilder(true, width, height, context),
                          );
                        } else if (snap.connectionState ==
                            ConnectionState.done) {
                          return _errorBuilder(false, width, height, context);
                        }
                        return placeholder ?? const SizedBox();
                      });
                }
                return ImageFuture(
                  url: _img,
                  height: height,
                  width: width,
                  boxFit: boxFit,
                  builder: (child, hasImage) =>
                      _imageBuilder(child, false, hasImage),
                  errorBuilder: (context) =>
                      _errorBuilder(true, width, height, context),
                );
              },
            );
    });
  }

  Widget _errorBuilder(
      bool isFirst, double width, double height, BuildContext context) {
    if (isFirst) {
      if (errorBuilder != null) {
        return errorBuilder!(context);
      } else {
        return ImageFuture(
          url: errorImg,
          width: width,
          height: height,
          boxFit: boxFit,
          builder: (child, hasImage) => _imageBuilder(child, false, hasImage),
          errorBuilder: (context) =>
              _errorBuilder(false, width, height, context),
        );
      }
    }
    return const SizedBox();
  }

  Widget _imageBuilder(Widget child, bool sync, bool hasImage) {
    if (hasImage) {
      if (builder != null) child = builder!(child);
      if (shadow) child = ImageShadow(child: child);
      if (sync) return child;
    } else {
      return placeholder ?? child;
    }
    return child;
    // return AnimatedOpacity(
    //     opacity: hasImage ? 1 : 0,
    //     duration: const Duration(milliseconds: 300),
    //     child: child);
  }
}
