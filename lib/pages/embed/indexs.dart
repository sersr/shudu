import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../../utils/utils.dart';
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();

    indexBloc.rmListener(lKey);
  }

  late BookIndexNotifier indexBloc;
  final lKey = Object();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    indexBloc = context.read<BookIndexNotifier>();
    indexBloc.listener(lKey);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: DefaultTextStyle(
        style: Provider.of<TextStyleConfig>(context)
            .title3
            .copyWith(color: Colors.grey.shade800),
        child: GestureDetector(
          onTap: () {},
          child: RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final extent = 32.0;
                final headerextent = 21.0;
                return AnimatedBuilder(
                    animation: indexBloc,
                    builder: (context, _) {
                      final data = indexBloc.data;
                      if (data == null) {
                        return loadingIndicator();
                      } else if (!data.isValid) {
                        return reloadBotton(indexBloc.sendIndexs);
                      }
                      final indexs = data.indexs!;
                      final volIndex = data.volIndex!;
                      final index = data.index!;
                      var offset = 0.0;
                      final halfHeight = (height - headerextent - extent) / 2;
                      for (var i = 0; i < volIndex; i++) {
                        offset += headerextent;
                        offset += (indexs[i].length - 1) * extent;
                      }
                      offset += index * extent - halfHeight;
                      var max = 0.0;
                      for (var l in indexs) {
                        max += (l.length - 1) * extent;
                      }

                      max += indexs.length * headerextent;
                      offset = math.max(0.0, math.min(offset, max - height));
                      if (controller != null) {
                        if (controller!.hasClients) {
                          controller?.animateTo(offset,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        } else {
                          controller!.dispose();
                          controller =
                              ScrollController(initialScrollOffset: offset);
                        }
                      } else {
                        controller =
                            ScrollController(initialScrollOffset: offset);
                      }

                      return Scrollbar(
                        controller: controller,
                        // interactive: true,
                        thickness: 8,
                        radius: const Radius.circular(5),
                        child: CustomScrollView(
                          controller: controller,
                          slivers: [
                            for (var l in data.indexs!)
                              SliverStickyHeader.builder(
                                builder: (context, st) {
                                  return Container(
                                    height: headerextent,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(150, 180, 140, 1),
                                    ),
                                    child: Center(
                                        child: Text('${l.first as String}')),
                                    // height: headerextent,
                                  );
                                },
                                sliver: _StickyBody(
                                    l: l,
                                    id: data.id!,
                                    indexBloc: indexBloc,
                                    widget: widget,
                                    extent: extent),
                              ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyBody extends StatelessWidget {
  const _StickyBody({
    Key? key,
    required this.l,
    required this.indexBloc,
    required this.widget,
    required this.extent,
    required this.id,
  }) : super(key: key);

  final List l;
  final BookIndexNotifier indexBloc;
  final IndexsWidget widget;
  final double extent;
  final int id;
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
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
                if (indexBloc.contains((l[_index] as BookIndexShort).cid))
                  Text(
                    '已缓存',
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: Provider.of<TextStyleConfig>(context).body3,
                  )
              ],
            ),
            splashColor: Colors.grey[500],
            background: false,
            onTap: () {
              widget.onTap(context, id, l[_index].cid);
            },
          );
        },
        childCount: l.length - 1,
      ),
      itemExtent: extent,
    );
  }
}
