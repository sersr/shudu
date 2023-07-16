import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_nop/router.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../modules/book_index/providers/book_index_notifier.dart';
import '../modules/text_style/text_style.dart';

class IndexsWidget extends StatelessWidget {
  const IndexsWidget({Key? key, required this.onTap}) : super(key: key);
  final void Function(BuildContext context, int id, int cid) onTap;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: DefaultTextStyle(
        style: context
            .grass<TextStyleConfig>()
            .data
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

                return _Indexs(
                  headerExtent: headerextent,
                  extent: extent,
                  halfHeight: halfHeight,
                  height: height,
                  onTap: onTap,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Indexs extends StatefulWidget {
  const _Indexs({
    Key? key,
    required this.headerExtent,
    required this.extent,
    required this.halfHeight,
    required this.height,
    required this.onTap,
  }) : super(key: key);

  final double headerExtent;
  final double extent;
  final double halfHeight;
  final double height;
  final void Function(BuildContext context, int id, int cid) onTap;

  @override
  State<_Indexs> createState() => _IndexsState();
}

class _IndexsState extends State<_Indexs> {
  ScrollController? controller;

  @override
  void dispose() {
    controller?.dispose();
    indexBloc?.removeRegisterKey(lKey);
    indexBloc?.removeListener(_listenOnUpdate);
    super.dispose();
  }

  BookIndexNotifier? indexBloc;
  final lKey = Object();
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    indexBloc
      ?..removeRegisterKey(lKey)
      ..removeListener(_listenOnUpdate);

    indexBloc = context.grass<BookIndexNotifier>();

    indexBloc!
      ..addRegisterKey(lKey)
      ..addListener(_listenOnUpdate);
    setController();
  }

  void setController() {
    if (controller == null && indexBloc?.data?.isValid == true) {
      final offset = _compute();
      controller = ScrollController(initialScrollOffset: offset);
    }
  }

  double _compute() {
    final data = indexBloc?.data;

    if (data == null || !data.isValidBqg) {
      return 0;
    }

    final indexs = data.chapters!;
    final volIndex = data.volIndex!;
    final index = data.index!;
    final vols = data.vols!;

    var offset = 0.0;
    offset = widget.headerExtent * volIndex;
    for (var i = 0; i < volIndex; i++) {
      offset += indexs[i].length * widget.extent;
    }
    offset += index * widget.extent - widget.halfHeight;

    final allChapters = data.allChapters!;

    final max =
        allChapters.length * widget.extent + vols.length * widget.headerExtent;

    offset = math.max(0.0, math.min(offset, max - widget.height));
    return offset;
  }

  void _listenOnUpdate() {
    setController();
    if (controller?.hasClients == true) {
      final offset = _compute();
      final position = controller!.offset;
      if ((position - offset).abs() <= 100) {
        controller!.animateTo(offset,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        controller!.jumpTo(offset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: indexBloc!,
      builder: (context, _) {
        final data = indexBloc!.data;

        if (data == null) {
          return loadingIndicator();
        } else if (!data.isValid) {
          return reloadBotton(indexBloc!.reloadIndexs);
        }

        final children = <Widget>[];

        final indexs = data.chapters!;
        final vols = data.vols!;

        for (var i = 0; i < indexs.length; i++) {
          final indexC = indexs[i];
          final child = SliverStickyHeader.builder(
            builder: (context, _) {
              return Container(
                height: widget.headerExtent,
                color: const Color.fromRGBO(150, 180, 160, 1),
                child: Center(child: Text(vols[i])),
              );
            },
            sliver: _StickyBody(
              length: indexC.length,
              extent: widget.extent,
              getName: (index) => indexC[index].name ?? '',
              isCached: (index) => indexBloc!.contains(indexC[index].id),
              onTap: (context, index) {
                final id = indexC[index].id;
                if (id != null) {
                  widget.onTap(context, data.bookid!, id);
                }
              },
            ),
          );
          children.add(child);
        }

        return Scrollbar(
          controller: controller,
          interactive: true,
          thickness: 8,
          radius: const Radius.circular(5),
          child: CustomScrollView(controller: controller, slivers: children),
        );
      },
    );
  }
}

class _StickyBody extends StatelessWidget {
  const _StickyBody({
    Key? key,
    required this.onTap,
    required this.extent,
    required this.getName,
    required this.isCached,
    required this.length,
  }) : super(key: key);

  final void Function(BuildContext context, int index) onTap;
  final double extent;
  final int length;
  final String Function(int index) getName;
  final bool Function(int index) isCached;
  @override
  Widget build(BuildContext context) {
    final styleConfig = context.grass<TextStyleConfig>().data;
    final style = styleConfig.body3;
    final title = styleConfig.title2;

    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: btn1(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              radius: 6,
              child: Row(
                children: [
                  Expanded(
                    child: Text(getName(index),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: title),
                  ),
                  if (isCached(index))
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '已缓存',
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                    )
                ],
              ),
              splashColor: !context.isDarkMode
                  ? Colors.grey.shade500
                  : Colors.grey.shade800,
              background: false,
              onTap: () => onTap(context, index),
            ),
          );
        },
        childCount: length,
      ),
      itemExtent: extent,
    );
  }
}
