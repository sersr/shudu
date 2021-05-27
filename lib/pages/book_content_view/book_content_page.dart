import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../bloc/book_cache_bloc.dart';
import '../../bloc/painter_bloc.dart';
import '../../utils/utils.dart';
import 'widgets/page_view.dart';
import 'widgets/pan_slide.dart';

enum SettingView { indexs, setting, none }

class BookContentPage extends StatefulWidget {
  const BookContentPage(
      {Key? key, required this.bookid, required this.cid, required this.page})
      : super(key: key);
  final int bookid;
  final int cid;
  final int page;

  static Future? _wait;
  static Future push(
      BuildContext context, int newBookid, int cid, int page) async {
    if (_wait != null) return;

    _wait =
        context.read<ContentNotifier>().setNewBookOrCid(newBookid, cid, page);

    await _wait;
    await EventLooper.instance.scheduler.endOfFrame;
    
    _wait = null;
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BookContentPage(bookid: newBookid, cid: cid, page: page);
    }));
  }

  @override
  BookContentPageState createState() => BookContentPageState();
}

class BookContentPageState extends PanSlideState<BookContentPage> {
  late ContentNotifier bloc;
  late BookCacheBloc blocCache;
  late Animation animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    blocCache = context.read<BookCacheBloc>();
    animation = ModalRoute.of(context)!.animation!..addStatusListener(canLoad);
  }

  void canLoad(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      uiOverlay().whenComplete(
          () => bloc.newBookOrCid(widget.bookid, widget.cid, widget.page));
    }
  }

  @override
  void dispose() {
    animation.removeStatusListener(canLoad);
    super.dispose();
  }

  Timer? errorTimer;
  @override
  Widget wrapOverlay(context, overlay) {
    Widget child = Consumer<ContentNotifier>(
      builder: (context, bloc, _) {
        return Material(
          color: bloc.config.value.bgcolor!,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .removePadding()
                .copyWith(size: bloc.size),
            child: OverflowBox(
              maxHeight: bloc.size.height,
              maxWidth: bloc.size.width,
              minHeight: bloc.size.height,
              minWidth: bloc.size.width,
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: ContentPageView(
                        showCname: bloc.showCname,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: IgnorePointer(
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
                    ),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: bloc.error,
                        builder: (context, _) {
                          if (bloc.error.value.error) {
                            errorTimer?.cancel();
                            errorTimer = Timer(const Duration(seconds: 2), () {
                              bloc.notifyState(
                                  error: const NotifyMessage(false));
                            });
                            return GestureDetector(
                              onTap: () {
                                bloc.notifyState(
                                    error: const NotifyMessage(false));
                              },
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: Colors.grey.shade100.withAlpha(250),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  child: Text(
                                    bloc.error.value.msg,
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13.0),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(child: RepaintBoundary(child: overlay)),
                ],
              ),
            ),
          ),
        );
      },
    );
    return WillPopScope(
      onWillPop: willPop,
      child: child,
    );
  }

  Future<bool> willPop() async {
    bloc.showCname.value = false;

    if (!animation.isCompleted) return false;

    removeHide();
    if (entriesLength > 1) {
      hideLast();
      return false;
    }

    bloc.out();
    final _f = bloc.dump();

    await bloc.enter;

    bloc.notifyState(ignore: bloc.tData.contentIsEmpty, loading: false);
    await _f;

    blocCache.load();

    await bloc.waitTasks;
    await EventLooper.instance.runner;
    uiOverlay(hide: false);
    uiStyle();

    // 横屏处理
    if (!bloc.config.value.portrait!) {
      SystemChrome.setPreferredOrientations(
          const [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    }
    await blocCache.awaitloading;
    await EventLooper.instance.scheduler.endOfFrame;

    return true;
  }
}
