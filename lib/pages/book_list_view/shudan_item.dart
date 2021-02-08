import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shudu/bloc/book_repository.dart';
import 'package:provider/provider.dart';
import 'package:shudu/bloc/text_styles.dart';

class ShudanItem extends StatelessWidget {
  const ShudanItem({
    Key? key,
    this.img,
    this.name,
    this.desc,
    this.total,
    this.title,
    this.height
  }) : super(key: key);
  final String? img;
  final String? name;
  final String? desc;
  final String? title;
  final int? total;
  final double? height;
  @override
  Widget build(BuildContext context) {
    final ts = BlocProvider.of<TextStylesBloc>(context);
    return Container(
      height: height ?? 112,
      padding: EdgeInsets.only(left: 14.0, right: 10.0),
      child: SizedBox.expand(
        child: Row(
          children: [
            Container(
              width: 70,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: RepaintBoundary(child: ImageResolve(img: img)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        title!,
                        style: ts.state.title,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      child: Text(
                        desc!,
                        style: ts.state.body1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        '总共${total}本书',
                        style: ts.state.body3,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageResolve extends StatelessWidget {
  const ImageResolve({Key? key, this.img, this.builder}) : super(key: key);
  final String? img;
  final Widget Function(Widget)? builder;
  @override
  Widget build(BuildContext context) {
    final _future = Provider.of<BookRepository>(context).saveImage(img!);
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<dynamic> snap) {
          if (snap.hasData) {
            if (snap.data!.isEmpty) {
              return Container(
                child: Text(''),
              );
            }
            Widget framebuilder(context, image, frame, done) {
              Widget child;
              if (builder != null) {
                child = builder!(image);
              } else {
                child = image;
              }
              if (frame != null) {
                return Container(
                  child: child,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-4, 2),
                        color: Color.fromRGBO(150, 150, 150, 1),
                        blurRadius: 2.6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              } else {
                return child;
              }
            }

            ;
            Widget errorbuilder(context, e, t) {
              return FutureBuilder(
                builder: (context, AsyncSnapshot<dynamic> s) {
                  if (s.hasData) {
                    Widget eframebuilder(context, image, frame, done) {
                      if (frame != null) {
                        return Container(
                          child: image,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-4, 2),
                                color: Color.fromRGBO(150, 150, 150, 1),
                                blurRadius: 2.6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return image;
                      }
                    }

                    if (s.data is String) {
                      return Image.file(File(s.data!),
                          fit: BoxFit.fitWidth, cacheWidth: 112, frameBuilder: eframebuilder);
                    } else if (s.data is Uint8List) {
                      return Image.memory(s.data, fit: BoxFit.fitWidth, cacheWidth: 112, frameBuilder: eframebuilder);
                    }
                  }
                  return Container();
                },
                future: Provider.of<BookRepository>(context).saveImage('guizhenwuji.jpg'),
              );
            }

            if (snap.data is String) {
              return Image.file(
                File(snap.data!),
                fit: BoxFit.fitWidth,
                cacheWidth: 112,
                frameBuilder: framebuilder,
                errorBuilder: errorbuilder,
              );
            } else if (snap.data is Uint8List) {
              return Image.memory(
                snap.data,
                fit: BoxFit.fitWidth,
                cacheWidth: 112,
                frameBuilder: framebuilder,
                errorBuilder: errorbuilder,
              );
            }
          }
          return Container();
        });
  }
}
