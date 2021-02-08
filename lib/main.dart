import 'package:flutter/widgets.dart';
import 'package:shudu/bloc/painter_bloc.dart';
import 'package:shudu/pages/app.dart';
import 'package:shudu/utils/debug/log.dart';

void main() {
  assert(() {
    // Bloc.observer = SimpleBlocObserver();
    Log.switchToPrint = (stage) {
      if (stage is PainterBloc) return true;
      return false;
    };
    return true;
  }());

  runApp(MulProvider());
}
