import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_header/flutter_sticky_header.dart';

import '../../bloc/bloc.dart';
import '../../utils/widget/botton.dart';

class IndexsWidget extends StatefulWidget {
  const IndexsWidget({Key? key, required this.onTap}) : super(key: key);
  final void Function(BuildContext context, int id, int cid) onTap;

  @override
  _IndexsWidgetState createState() => _IndexsWidgetState();
}

class _IndexsWidgetState extends State<IndexsWidget> {
  ScrollController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final extent = 32.0;
        final headerextent = 21.0;
        return BlocBuilder<BookIndexBloc, BookIndexState>(builder: (context, state) {
          if (state is BookIndexWidthData) {
            final indexs = state.bookIndexs;
            final volIndex = state.volIndex;
            controller?.dispose();
            var offset = 0.0;
            final halfHeight = (height - headerextent) / 2 - extent / 2;
            for (var i = 0; i < volIndex; i++) {
              offset += headerextent;
              offset += (indexs[i].length - 1) * extent;
            }
            offset += state.index * extent - halfHeight;
            var max = 0.0;
            for (var l in indexs) {
              max += (l.length - 1) * extent;
            }
            max += state.bookIndexs.length * headerextent;
            offset = math.max(0.0, math.min(offset, max - height));
            controller = ScrollController(initialScrollOffset: offset);
            return Scrollbar(
              controller: controller,
              thickness: 10,
              radius: Radius.circular(5),
              child: CustomScrollView(
                controller: controller,
                // key: Key('$max'),
                slivers: [
                  for (var l in state.bookIndexs)
                    // Container(),
                    SliverStickyHeader.builder(
                      builder: (context, st) {
                        return Container(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 1.0),
                          child: Center(child: Text('${l.first as String}')),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(150, 180, 140, 1),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(st.isPinned ? 6.0 : 0.0)),
                          ),
                          // height: headerextent,
                        );
                      },
                      sliver: SliverFixedExtentList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final _index = index + 1;
                            return btn1(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              radius: 6,
                              child: Row(
                                textBaseline: TextBaseline.ideographic,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${l[_index].cname}',
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (state.cacheList.contains((l[_index] as BookIndexShort).cid))
                                    Text(
                                      '已缓存',
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: BlocProvider.of<TextStylesBloc>(context).state.body3,
                                    )
                                ],
                              ),
                              splashColor: Colors.grey[500],
                              background: false,
                              onTap: () {
                                widget.onTap(context, state.id, l[_index].cid);
                              },
                            );
                          },
                          childCount: l.length - 1,
                        ),
                        itemExtent: extent,
                      ),
                    ),
                ],
              ),
            );
            // },
            // );
          } else if (state is BookIndexErrorState) {
            return Center(
              child: btn1(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                bgColor: Colors.blue,
                splashColor: Colors.blue[200],
                radius: 40,
                child: Text('重新加载'),
                onTap: () {
                  BlocProvider.of<BookIndexBloc>(context).add(BookIndexReloadEvent());
                },
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
      },
    );
  }
}
