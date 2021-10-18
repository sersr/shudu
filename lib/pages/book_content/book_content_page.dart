import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../provider/book_cache_notifier.dart';
import '../../provider/content_notifier.dart';
import '../../widgets/page_animation.dart';
import '../../widgets/pan_slide.dart';
import 'widgets/page_view.dart';

enum SettingView { indexs, setting, none }

class BookContentPage extends StatefulWidget {
  const BookContentPage(
      {Key? key,
      required this.bookId,
      required this.cid,
      required this.page,
      required this.currentKey})
      : super(key: key);
  final int bookId;
  final int cid;
  final int page;

  // 任务队列中的任务相同的 key 不会被抛弃
  final Object currentKey;
  static Object? _wait;
  static Future push(
      BuildContext context, int newBookid, int cid, int page) async {
    if (_wait != null) return;
    _wait = const Object();
    final bloc = context.read<ContentNotifier>();
    final taskKey = Object();
    bloc.touchBook(newBookid, cid, page);
    await SchedulerBinding.instance!.endOfFrame;
    _wait = null;

    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RepaintBoundary(
        child: BookContentPage(
          bookId: newBookid,
          cid: cid,
          page: page,
          currentKey: taskKey,
        ),
      );
    }));
  }

  @override
  BookContentPageState createState() => BookContentPageState();
}

class BookContentPageState extends PanSlideState<BookContentPage>
    with WidgetsBindingObserver, PageAnimationMixin {
  late ContentNotifier bloc;
  late BookCacheNotifier blocCache;
  late ChangeNotifierSelector<Color?, ValueNotifier<ContentViewConfig>>
      notifyColor;
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
    notifyColor = bloc.config.selector((parent) => parent.value.bgcolor);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void initOnceTask() {
    super.initOnceTask();
    if (bloc.config.value.orientation!) {
      EventQueue.runTaskOnQueue(runtimeType, () async {
        if (!bloc.uiOverlayShow) await uiOverlay();
        // 状态栏彻底隐藏之后才改变颜色
        await release(const Duration(milliseconds: 300));
        uiStyle(dark: false);
      });
    }
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
            const Positioned.fill(
                child: RepaintBoundary(child: ContentPageView())),
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

    return WillPopScope(onWillPop: onWillPop, child: child);
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

    EventQueue.runTaskOnQueue(runtimeType, () async {
      uiStyle();
      await uiOverlay(hide: false);
    });
    bloc.addInitEventTask(() => null);
    // 横屏处理
    if (!bloc.config.value.orientation!) setOrientation(true);
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await bloc.taskRunner();
    }
    return true;
  }
}
