import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../database/database.dart';
import '../../provider/book_cache_notifier.dart';
import '../../provider/painter_notifier.dart';
import '../../widgets/page_animation.dart';
import '../../widgets/pan_slide.dart';
import 'widgets/page_view.dart';

enum SettingView { indexs, setting, none }

class BookContentPage extends StatefulWidget {
  const BookContentPage(
      {Key? key, required this.bookId, required this.cid, required this.page})
      : super(key: key);
  final int bookId;
  final int cid;
  final int page;

  static Object? _wait;
  static Future push(
      BuildContext context, int newBookid, int cid, int page) async {
    if (_wait != null) return;
    _wait = Object();
    final bloc = context.read<ContentNotifier>();
    bloc.touchBook(newBookid, cid, page);

    await EventQueue.scheduler.endOfFrame;
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
  late ChangeNotifierSelector<ContentViewConfig, Color?> notifyColor;
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
    notifyColor = ChangeNotifierSelector<ContentViewConfig, Color?>(
        parent: bloc.config, notifyValue: (config) => config.bgcolor);

    if (Platform.isAndroid) {
      getExternalStorageDirectories().then((value) => Log.w(value));
      getApplicationDocumentsDirectory().then((value) => Log.w(value));
    }

    _book =
        bloc.repository.bookEvent.getBookCacheDb(widget.bookId).then((book) {
      if (book?.isNotEmpty == true) return book!.last;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  late FutureOr<BookCache?> _book;

  @override
  void initOnceTask() {
    super.initOnceTask();
    bloc.addInitEventTask(() async {
      final u = uiOverlay();
      final book = await _book;
      bloc.newBookOrCid(widget.bookId, book?.chapterId ?? widget.cid,
          book?.page ?? widget.page);

      await u;
      await release(const Duration(milliseconds: 300));
      uiStyle(dark: false);
    });
  }

  Timer? errorTimer;
  @override
  Widget wrapOverlay(context, overlay) {
    bloc.metricsChange(MediaQuery.of(context));

    Widget child = AnimatedBuilder(
      animation: notifyColor,
      builder: (context, child) {
        return Material(color: notifyColor.value, child: child);
      },
      child: RepaintBoundary(
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: bloc,
                  builder: (_, __) {
                    return ContentPageView();
                  },
                ),
              ),
            ),
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
        onWillPop: onWillPop, child: RepaintBoundary(child: child));
  }

  Future<bool> onWillPop() async {
    bloc.showCname.value = false;

    if (showEntries.length > 1) {
      hideLast();
      return false;
    }

    bloc.out();

    await bloc.dump();

    await blocCache.load();

    bloc.initQueue.addEventTask(() async {
      uiStyle();
      await uiOverlay(hide: false);
    });
    // 横屏处理
    if (!bloc.config.value.orientation!) setOrientation(true);

    return true;
  }
}
