import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../provider/book_cache_notifier.dart';
import '../../provider/painter_notifier.dart';
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

class BookContentPageState extends PanSlideState<BookContentPage>
    with WidgetsBindingObserver {
  late ContentNotifier bloc;
  late BookCacheNotifier blocCache;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    blocCache = context.read<BookCacheNotifier>();
    if (Platform.isAndroid) {
      FlutterDisplayMode.active.then(print);
      // final f = Directory('/storage/emulated/0');

      getExternalStorageDirectories().then((value) => Log.w(value));
      getApplicationDocumentsDirectory().then((value) => Log.w(value));
    }
    // f.exists().then((value) async {
    //   if (value) {
    //     final list = await f.list().toList();
    //     Log.w(list);
    //   }
    // });
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  bool _first = true;
  @override
  void complete() {
    if (_first) {
      _first = false;
      uiOverlay().whenComplete(
          () => bloc.newBookOrCid(widget.bookid, widget.cid, widget.page));
    }
  }

  Timer? errorTimer;
  @override
  Widget wrapOverlay(context, overlay) {
    //
    bloc.metricsChange(MediaQuery.of(context));

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
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: RepaintBoundary(child: ContentPageView())),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: bloc.listenable,
                          builder: (context, _) {
                            if (bloc.error.value.error) {
                              errorTimer?.cancel();
                              errorTimer =
                                  Timer(const Duration(seconds: 2), () {
                                bloc.notifyState(error: NotifyMessage.hide);
                              });

                              return GestureDetector(
                                onTap: () =>
                                    bloc.notifyState(error: NotifyMessage.hide),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.grey.shade100,
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
                            } else if (bloc.loading.value) {
                              return IgnorePointer(
                                child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: bloc.loading,
                                    builder: (context, child) {
                                      if (bloc.loading.value) return child!;

                                      return const SizedBox();
                                    },
                                    child: loadingIndicator(),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    Positioned.fill(child: RepaintBoundary(child: overlay)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return WillPopScope(onWillPop: onWillPop, child: child);
  }

  Future<bool> onWillPop() async {
    bloc.showCname.value = false;

    if (!isCompleted) return false;

    if (showEntries.length > 1) {
      hideLast();
      return false;
    }

    bloc.out();
    final _f = bloc.dump();

    await bloc.enter;

    bloc.notifyState(notEmptyOrIgnore: true, loading: false);
    await _f;

    await blocCache.load();

    await bloc.waitTasks;
    await EventLooper.instance.runner;
    uiOverlay(hide: false);
    uiStyle();

    // 横屏处理
    if (!bloc.config.value.portrait!) orientation(true);

    await EventLooper.instance.scheduler.endOfFrame;

    bloc.out();
    return true;
  }
}
