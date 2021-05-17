// import 'package:flutter/foundation.dart';
part of autils;

abstract class Log {
  static const int info = 0;
  static const int warn = 1;
  static const int error = 2;
  static int level = 0;
  static final List<String> _logMessage = ['Info', 'Warn', 'Error'];
  
  static bool i(String info, {Object? stage, Object? name, Object? data}) {
    return log(Log.info, info, stage: stage, name: name, data: data);
  }

  static bool w(String warn, {Object? stage, Object? name, Object? data}) {
    return log(Log.warn, warn, stage: stage, name: name, data: data);
  }

  static bool e(String error, {Object? stage, Object? name, Object? data}) {
    return log(Log.error, error, stage: stage, name: name, data: data);
  }

  static bool log(int lv, String message, {Object? stage, Object? name, Object? data}) {
    String addMsg;
    String l;
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
          // addMsg = '\x1B[34m';
          addMsg = '';
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
    } else {
      addMsg = '';
    }
    if (stage != null) {
      addMsg += '${stage.runtimeType}';
    }
    if (name != null) {
      if (stage != null) {
        addMsg = '$addMsg.${name.toString().padRight(12)}';
      } else {
        addMsg = '$addMsg${name.toString().padRight(12)}';
      }
    }
    if (stage != null || name != null) {
      addMsg = '$addMsg |';
    }
    addMsg = '$addMsg $l: $message.';
    if (data != null) {
      addMsg = '$addMsg\n<~ data: ${data.toString()} ~>';
    }
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      addMsg += '\x1B[0m';
    }
    print(addMsg);
    return true;
  }
}
