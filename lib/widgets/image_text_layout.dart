import 'package:flutter/material.dart';

import '../../widgets/image_text.dart';
import '../../widgets/images.dart' show ImageResolve;
import '../../widgets/images.dart';
import '../../widgets/text_builder.dart';

class ImageTextLayout extends StatelessWidget {
  const ImageTextLayout({
    Key? key,
    this.img,
    this.name,
    this.topRightScore,
    this.center,
    this.desc,
  }) : super(key: key);

  final String? img;
  final String? name;
  final String? topRightScore;
  final String? center;
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 112, minHeight: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ImageResolve(img: img),
              ),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: TextAsyncLayout(
                    topRightScore: topRightScore,
                    top: name ?? '',
                    center: center ?? '',
                    bottom: desc ?? ''),
              ),
            ),
          )
        ],
      ),
    );
  }
}
