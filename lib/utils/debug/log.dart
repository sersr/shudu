import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

abstract class Log {
  static const int info = 0;
  static const int warn = 1;
  static const int error = 2;
  static int level = 0;

  static int functionLength = 24;

  static bool i(Object? info, {bool showPath = true}) {
    return _log(Log.info, info, StackTrace.current, showPath);
  }

  static bool w(Object? warn, {bool showPath = true}) {
    return _log(Log.warn, warn, StackTrace.current, showPath);
  }

  static bool e(Object? error, {bool showPath = true}) {
    return _log(Log.error, error, StackTrace.current, showPath);
  }

  static bool log(int lv, Object? message, {bool showPath = true}) {
    return _log(lv, message, StackTrace.current, showPath);
  }

  static bool _log(
      int lv, Object? message, StackTrace stackTrace, bool showPath) {
    if (!kDebugMode) return true;
    var addMsg = '';

    var path = '', name = '';

    final st = stackTrace.toString();

    final sp = LineSplitter.split(st).toList();

    final spl = sp[1].split(RegExp(r' +'));

    if (spl.length >= 3) {
      final _s = spl[1].split('.');
      name =
          _s.sublist(math.min(1, _s.length), math.min(2, _s.length)).join('.');

      path = spl.last;

      if (name.length > functionLength)
        name = '${name.substring(0, functionLength - 3)}...';
      else
        name = name.padRight(functionLength);
    }
    if (defaultTargetPlatform != TargetPlatform.iOS)
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

    addMsg = '$addMsg$name|$message.';

    if (defaultTargetPlatform != TargetPlatform.iOS) addMsg = '$addMsg\x1B[0m';

    if (showPath) addMsg = '$addMsg $path';

    print(addMsg);
    return true;
  }
}
