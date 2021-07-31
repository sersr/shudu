import 'package:flutter/material.dart';

import '../../widgets/image_text.dart';
import '../../widgets/text_builder.dart';
import '../../widgets/images.dart';

/// 书单列表项
class BooklistItem extends StatelessWidget {
  const BooklistItem(
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
      constraints:
          BoxConstraints(maxHeight: height ?? 112, minHeight: height ?? 112),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ImageResolve(img: img),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: TextAsyncLayout(
                  top: title ?? '',
                  center: desc ?? '',
                  bottom: '总共$total本书',
                  height: height ?? 112,
                  centerLines: 2,
                  bottomLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
