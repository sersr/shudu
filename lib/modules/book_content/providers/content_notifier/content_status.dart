import 'dart:async';

import 'content_base.dart';
import 'content_brightness.dart';

mixin ContentStatus on ContentDataBase, ContentBrightness {
  bool _inBookView = false;
  @override
  bool get inBook => _inBookView;

  //状态栏显隐状态
  bool uiOverlayShow = false;
  void out() {
    if (!inBook) return;
    _inBookView = false;
    assert((debugTest = false) || true);
    notifyCustom();
    outResetDefault();
  }

  @override
  FutureOr<void> onOut() {
    uiOverlayShow = false;
    return super.onOut();
  }

  void setInBook() {
    if (_inBookView) return;
    _inBookView = true;
    assert(debugTest = true);
    brightnessResetUser();
  }
}
