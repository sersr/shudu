import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../data/data.dart';
import '../provider/provider.dart';

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
    indexBloc.removeRegisterKey(lKey);
  }

  late BookIndexNotifier indexBloc;
  final lKey = Object();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    indexBloc = context.read<BookIndexNotifier>();
    indexBloc.addRegisterKey(lKey);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: DefaultTextStyle(
        style: context
            .read<TextStyleConfig>()
            .title3
            .copyWith(color: Colors.grey.shade800),
        child: GestureDetector(
          onTap: () {},
          child: RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                const extent = 32.0;
                const headerextent = 21.0;
                final halfHeight = (height - extent - headerextent) / 2;

                return AnimatedBuilder(
                    animation: indexBloc,
                    builder: (context, _) {
                      final data = indexBloc.data;

                      if (data == null) {
                        return loadingIndicator();
                      } else if (!data.isValid) {
                        return reloadBotton(indexBloc.loadIndexs);
                      }

                      final indexs = data.chapters!;
                      final volIndex = data.volIndex!;
                      final index = data.index!;
                      final vols = data.vols!;

                      var offset = 0.0;
                      offset = headerextent * volIndex;
                      for (var i = 0; i < volIndex; i++) {
                        offset += indexs[i].length * extent;
                      }
                      offset += index * extent - halfHeight;

                      final allChapters = data.allChapters!;

                      final max = allChapters.length * extent +
                          vols.length * headerextent;

                      offset = math.max(0.0, math.min(offset, max - height));
                      if (controller != null) {
                        // if (controller!.hasClients) {
                        //   controller?.animateTo(offset,
                        //       duration: const Duration(milliseconds: 300),
                        //       curve: Curves.easeInOut);
                        // } else {
                        controller!.dispose();
                        controller =
                            ScrollController(initialScrollOffset: offset);
                        // }
                      } else {
                        controller =
                            ScrollController(initialScrollOffset: offset);
                      }

                      return Scrollbar(
                        controller: controller,
                        interactive: true,
                        thickness: 8,
                        radius: const Radius.circular(5),
                        child: CustomScrollView(
                          controller: controller,
                          slivers: [
                            for (var i = 0; i < indexs.length; i++)
                              SliverStickyHeader.builder(
                                builder: (context, st) {
                                  return Container(
                                    height: headerextent,
                                    color:
                                        const Color.fromRGBO(150, 180, 160, 1),

                                    child: Center(child: Text(vols[i])),
                                    // height: headerextent,
                                  );
                                },
                                sliver: _StickyBody(
                                    l: indexs[i],
                                    bookid: data.bookid!,
                                    indexBloc: indexBloc,
                                    onTap: widget.onTap,
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
    required this.onTap,
    required this.extent,
    required this.bookid,
  }) : super(key: key);

  final List<BookIndexChapter> l;
  final BookIndexNotifier indexBloc;
  final void Function(BuildContext context, int id, int cid) onTap;
  final double extent;
  final int bookid;
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return btn1(
            padding: const EdgeInsets.only(left: 10, right: 10),
            radius: 6,
            child: Row(
              textBaseline: TextBaseline.ideographic,
              children: [
                Expanded(
                  child: Text(
                    l[index].name ?? '',
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (indexBloc.contains(l[index].id))
                  Text(
                    '已缓存',
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: context.read<TextStyleConfig>().body3,
                  )
              ],
            ),
            splashColor: Colors.grey[500],
            background: false,
            onTap: () {
              final id = l[index].id;
              if (id != null) onTap(context, bookid, id);
            },
          );
        },
        childCount: l.length,
      ),
      itemExtent: extent,
    );
  }
}
