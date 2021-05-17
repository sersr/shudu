// export './log.dart';
class MainIsolate {
  const MainIsolate._({this.message = 'main Isolate'});
  final String message;
}

/// 主线程中使用
const mainIsolate = MainIsolate._();
