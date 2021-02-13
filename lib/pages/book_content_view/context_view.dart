import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/book_cache_bloc.dart';
import '../../bloc/painter_bloc.dart';
import 'page_view.dart';

enum SettingView { indexs, setting, none }

class PainterPage extends StatefulWidget {
  const PainterPage({Key? key}) : super(key: key);

  @override
  _PainterPageState createState() => _PainterPageState();
}

class _PainterPageState extends State<PainterPage> with WidgetsBindingObserver {
  ValueNotifier<bool> showPannel = ValueNotifier(false);
  final absorbPointer = ValueNotifier(false);
  final showSettings = ValueNotifier(SettingView.none);
  final showCname = ValueNotifier(false);
  late PainterBloc bloc;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    absorbPointer.value = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
    animation = ModalRoute.of(context)!.animation!..addListener(canLoad);
  }

  void canLoad() {
    if (animation.isCompleted) {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((value) {
        absorbPointer.value = false;
        bloc.completerCanLoad();
      });
    }
  }

  Timer? timer;
  @override
  void didChangeMetrics() {
    final w = ui.window;
    print('viewpadding: ${w.viewPadding}, viewinsets: ${w.viewInsets}, padding: ${w.padding}, ${w.physicalSize}');
    if (w.padding.top == 0.0) {
      timer?.cancel();
      timer = Timer(Duration(milliseconds: 100), () {
        if (mounted) {
          bloc.add(PainterMetricsChangeEvent());
        }
      });
    }
  }

  @override
  void dispose() {
    animation.removeListener(canLoad);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = BlocBuilder<PainterBloc, PainterState>(
      builder: (context, state) {
        if (state.config?.bgcolor == null) {
          return Container();
        }
        return Stack(
          children: [
            Container(color: Color(state.config!.bgcolor!)),
            ContentPageView(
              show: showPannel,
              willPop: willPop,
              showCname: showCname,
              showSettings: showSettings,
              ignore: state.ignore,
            ),
            if (state.loading!) Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        showCname.value = false;
        if (showSettings.value != SettingView.none) {
          showSettings.value = SettingView.none;
          return false;
        }

        return willPop();
      },
      child: AnimatedBuilder(
          animation: absorbPointer,
          child: RepaintBoundary(child: child),
          builder: (context, child) {
            return AbsorbPointer(
              child: child,
              absorbing: absorbPointer.value,
            );
          }),
    );
  }

  Future<bool> willPop() async {
    if (!animation.isCompleted) {
      return false;
    }

    absorbPointer.value = true;
    //---------------------------
    bloc.add(PainterSaveEvent());
    bloc.completerCanLoad();
    final cbloc = context.read<BookCacheBloc>()
      ..loading = Completer<void>()
      ..add(BookChapterIdUpdateCidEvent(id: bloc.bookid!, cid: bloc.tData.cid!, page: bloc.currentPage!))
      ..add(BookChapterIdLoadEvent());
    if (bloc.canCompute != null && !bloc.canCompute!.isCompleted) {
      bloc.canCompute!.complete();
    }
    // bloc.computeCount != 0; 说明正在进行textPainter.layout... (UI耗时任务)
    // 而网络任务是在另一个Isolate进行的，不用等待。
    if (bloc.computeCount != 0) {
      await bloc.completer.future;
    }
    print('computeCount: ${bloc.computeCount},loadCount: ${bloc.loadCount},loadingId: ${bloc.loadingId}');
    await cbloc.loading!.future;
    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    await Future.delayed(Duration(milliseconds: 200));
    //-------------------------
    absorbPointer.value = false;
    return true;
  }
}
