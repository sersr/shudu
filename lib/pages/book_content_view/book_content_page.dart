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
import '../../utils/widget/page_animation.dart';
import 'widgets/page_view.dart';
import 'widgets/pan_slide.dart';

enum SettingView { indexs, setting, none }

class BookContentPage extends StatefulWidget {
  const BookContentPage(
      {Key? key, required this.bookId, required this.cid, required this.page})
      : super(key: key);
  final int bookId;
  final int cid;
  final int page;

  static Future? _wait;
  static Future push(
      BuildContext context, int newBookid, int cid, int page) async {
    if (_wait != null) return;
    final bloc = context.read<ContentNotifier>();
    _wait = bloc.setNewBookOrCid(newBookid, cid, page);
    // _wait = bloc.newBookOrCid(newBookid, cid, page);

    await EventLooper.instance.scheduler.endOfFrame;
    await _wait;
    _wait = null;

    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BookContentPage(bookId: newBookid, cid: cid, page: page);
    }));
  }

  @override
  BookContentPageState createState() => BookContentPageState();
}

class BookContentPageState extends PanSlideState<BookContentPage>
    with WidgetsBindingObserver, PageAnimationMixin {
  late ContentNotifier bloc;
  late BookCacheNotifier blocCache;
  @override
  void initState() {
    super.initState();
    addListener(showUiOverlay);

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    blocCache = context.read<BookCacheNotifier>();
    if (Platform.isAndroid) {
      FlutterDisplayMode.active.then(print);

      getExternalStorageDirectories().then((value) => Log.w(value));
      getApplicationDocumentsDirectory().then((value) => Log.w(value));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void showUiOverlay() {
    uiOverlay()
        .then((_) => bloc.newBookOrCid(widget.bookId, widget.cid, widget.page));
    removeListener(showUiOverlay);
  }

  Timer? errorTimer;
  @override
  Widget wrapOverlay(context, overlay) {
    //
    bloc.metricsChange(MediaQuery.of(context));

    Widget child = Selector<ContentNotifier, Color?>(
      selector: (_, ntf) => ntf.config.value.bgcolor,
      builder: (context, bgcolor, child) {
        return Material(color: bgcolor, child: child);
      },
      child: RepaintBoundary(
        child: Stack(
          children: [
            Positioned.fill(
                child: RepaintBoundary(
                    // child: ContentPageView())),
                    child: Consumer<ContentNotifier>(
                        builder: (_, __, child) {
                          Log.w(bloc.size);
                          return ContentPageView();
                        },
                        child: ContentPageView()))),
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: bloc.listenable,
                  builder: (context, _) {
                    if (bloc.error.value.error) {
                      errorTimer?.cancel();
                      errorTimer = Timer(const Duration(seconds: 2), () {
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
                                  color: Colors.grey.shade700, fontSize: 13.0),
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
    );

    return WillPopScope(
        onWillPop: onWillPop,
        child: MediaQuery(
            data: MediaQuery.of(context).removePadding(),
            child: RepaintBoundary(child: child)));
  }

  Future<bool> onWillPop() async {
    bloc.showCname.value = false;

    if (showEntries.length > 1) {
      hideLast();
      return false;
    }

    bloc.out();
    final _f = bloc.dump();

    await bloc.enter;

    bloc.notifyState(notEmptyOrIgnore: true, loading: false);
    await uiOverlay(hide: false);
    await _f;

    await blocCache.load();

    await bloc.waitTasks;
    await EventLooper.instance.runner;
    uiStyle();

    // 横屏处理
    if (!bloc.config.value.portrait!) orientation(true);

    await EventLooper.instance.scheduler.endOfFrame;

    bloc.out();
    return true;
  }
}
