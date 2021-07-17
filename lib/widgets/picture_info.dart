import 'dart:ui' as ui;

class PictureInfo {
  PictureInfo.picture(ui.Picture pic, ui.Size size)
      : _picture = PictureMec._(pic, size);

  PictureInfo(this._picture);
  final PictureMec _picture;

  void drawPicture(ui.Canvas canvas) {
    assert(!_picture._dispose);
    canvas.drawPicture(_picture.picture);
  }

  ui.Size get size {
    assert(!_picture._dispose);
    return _picture.size;
  }

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
  PictureMec._(this.picture, this.size);
  final ui.Picture picture;
  final ui.Size size;
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

typedef PictureListenerCallback = void Function(PictureInfo? image, bool error);

class PictureListener {
  PictureListener();
  PictureInfo? _image;
  bool _error = false;

  void setPicture(PictureInfo? img, [bool error = false]) {
    final list = List.of(_list);
    _list.clear();
    _error = error;

    list.forEach((element) => element(img?.clone(), error));
    if (_dispose) {
      img?.dispose();
      return;
    } else {
      _image = img;
    }
  }

  final _list = <PictureListenerCallback>[];
  void addListener(PictureListenerCallback callback) {
    if (_image == null && !_error) {
      _list.add(callback);
      return;
    }
    callback(_image?.clone(), _error);
  }

  void removeListener(PictureListenerCallback callback) {
    _list.remove(callback);
  }

  bool get hasListener => _list.isNotEmpty;

  bool get close => _dispose;

  bool _dispose = false;
  void dispose() {
    if (_dispose) return;
    _dispose = true;
    _image?.dispose();
  }
}
