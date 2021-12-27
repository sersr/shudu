import 'content_brightness.dart';
import 'content_base.dart';

mixin ContentStatus on ContentDataBase, ContentBrightness {
  bool _inBookView = false;
  @override
  bool get inBook => _inBookView;

  //状态栏显隐状态
  bool uiOverlayShow = false;
  void out() {
    if (!inBook) return;
    uiOverlayShow = false;
    _inBookView = false;
    assert((debugTest = false) || true);
    notifyCustom();
    outResetDefault();
  }

  void inbook() {
    if (_inBookView) return;
    _inBookView = true;
    assert(debugTest = true);
    brightnessResetUser();
  }
}
