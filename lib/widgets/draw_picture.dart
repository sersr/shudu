import 'package:flutter/material.dart';

import 'picture_info.dart';

class PictureWidget extends LeafRenderObjectWidget {
  PictureWidget({Key? key, this.info}) : super(key: key);
  final PictureInfo? info;
  @override
  PictureRenderBox createRenderObject(BuildContext context) {
    return PictureRenderBox(info: info?.clone());
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant PictureRenderBox renderObject) {
    renderObject..info = info?.clone();
  }
}

class PictureRenderBox extends RenderBox {
  PictureRenderBox({PictureInfo? info}) : _info = info;

  PictureInfo? _info;
  set info(PictureInfo? t) {
    if (_info != null && t != null && t.isCloneOf(_info!)) {
      t.dispose();
      return;
    }
    _info?.dispose();
    _info = t;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (_info != null) {
      return constraints
          .constrainSizeAndAttemptToPreserveAspectRatio(_info!.size);
    }
    return constraints.smallest;
  }

  @override
  void performLayout() {
    if (_info != null) {
      size =
          constraints.constrainSizeAndAttemptToPreserveAspectRatio(_info!.size);
    } else {
      size = constraints.smallest;
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_info != null) {
      // context.setWillChangeHint();

      final canvas = context.canvas;
      // canvas.save();
      // canvas.translate(offset.dx, offset.dy);
      final src = Offset.zero & _info!.size;
      final paint = Paint()..isAntiAlias = true;

      paint.color = Color.fromRGBO(0, 0, 0, 1);
      paint.filterQuality = FilterQuality.low;
      // paint.invertColors = invertColors;
      _info!.drawPicture(canvas, src, offset & size, paint);

      // canvas.restore();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _info?.dispose();
  }
}
