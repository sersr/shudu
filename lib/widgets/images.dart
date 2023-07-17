import 'package:flutter/material.dart';
import 'package:flutter_nop/router.dart';
import 'package:useful_tools/useful_tools.dart';

import '../event/export.dart';

class ImageResolve extends StatefulWidget {
  const ImageResolve(
      {Key? key,
      this.img,
      this.builder,
      this.errorBuilder,
      this.placeholder,
      this.boxFit = BoxFit.fitWidth,
      this.shadow = true})
      : super(key: key);
  final String? img;
  final Widget Function(Widget)? builder;
  final Widget Function(BuildContext)? errorBuilder;
  final BoxFit boxFit;
  final bool shadow;
  final Widget? placeholder;

  @override
  State<ImageResolve> createState() => _ImageResolveState();
}

class _ImageResolveState extends State<ImageResolve> {
  @override
  Widget build(BuildContext context) {
    final child = _layoutBuilder();

    return RepaintBoundary(child: child);
  }

  late Repository repository;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = context.grass();
  }

  String? path;

  Widget _layoutBuilder() {
    return LayoutBuilder(builder: (context, constraints) {
      final ratio = MediaQuery.of(context).devicePixelRatio;
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      final _img = widget.img;
      if (_img == null) {
        return _errorBuilder(width, height);
      }

      final repository = context.grass<Repository>();

      final getImageBytes = repository.getImageBytes;
      final rw = (width * ratio).toInt();
      final plh = CallbackWithKeyImage(
          keys: errorImg,
          callback: () => getImageBytes(errorImg)).resize(width: rw);

      Widget child = FadeInImage(
        width: widget.boxFit == BoxFit.fitWidth ? width : null,
        height: widget.boxFit == BoxFit.fitHeight ? height : null,
        fit: widget.boxFit,
        placeholder: plh,
        image: CallbackWithKeyImage(
            keys: _img, callback: () => getImageBytes(_img)).resize(width: rw),
        imageErrorBuilder: (_, o, s) {
          return Image(
              image: plh,
              width: widget.boxFit == BoxFit.fitWidth ? width : null,
              height: widget.boxFit == BoxFit.fitHeight ? height : null,
              fit: widget.boxFit);
        },
        placeholderErrorBuilder: (_, o, s) {
          return const SizedBox();
        },
      );
      if (widget.builder != null) child = widget.builder!(child);
      // if (widget.shadow) child = ImageShadow(child: child);
      return child;
    });
  }

  Widget _errorBuilder(double width, double height) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context);
    } else {
      final getImageBytes = repository.getImageBytes;

      final plh = CallbackWithKeyImage(
          keys: errorImg, callback: () => getImageBytes(errorImg));
      return Image(
        image: plh,
        width: width,
        height: height,
        fit: widget.boxFit,
      );
    }
  }
}
