import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../utils/widget/image_shadow.dart';

class ImageResolve extends StatelessWidget {
  const ImageResolve({Key? key, this.img, this.builder, this.width = 112, this.boxFit = BoxFit.fitWidth})
      : super(key: key);
  final String? img;
  final int width;
  final Widget Function(Widget)? builder;
  final BoxFit boxFit;
  @override
  Widget build(BuildContext context) {
    if (img == null) return Container();
    final repository = Provider.of<Repository>(context);
    final _future = repository.saveImage(img!);
    return FutureBuilder(future: _future.then((value) async {
      final exits = await File(value).exists();
      return exits ? value : null;
    }), builder: (context, AsyncSnapshot<String?> snap) {
      if (snap.hasData) {
        if (snap.data!.isEmpty) {
          return Container(
            child: Text(''),
          );
        }
        Widget framebuilder(context, Widget image, int? frame, bool wasSynchronouslyLoaded) {
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
          return Center(
            child: Text('图片加载错误'),
          );
        }

        return Image.file(
          File(snap.data!),
          fit: boxFit,
          cacheWidth: width * ui.window.devicePixelRatio.round(),
          frameBuilder: framebuilder,
          errorBuilder: errorbuilder,
        );
      }
      return Container();
    });
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
