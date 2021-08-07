import 'dart:io';
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

  String? path;

  Widget _layoutBuilder() {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      final _img = widget.img;
      final ratio = ui.window.devicePixelRatio;
      final repository = context.read<Repository>();
      return _img == null
          ? _errorBuilder(true, width, height, context)
          : Selector<OptionsNotifier, bool>(
              selector: (_, opt) => opt.options.useImageCache ?? false,
              builder: (context, useImageCache, _) {
                if (!useImageCache) {
                  final repository = context.read<Repository>();
                  final getPath = repository.bookEvent.getImagePath(_img);
                  return FutureBuilder<String?>(
                      initialData: path,
                      future: Future.value(getPath)
                        ..then((value) => path = value),
                      builder: (context, snap) {
                        final data = snap.data;
                        if (data != null && data.isNotEmpty) {
                          final f = File(snap.data!);
                          return Image.file(
                            f,
                            // cacheHeight: (constraints.maxHeight * ratio).toInt(),
                            cacheWidth: (width * ratio).toInt(),
                            fit: widget.boxFit,
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
                        return widget.placeholder ?? const SizedBox();
                      });
                }
                return ImageFuture(
                  url: _img,
                  height: height,
                  width: width,
                  boxFit: widget.boxFit,
                  getPath: repository.bookEvent.getImagePath,
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
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context);
      } else {
        final repository = context.read<Repository>();
        return ImageFuture(
          url: errorImg,
          width: width,
          height: height,
          boxFit: widget.boxFit,
          getPath: repository.bookEvent.getImagePath,
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
      if (widget.builder != null) child = widget.builder!(child);
      if (widget.shadow) child = ImageShadow(child: child);
      // if (sync) return child;
      // } else {
      //   return widget.placeholder ?? child;
    }
    // return child;
    return AnimatedOpacity(
        opacity: hasImage ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
