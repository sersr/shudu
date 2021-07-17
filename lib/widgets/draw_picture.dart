import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
          .constrainSizeAndAttemptToPreserveAspectRatio(_info!._picture.size);
    }
    return constraints.smallest;
  }

  @override
  void performLayout() {
    if (_info != null) {
      size = constraints
          .constrainSizeAndAttemptToPreserveAspectRatio(_info!._picture.size);
    } else {
      size = constraints.smallest;
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_info != null) {
      final canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.drawPicture(_info!._picture.picture);
      canvas.restore();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _info?.dispose();
  }
}

class PictureInfo {
  PictureInfo(this._picture);
  final PictureMec _picture;

  PictureInfo clone() {
    final _clone = PictureInfo(_picture);
    _picture.add(_clone);
    return _clone;
  }

  bool isCloneOf(PictureInfo info) {
    return _picture == info._picture;
  }

  void dispose() {
    _picture.dispose(this);
  }
}

class PictureMec {
  PictureMec(this.picture, this.size);
  final ui.Picture picture;
  final Size size;
  final Set<PictureInfo> _list = <PictureInfo>{};

  void add(PictureInfo info) {
    assert(!_dispose);
    _list.add(info);
  }

  bool _dispose = false;
  void dispose(PictureInfo info) {
    assert(!_dispose);
    _list.remove(info);
    if (_list.isEmpty) {
      _dispose = true;
      picture.dispose();
    }
  }
}
