import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../event/event.dart';
import '../../utils/widget/image_shadow.dart';

class ImageResolve extends StatelessWidget {
  const ImageResolve(
      {Key? key, this.img, this.builder, this.boxFit = BoxFit.fitWidth})
      : super(key: key);
  final String? img;
  final Widget Function(Widget)? builder;
  final BoxFit boxFit;
  @override
  Widget build(BuildContext context) {
    if (img == null) return Container();
    final repository = Provider.of<Repository>(context);
    final _future = repository.customEvent.getImagePath(img!);
    return RepaintBoundary(
      child: _futureBuilder(_future),
    );
  }

  Widget _futureBuilder(Future<String> _future, {bool isFirst = true}) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<String?> snap) {
        if (snap.hasData) {
          if (snap.data!.isEmpty) {
            return Container(
              child: Text(''),
            );
          }
          Widget framebuilder(
              context, Widget image, int? frame, bool wasSynchronouslyLoaded) {
            Widget child;
            if (builder != null) {
              child = builder!(image);
            } else {
              child = image;
            }
            if (frame != null) {
              return ImageShadow(child: child);
            } else {
              return Container();
            }
          }

          Widget errorbuilder(context, e, t) {
            final repository = Provider.of<Repository>(context);
            final _future = repository.customEvent.getImagePath(errorImg);
            if (isFirst) {
              return _futureBuilder(_future, isFirst: false);
            }
            return Container(child: Center(child: Text('error')));
          }

          return Image.file(
            File(snap.data!),
            fit: boxFit,
            cacheHeight: (120 * ui.window.devicePixelRatio).toInt(),
            frameBuilder: framebuilder,
            errorBuilder: errorbuilder,
          );
        }
        return Container();
      },
    );
  }
}

class _Image extends StatefulWidget {
  @override
  __ImageState createState() => __ImageState();
}

class __ImageState extends State<_Image> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
