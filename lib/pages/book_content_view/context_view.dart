import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/utils.dart';

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

  final showSettings = ValueNotifier(SettingView.none);
  final showCname = ValueNotifier(false);
  late PainterBloc bloc;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    // absorbPointer.value = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
    animation = ModalRoute.of(context)!.animation!..addListener(canLoad);
  }

  void canLoad() {
    if (animation.isCompleted) {
      bloc.completerCanLoad();
      // SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }

  Timer? timer;
  @override
  void didChangeMetrics() {
    timer?.cancel();
    timer = Timer(Duration(milliseconds: 150), () {
      if (mounted) {
        final w = ui.window;
        assert(Log.i('${w.systemGestureInsets}${w.viewPadding}${w.padding}${w.viewInsets}${w.physicalGeometry}'));
        bloc.add(PainterMetricsChangeEvent());
      }
    });
  }

  @override
  void dispose() {
    animation.removeListener(canLoad);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
Timer? errorTimer;
  @override
  Widget build(BuildContext context) {
    Widget child = BlocBuilder<PainterBloc, PainterState>(
      builder: (context, state) {
        if (bloc.config.bgcolor == null) {
          return Container();
        } else {
          return Stack(
            children: [
              Container(color: Color(bloc.config.bgcolor!)),
              ContentPageView(
                show: showPannel,
                willPop: willPop,
                showCname: showCname,
                showSettings: showSettings,
              ),
              RepaintBoundary(
                  child: AnimatedBuilder(
                      animation: bloc.loading,
                      builder: (context, child) {
                        if (bloc.loading.value) {
                          return child!;
                        }
                        return Container();
                      },
                      child: Center(child: CircularProgressIndicator()))),
              RepaintBoundary(
                  child: AnimatedBuilder(
                      animation: bloc.error,
                      builder: (context, child) {
                        if (bloc.error.value) {
                          errorTimer?.cancel();
                          errorTimer = Timer(Duration(seconds: 2), () {
                            bloc.error.value = false;
                          });
                          return child!;
                        }
                        return Container();
                      },
                      child: GestureDetector(
                        onTap: () {
                          bloc.error.value = false;
                        },
                        child: Center(
                          child: Container(
                            child: Text(
                              '网络加载出错',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13.0),
                              overflow: TextOverflow.fade,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: Colors.grey.shade100.withAlpha(250),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          ),
                        ),
                      ))),
              // AnimatedBuilder(
              //     animation: absorbPointer,
              //     builder: (context, child) {
              //       return Container(color: absorbPointer.value ? Colors.white.withAlpha(0) : null);
              //     }),
            ],
          );
        }
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
      child: RepaintBoundary(child: child),
    );
  }

  Future<bool> willPop() async {
    if (!animation.isCompleted) {
      return false;
    }
    await bloc.dump();
    final cbloc = context.read<BookCacheBloc>()
      ..loading = Completer<void>()
      ..add(BookChapterIdLoadEvent());
    bloc.out();
    bloc.completerCanLoad();
    if (!bloc.completer.isCompleted) {
      // 尽快退出其他任务；
      await bloc.repository.restartClient();
      // await bloc.completer.future;
    }
    bloc.completercanCompute();

    await bloc.completer.future;
    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    assert(Log.i('computeCount: ${bloc.computeCount},loadCount: ${bloc.loadCount},loadingId: ${bloc.loadingId}'));
    await cbloc.loading!.future;
    //-------------------------
    await Future.delayed(Duration(milliseconds: 500));
    // absorbPointer.value = false;
    return true;
  }
}
