import 'package:flutter/material.dart';
import 'package:shudu/pages/book_content_view/widgets/page_view.dart';
import 'package:shudu/pages/book_content_view/widgets/page_view_controller.dart';
import 'package:shudu/provider/provider.dart';
import '../../utils/utils.dart';

class ListItemBuilder extends StatelessWidget {
  const ListItemBuilder({
    Key? key,
    required this.child,
    this.onLongPress,
    this.onTap,
    this.background = true,
    this.height,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool background;
  final double? height;

  final bgColor = const Color.fromRGBO(250, 250, 250, 1);
  final spalColor = const Color.fromRGBO(225, 225, 225, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: height == null
          ? null
          : BoxConstraints(maxHeight: height!, minHeight: height!),
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
      child: btn1(
          onTap: onTap,
          background: background,
          onLongPress: onLongPress,
          radius: 6.0,
          bgColor: bgColor,
          splashColor: spalColor,
          child: child),
    );
  }
}

class ListViewBuilder extends StatefulWidget {
  const ListViewBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent,
    this.primary,
    this.cacheExtent,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final bool? primary;
  final double? cacheExtent;
  final EdgeInsets padding;

  @override
  State<ListViewBuilder> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<ListViewBuilder>
    with TickerProviderStateMixin {
  // late NopPageViewController offsetPosition;

  // @override
  // void initState() {
  //   super.initState();
  //   offsetPosition = NopPageViewController(
  //     vsync: this,
  //     scrollingNotify: (_) {},
  //     getBounds: isBoundary,
  //   );
  // }

  // int isBoundary() {
  //   var _r = 0;
  //   if (currentIndex > 0) _r |= ContentBounds.addLeft;
  //   if (currentIndex < widget.itemCount - 1) _r |= ContentBounds.addRight;

  //   return _r;
  // }

  // int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color.fromRGBO(242, 242, 242, 1),
      // child: NopPageView(
      //   offsetPosition: offsetPosition,
      //   builder: (index, {bool changeState = false}) {
      //     if (changeState) {
      //       Log.w(currentIndex);
      //       currentIndex = index;
      //       return null;
      //     }
      //     return widget.itemBuilder(context, index);
      //   },
      // ),
      child: ListView.builder(
          primary: widget.primary,
          itemExtent: widget.itemExtent,
          itemCount: widget.itemCount,
          cacheExtent: widget.cacheExtent,
          padding: widget.padding,
          itemBuilder: widget.itemBuilder),
    );
  }
}
