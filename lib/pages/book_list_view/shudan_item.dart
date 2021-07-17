import 'package:flutter/material.dart';

import '../../widgets/image_text.dart';
import '../../widgets/text_builder.dart';
import '../embed/images.dart';

class ShudanItem extends StatelessWidget {
  const ShudanItem(
      {Key? key,
      this.img,
      this.name,
      this.desc,
      this.total,
      this.title,
      this.height})
      : super(key: key);
  final String? img;
  final String? name;
  final String? desc;
  final String? title;
  final int? total;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 112,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: Container(
              // width: 72,
              // height: height ?? 112,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ImageResolve(img: img),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: RepaintBoundary(
                child: TextBuilder(
                    top: title,
                    center: desc,
                    bottom: '总共$total本书',
                    height: height ?? 112),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
