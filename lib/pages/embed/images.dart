import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../utils/widget/image_shadow.dart';

/// 不支持web
class ImageResolve extends StatelessWidget {
  const ImageResolve({Key? key, this.img, this.builder, this.width = 112}) : super(key: key);
  final String? img;
  final int width;
  final Widget Function(Widget)? builder;
  @override
  Widget build(BuildContext context) {
    final _future = Provider.of<BookRepository>(context).saveImage(img!);
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<String> snap) {
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
              return FutureBuilder(
                builder: (context, AsyncSnapshot<String> es) {
                  if (es.hasData) {
                    Widget eframebuilder(context, Widget image, int? frame, bool wasSynchronouslyLoaded) {
                      if (frame != null) {
                        return ImageShadow(child: image);
                      } else {
                        return Container();
                      }
                    }

                    return Image.file(File(es.data!),
                        fit: BoxFit.fitWidth, cacheWidth: width * 2, frameBuilder: eframebuilder);
                  }
                  return Container();
                },
                future: Provider.of<BookRepository>(context).saveImage('guizhenwuji.jpg'),
              );
            }

            return Image.file(
              File(snap.data!),
              fit: BoxFit.fitWidth,
              cacheWidth: width * ui.window.devicePixelRatio.round(),
              frameBuilder: framebuilder,
              errorBuilder: errorbuilder,
            );
          }
          return Container();
        });
  }
}
