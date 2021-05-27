// import 'package:flutter/foundation.dart';
part of autils;

abstract class Log {
  static const int info = 0;
  static const int warn = 1;
  static const int error = 2;
  static int level = 0;
  static final List<String> _logMessage = ['Info ', 'Warn ', 'Error'];

  static int functionLength = 15;

  static bool i(String info, {bool showPath = true}) {
    return _log(Log.info, info, StackTrace.current, showPath);
  }

  static bool w(String warn, {bool showPath = true}) {
    return _log(Log.warn, warn, StackTrace.current, showPath);
  }

  static bool e(String error, {bool showPath = true}) {
    return _log(Log.error, error, StackTrace.current, showPath);
  }

  static bool log(int lv, String message, {bool showPath = true}) {
    return _log(lv, message, StackTrace.current, showPath);
  }

  static bool _log(
      int lv, String message, StackTrace stackTrace, bool showPath) {
    if (!kDebugMode) return true;
    var addMsg = '';

    String l;
    var path = '', name = '';
    final st = stackTrace.toString();

    final sp = LineSplitter.split(st).toList();

    final spl = sp[1].split(RegExp(r' +'));

    if (spl.length >= 3) {
      name = spl[1];
      path = spl[2];

      if (name.length > functionLength)
        name = '${name.substring(0, functionLength - 3)}...';
      else
        name = name.padRight(functionLength);
    }

    switch (level) {
      case 0:
        l = _logMessage[lv];
        break;
      case 1:
        if (lv <= 0) return true;
        l = _logMessage[lv];
        break;
      case 2:
        if (lv <= 1) return true;
        l = _logMessage[lv];
        break;
      default:
        l = '';
    }

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      switch (lv) {
        case 0:
          addMsg = '\x1B[39m';
          break;
        case 1:
          addMsg = '\x1B[33m';
          break;
        case 2:
          addMsg = '\x1B[31m';
          break;
        default:
          addMsg = '';
      }
    }

    addMsg = '$addMsg$l: $name | $message.';

    if (defaultTargetPlatform != TargetPlatform.iOS) addMsg = '$addMsg\x1B[0m';

    if (showPath) addMsg = '$addMsg $path';

    print(addMsg);
    return true;
  }
}
