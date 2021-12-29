import 'package:flutter/material.dart';

import '../../widgets/image_text.dart';

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
    return ImageTextLayout(
      img: img,
      top: title ?? '',
      center: desc ?? '',
      bottom: '总共$total本书',
      height: height ?? 112,
      centerLines: 2,
      bottomLines: 1,
    );
  }
}
