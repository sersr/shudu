import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../embed/images.dart';

import '../../bloc/bloc.dart';

class ShudanItem extends StatelessWidget {
  const ShudanItem({Key? key, this.img, this.name, this.desc, this.total, this.title, this.height}) : super(key: key);
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
              width: 72,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: RepaintBoundary(child: ImageResolve(img: img, width: 72)),
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
