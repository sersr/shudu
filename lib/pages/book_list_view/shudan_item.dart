import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../../widgets/async_text.dart';
import '../embed/images.dart';
import 'list_shudan_detail.dart';

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
    final ts = Provider.of<TextStyleConfig>(context);
    return Container(
      height: height ?? 112,
      padding: EdgeInsets.only(left: 14.0, right: 10.0),
      child: Row(
        children: [
          Container(
            width: 72,
            height: height ?? 112,
            child: ImageResolve(img: img),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: TextBuilder(
                  title: title,
                  ts: ts,
                  desc: desc,
                  total: total,
                  height: height ?? 112),
            ),
          ),
        ],
      ),
    );
  }
}

class TextBuilder extends StatefulWidget {
  const TextBuilder({
    Key? key,
    required this.title,
    required this.ts,
    required this.desc,
    required this.total,
    required this.height,
  }) : super(key: key);

  final String? title;
  final TextStyleConfig ts;
  final String? desc;
  final int? total;
  final double height;

  @override
  State<TextBuilder> createState() => _TextBuilderState();
}

class _TextBuilderState extends State<TextBuilder> {
  Future<List<TextPainter>>? _f;

  String title = '', desc = '';
  int total = 0;

  @override
  Widget build(BuildContext context) {
    if (title != widget.title || desc != widget.desc || total != widget.total) {
      _f = null;
    }
    title = widget.title!;
    desc = widget.desc!;
    total = widget.total!;
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder<List<TextPainter>>(
          future: _f ??= Future.wait<TextPainter>([
            AsyncText.asyncLayout(
                constraints.maxWidth,
                TextPainter(
                    text:
                        TextSpan(text: widget.title!, style: widget.ts.title3),
                    maxLines: 1,
                    textDirection: TextDirection.ltr)),
            AsyncText.asyncLayout(
                constraints.maxWidth,
                TextPainter(
                    text: TextSpan(text: widget.desc!, style: widget.ts.body2),
                    maxLines: 2,
                    textDirection: TextDirection.ltr)),
            AsyncText.asyncLayout(
                constraints.maxWidth,
                TextPainter(
                    text: TextSpan(
                        text: '总共${widget.total}本书', style: widget.ts.body3),
                    maxLines: 1,
                    textDirection: TextDirection.ltr)),
          ]),
          builder: (context, snap) {
            if (snap.hasData) {
              final data = snap.data!;
              return CustomMultiChildLayout(
                delegate: ItemDetailWidget(widget.height),
                children: [
                  LayoutId(id: 'top', child: AsyncText.async(data[0])),
                  LayoutId(id: 'center', child: AsyncText.async(data[1])),
                  LayoutId(id: 'bottom', child: AsyncText.async(data[2]))
                ],
              );
            }
            return SizedBox();
          });
    });
  }
}
