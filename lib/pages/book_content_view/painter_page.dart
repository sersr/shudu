import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/book_cache_bloc.dart';
import '../../bloc/painter_bloc.dart';
import '../../utils/utils.dart';
import 'widgets/page_view.dart';

enum SettingView { indexs, setting, none }

class PainterPage extends StatefulWidget {
  const PainterPage({Key? key}) : super(key: key);

  @override
  _PainterPageState createState() => _PainterPageState();
}

class _PainterPageState extends State<PainterPage> with NavigatorObserver {
  ValueNotifier<bool> showPannel = ValueNotifier(false);

  final showSettings = ValueNotifier(SettingView.none);
  final showCname = ValueNotifier(false);

  late PainterBloc bloc;
  late Animation animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
    animation = ModalRoute.of(context)!.animation!..addStatusListener(canLoad);
  }

  void canLoad(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      bloc.completerCanLoad();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    print('/./////...........');
    willPop();
  }

  @override
  void dispose() {
    animation.removeStatusListener(canLoad);
    super.dispose();
  }

  Timer? errorTimer;
  @override
  Widget build(BuildContext context) {
    Widget child = BlocBuilder<PainterBloc, PainterState>(
      builder: (context, state) {
        final size = MediaQuery.of(context).size;

        return Container(
          height: size.height,
          width: size.width,
          color: bloc.config.bgcolor!,
          child: MediaQuery(
            data: MediaQueryData(size: bloc.size), // 使子级可以查询所提供的 size
            child: OverflowBox(
              maxHeight: bloc.size.height,
              maxWidth: bloc.size.width,
              minHeight: bloc.size.height,
              minWidth: bloc.size.width,
              alignment: Alignment.topLeft,
              child: Container(
                color: bloc.config.bgcolor!,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: ContentPageView(
                        show: showPannel,
                        willPop: willPop,
                        showCname: showCname,
                        showSettings: showSettings,
                      ),
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
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: bloc.error,
                        builder: (context, child) {
                          if (bloc.error.value.error) {
                            errorTimer?.cancel();
                            errorTimer = Timer(Duration(seconds: 2), () {
                              bloc.notifyState(error: const NotifyMessage(false));
                            });
                            return child!;
                          }
                          return SizedBox();
                        },
                        child: GestureDetector(
                          onTap: () {
                            bloc.notifyState(error: NotifyMessage(false));
                          },
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: Colors.grey.shade100.withAlpha(250),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              child: Text(
                                '网络加载出错',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.0),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return WillPopScope(
      onWillPop: willPop,
      child: FutureBuilder(
          future: bloc.canLoad?.future,
          builder: (contxt, snap) {
            if (snap.connectionState == ConnectionState.done) {
              return RepaintBoundary(child: child);
            }
            return Container(color: bloc.config.bgcolor!);
          }),
    );
  }

  // 避免多次调用
  var exiting = false;
  Future<bool> willPop() async {
    showCname.value = false;
    if (showSettings.value != SettingView.none) {
      showSettings.value = SettingView.none;
      return false;
    }
    if (!animation.isCompleted || bloc.locked || exiting) return false;
    exiting = true;

    bloc.out();
    bloc.computeCount++;

    uiOverlay(hide: false);
    uiStyle();

    await bloc.undelayedDump();
    final cbloc = context.read<BookCacheBloc>()..load();

    bloc.out();

    // 横屏处理
    if (!bloc.config.portrait!) {
      SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    }

    await cbloc.loading!.future;
    bloc.computeCount--;
    exiting = false;
    bloc.notifyState(loading: false);

    print('computeCount: ${bloc.computeCount},tasks: ${bloc.tasksLength},loadingId: ${bloc.loadingId}');
    return true;
  }
}
