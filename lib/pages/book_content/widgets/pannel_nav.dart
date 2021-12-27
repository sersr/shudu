import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../provider/export.dart';
import '../../../widgets/indexs.dart';
import '../../../widgets/pan_slide.dart';
import '../../book_info/info_page.dart';
import '../book_content_page.dart';
import 'page_view_controller.dart';

class Pannel extends StatefulWidget {
  const Pannel({Key? key, required this.controller}) : super(key: key);

  final NopPageViewController controller;
  @override
  _PannelState createState() => _PannelState();
}

class _PannelState extends State<Pannel> {
  Timer? timer;
  late ContentNotifier bloc;
  late BookIndexNotifier indexBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    indexBloc = context.read<BookIndexNotifier>();
  }

  @override
  Widget build(BuildContext context) {
    final child = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: Colors.grey.shade300,
        inactiveTrackColor: Colors.grey,
        activeTrackColor: Colors.blue,
        minThumbSeparation: 2,
        valueIndicatorTextStyle: TextStyle(),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
        thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6, pressedElevation: 4, elevation: 5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: CnamePan(
                indexBloc: indexBloc, bloc: bloc, getTimer: () => timer),
          ),
          RepaintBoundary(
            child: Material(
              color: Colors.grey.shade900,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: bloc.pannelPaddingNotifier,
                  builder: (context, child) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 10.0 + bloc.pannelPadding.left,
                        right: 10.0 + bloc.pannelPadding.right,
                      ),
                      child: child!,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RepaintBoundary(
                              child: btn1(
                                  radius: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  onTap: () {
                                    if (!bloc.loading.value) {
                                      bloc.goPre();
                                    }
                                  },
                                  child: Center(
                                      child: Text(
                                    '上一章',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade300),
                                  )),
                                  bgColor: Colors.transparent,
                                  splashColor: Colors.grey.shade700),
                            ),
                            Expanded(
                              child: RepaintBoundary(
                                child: AnimatedBuilder(
                                  animation: indexBloc.slide,
                                  builder: (context, child) {
                                    return Slider(
                                      value: indexBloc.slide.value.toDouble(),
                                      // divisions: sldvalue.max,
                                      onChanged: (double value) {
                                        indexBloc.slide.value = value.toInt();
                                      },
                                      onChangeEnd: (value) {
                                        timer?.cancel();
                                        timer = Timer(
                                            Duration(milliseconds: 1500), () {
                                          bloc.showCname.value = false;
                                          indexBloc.slide.value =
                                              indexBloc.sldvalue.index;
                                        });
                                      },
                                      onChangeStart: (value) {
                                        timer?.cancel();
                                        bloc.showCname.value = true;
                                      },
                                      min: 0.0,
                                      max: indexBloc.sldvalue.max.toDouble(),
                                    );
                                  },
                                ),
                              ),
                            ),
                            btn1(
                                radius: 40,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                onTap: () {
                                  if (!bloc.loading.value) {
                                    bloc.goNext();
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    '下一章',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                                bgColor: Colors.transparent,
                                // radius: 6.0,
                                splashColor: Colors.grey.shade700),
                          ],
                        ),
                      ),
                      RepaintBoundary(
                        child: BottomEnd(controller: widget.controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return child;
  }
}

class CnamePan extends StatelessWidget {
  const CnamePan({
    Key? key,
    required this.indexBloc,
    required this.bloc,
    required this.getTimer,
  }) : super(key: key);

  final BookIndexNotifier indexBloc;
  final ContentNotifier bloc;
  // timer 会更改，回调得到当前的引用
  final Timer? Function() getTimer;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bloc.showCname,
      builder: (context, child) {
        if (bloc.showCname.value) {
          return AnimatedBuilder(
            animation: indexBloc,
            builder: (context, state) {
              final data = indexBloc.data;
              if (data == null) {
                return loadingIndicator();
              } else if (data.isValid != true) {
                return reloadBotton(indexBloc.reloadIndexs);
              }
              final indexs = data.allChapters;
              final _zduIndexs = data.data;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AnimatedBuilder(
                  animation: indexBloc.slide,
                  builder: (context, child) {
                    var v = indexBloc.slide.value.toInt();
                    var text = '';
                    var cid = -1;
                    if (data.api == ApiType.biquge) {
                      if (v < indexs!.length) {
                        final chapter = indexs[v];
                        text = chapter.name ?? text;
                        cid = chapter.id ?? cid;
                      }
                    } else {
                      if (v < _zduIndexs!.length) {
                        final chapter = _zduIndexs[v];
                        text = chapter.name ?? text;
                        cid = chapter.id ?? cid;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        if (!bloc.loading.value) {
                          getTimer()?.cancel();
                          bloc.showCname.value = false;
                          if (cid != -1)
                            bloc.newBookOrCid(data.bookid!, cid, 1,
                                api: bloc.api);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.grey.shade900.withAlpha(210),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        child: Text(
                          text,
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 15.0),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }
}

class BottomEnd extends StatefulWidget {
  const BottomEnd({Key? key, required this.controller}) : super(key: key);

  final NopPageViewController controller;

  @override
  _BottomEndState createState() => _BottomEndState();
}

Widget bottomButton(
    {Widget? child,
    String? text,
    IconData? icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress}) {
  assert(child != null || text != null);
  return Center(
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.grey.shade400),
            SizedBox(height: 5),
            child ??
                Text(text!,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
      ),
    ),
  );
}

Widget _topButton(
    {Widget? child,
    String? text,
    required VoidCallback onTap,
    VoidCallback? onLongPress}) {
  assert(child != null || text != null);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1.0),
    child: SizedBox(
      height: 42,
      width: 60,
      child: OverflowBox(
        maxHeight: 60,
        maxWidth: 60,
        child: btn1(
          onTap: onTap,
          radius: 100,
          onLongPress: onLongPress,
          bgColor: Colors.grey.withAlpha(0),
          splashColor: Color.fromARGB(255, 119, 119, 119),
          // borderRadius: BorderRadius.circular(100.0),
          child: Center(
            child: child ??
                Text(
                  text!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
                ),
          ),
        ),
      ),
    ),
  );
}

class _BottomEndState extends State<BottomEnd> {
  late ContentNotifier bloc;
  late BookIndexNotifier indexBloc;

  final ValueNotifier<SettingView> showSettings =
      ValueNotifier(SettingView.none);
  Size bsize = const Size(0.0, 10);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    indexBloc = context.read<BookIndexNotifier>();
  }

  final op = Tween<Offset>(begin: const Offset(-0.120, 0), end: Offset.zero);
  final debx =
      ColorTween(begin: Colors.transparent, end: Colors.black87.withAlpha(100));

  OverlayVerticalPannels? _pannels;

  OverlayVerticalPannels get pannels {
    if (_pannels != null) return _pannels!;
    late OverlayVerticalPannels pannel;
    return _pannels = pannel = OverlayVerticalPannels(
      onShowEnd: onshowEnd,
      onHideEnd: onhideEnd,
      builders: [
        (context) {
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SettingsTransition(
              onTap: hide,
              hide: _hide,
              height: bsize.height,
              showSettings: showSettings,
              controller: pannel.controller,
              callbackOnHide: callbackOnHide,
            ),
          );
        },
      ],
    );
  }

  OverlayMixinDelegate? _delegate;
  OverlayMixinDelegate get delegate {
    if (_delegate != null) {
      if (!_delegate!.closed) return _delegate!;
    }
    return _delegate =
        OverlayMixinDelegate(pannels, const Duration(milliseconds: 350))
          ..overlay = context.read<OverlayObserver>();
  }

  VoidCallback? _callback;
  void callbackOnHide([VoidCallback? callback]) {
    _callback = callback;
    hide();
  }

  final _hide = ValueNotifier(false);

  void toggle() {
    if (_fut != null) return;
    if (delegate.hided) {
      show();
    } else {
      hide();
    }
  }

  FutureOr? _fut;

  void show() {
    _fut ??= delegate.show()..whenComplete(() => _fut = null);
  }

  void hide() {
    _fut ??= delegate.hide()..whenComplete(() => _fut = null);
  }

  void onhideEnd() {
    _callback?.call();
    _callback = null;
    _hide.value = true;

    showSettings.value = SettingView.none;
  }

  void onshowEnd() {
    _hide.value = false;
    bloc.reloadBrightness();
    indexBloc.loadIndexs(bloc.bookId, bloc.tData.cid,
        api: bloc.api, restore: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bloc.pannelPaddingNotifier,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(
              top: 6.0, bottom: 2.0 + bloc.pannelPadding.bottom),
          child: child,
        );
      },
      child: RepaintBoundary(
        child: Row(
          children: [
            Expanded(
              child: bottomButton(
                onTap: () {
                  bsize = context.size ?? bsize;
                  if (showSettings.value != SettingView.indexs) {
                    show();

                    bloc.showCname.value = false;
                    // context
                    //     .read<BookIndexNotifier>()
                    //     .loadIndexs(bloc.bookid, bloc.tData.cid, true);
                    showSettings.value = SettingView.indexs;
                  } else {
                    toggle();
                  }
                },
                onLongPress: () {
                  bsize = context.size ?? bsize;

                  if (showSettings.value != SettingView.indexs) {
                    show();
                    bloc.showCname.value = false;
                    indexBloc
                      ..bookUpDateTime.remove(bloc.bookId)
                      ..loadIndexs(bloc.bookId, bloc.tData.cid,
                          api: bloc.api, restore: true);
                    showSettings.value = SettingView.indexs;
                  } else {
                    toggle();
                  }
                },
                text: '目录',
                icon: Icons.menu_book_outlined,
              ),
            ),
            Expanded(
              child: bottomButton(
                onTap: () {
                  bsize = context.size ?? bsize;
                  if (showSettings.value != SettingView.setting) {
                    show();
                    bloc.showCname.value = false;
                    showSettings.value = SettingView.setting;
                  } else {
                    toggle();
                  }
                },
                text: '设置',
                icon: Icons.settings_rounded,
              ),
            ),
            Expanded(
              child: bottomButton(
                onTap: bloc.auto,
                child: AnimatedBuilder(
                  animation: bloc.autoRun.isActive,
                  builder: (context, child) {
                    return Text(
                      '${!bloc.autoRun.value ? '开始' : '停止'}滚动',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade300),
                    );
                  },
                ),
                icon: Icons.auto_stories,
              ),
            ),
            Expanded(
              child: bottomButton(
                onTap: () {
                  hide();
                  final portrait = !bloc.config.value.orientation!;
                  bloc.setPrefs(
                      bloc.config.value.copyWith(orientation: portrait));
                },
                child: AnimatedBuilder(
                  animation: bloc.config,
                  builder: (context, _) {
                    return Text(
                      '切换${bloc.config.value.orientation! ? '横屏' : '竖屏'}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade300),
                    );
                  },
                ),
                icon: Icons.screen_rotation_outlined,
              ),
            ),
            Expanded(
              child: bottomButton(
                onTap: () {
                  final _axis = widget.controller.axis == Axis.horizontal
                      ? Axis.vertical
                      : Axis.horizontal;

                  bloc.autoRun.stopTicked();
                  bloc.setPrefs(bloc.config.value.copyWith(axis: _axis));
                },
                child: AnimatedBuilder(
                  animation: bloc.config,
                  builder: (context, _) {
                    return Text(
                      bloc.config.value.axis == Axis.horizontal
                          ? '上下滚动'
                          : '左右滑动',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade300),
                    );
                  },
                ),
                icon: Icons.swap_vert_circle_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTransition extends StatelessWidget {
  const SettingsTransition({
    Key? key,
    required this.height,
    required this.hide,
    required this.onTap,
    required this.controller,
    required this.callbackOnHide,
    required this.showSettings,
  }) : super(key: key);

  final double height;
  final ValueNotifier hide;
  final VoidCallback onTap;
  final AnimationController controller;
  final void Function([VoidCallback? callback]) callbackOnHide;
  final ValueNotifier<SettingView> showSettings;

  @override
  Widget build(BuildContext context) {
    final op = Tween<Offset>(begin: const Offset(-0.120, 0), end: Offset.zero);
    final debx = ColorTween(
        begin: Colors.transparent, end: Colors.black87.withAlpha(100));
    final bottom = 30 + height;

    return CurvedAnimationWidget(
        controller: controller,
        curve: Curves.easeInOut,
        builder: (context, animation) {
          final position = animation.drive(op);
          final colors = debx.animate(animation);
          final bloc = context.read<ContentNotifier>();

          final bottomChild = LayoutId(
            id: 'bottom',
            child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                    animation: colors,
                    builder: (context, _) {
                      return Container(
                        color: colors.value ?? Colors.transparent,
                        height: bottom,
                      );
                    }),
              ),
            ),
          );

          Widget body;
          body = SlideTransition(
            position: position,
            child: FadeTransition(
              opacity: animation,
              child: Material(
                borderRadius: BorderRadius.circular(6.0),
                color: !context.isDarkMode
                    ? Colors.grey.shade300
                    : Colors.grey.shade900,
                clipBehavior: Clip.hardEdge,
                child: BookSettingsView(
                    showSettings: showSettings, close: callbackOnHide),
              ),
            ),
          );

          body = AnimatedBuilder(
            animation: bloc.pannelPaddingNotifier,
            builder: (context, child) {
              final padding = EdgeInsets.only(
                  top: 10.0 + bloc.pannelPadding.top,
                  left: 24.0 + bloc.pannelPadding.left,
                  right: 24.0 + bloc.pannelPadding.right,
                  bottom: 0);
              return Padding(padding: padding, child: child);
            },
            child: body,
          );

          body = GestureDetector(
            onTap: onTap,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: colors,
                builder: (context, child) {
                  return ColoredBox(
                    color: colors.value ?? Colors.transparent,
                    child: GestureDetector(onTap: () {}, child: child),
                  );
                },
                child: RepaintBoundary(child: body),
              ),
            ),
          );

          body = LayoutId(
            id: 'body',
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: hide,
                builder: (context, child) {
                  return IgnorePointer(ignoring: hide.value, child: child);
                },
                child: body,
              ),
            ),
          );

          return RepaintBoundary(
            child: CustomMultiChildLayout(
              delegate: ModalPart(bottom),
              children: [body, bottomChild],
            ),
          );
        });
  }
}

class PannelTransition extends StatelessWidget {
  const PannelTransition({
    Key? key,
    required this.child,
    required this.controller,
    this.begin = const Offset(0, -1),
  }) : super(key: key);

  final Widget child;
  final Offset begin;
  final AnimationController controller;
  @override
  Widget build(BuildContext context) {
    return CurvedAnimationWidget(
        controller: controller,
        curve: Curves.ease,
        reverseCurve: Curves.ease.flipped,
        builder: (context, animation) {
          final op = Tween<Offset>(begin: begin, end: Offset.zero);

          final position = animation.drive(op);
          return SlideTransition(
            position: position,
            child: FadeTransition(
              opacity: animation.drive(Tween<double>(begin: 0, end: 0.9)),
              child: child,
            ),
          );
        });
  }
}

class TopPannel extends StatefulWidget {
  const TopPannel({Key? key}) : super(key: key);

  @override
  _TopPannelState createState() => _TopPannelState();
}

class _TopPannelState extends State<TopPannel> {
  late ContentNotifier contentNtf;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    contentNtf = context.read<ContentNotifier>();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.grey.shade900,
        child: AnimatedBuilder(
          animation: contentNtf.pannelPaddingNotifier,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.only(
                top: contentNtf.pannelPadding.top + 6.0,
                bottom: 6.0,
                left: 4 + contentNtf.pannelPadding.left,
                right: 4 + contentNtf.pannelPadding.right,
              ),
              child: RepaintBoundary(
                child: Row(
                  children: [
                    _topButton(
                      onTap: Navigator.of(context).maybePop,
                      child: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          children: [
                            _topButton(
                              onTap: () {
                                contentNtf.showCname.value = false;
                                contentNtf.controller?.goIdle();
                                var cid = contentNtf.tData.cid!;
                                var page = contentNtf.currentPage;
                                var bookid = contentNtf.bookId;

                                contentNtf
                                  ..dump()
                                  ..out();
                                setOrientation(true);
                                uiOverlay(hide: false);
                                // OptionsNotifier.autoSetStatus(context);
                                final cache = context.read<BookCacheNotifier>();
                                BookInfoPage.push(
                                        context, bookid, contentNtf.api)
                                    .then((_) async {
                                  final list = await cache.getList;
                                  for (final bookCache in list) {
                                    if (bookCache.bookId == bookid) {
                                      cid = bookCache.chapterId ?? cid;
                                      page = bookCache.page ?? page;
                                      break;
                                    }
                                  }
                                  contentNtf
                                    ..inbook()
                                    ..newBookOrCid(bookid, cid, page,
                                        api: contentNtf.api);
                                  setOrientation(
                                      contentNtf.config.value.orientation!);
                                  uiOverlay(
                                      hide: !contentNtf
                                          .config.value.orientation!);
                                  uiStyle(dark: true);
                                });
                              },
                              text: '详情页',
                            ),
                            _topButton(
                                text: '重新下载',
                                onTap: () => contentNtf.updateCurrent()),
                            _topButton(
                                text: '阴影', onTap: () => contentNtf.shadow()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 属性设置页面
class BookSettingsView extends StatefulWidget {
  const BookSettingsView({
    Key? key,
    required this.showSettings,
    required this.close,
  }) : super(key: key);
  final ValueNotifier<SettingView> showSettings;
  final void Function([void Function()?]) close;
  @override
  _BookSettingsViewState createState() => _BookSettingsViewState();
}

class _BookSettingsViewState extends State<BookSettingsView> {
  final ValueNotifier<double> fontvalue = ValueNotifier(10.0);
  final ValueNotifier<double> fontHvalue = ValueNotifier(1.0);
  ValueNotifier<Color> bgColor = ValueNotifier(Colors.transparent);
  ValueNotifier<Color> ftColor = ValueNotifier(Colors.transparent);

  late ContentNotifier bloc;
  // late ChangeNotifierSelector<ContentViewConfig, bool> _audioNotifier;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    update();
  }

  void update() {
    final color = bloc.config.value.bgcolor!;
    final fcolor = bloc.config.value.fontColor!;
    fontvalue.value = bloc.config.value.fontSize!;
    fontHvalue.value = bloc.config.value.lineTweenHeight!;
    bgColor.value = color;
    ftColor.value = fcolor;
  }

  //TODO: 添加配色保存功能
  Widget settings() {
    var fontSlider = Row(
      children: [
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: fontvalue,
              builder: (context, child) {
                return Slider(
                  value: fontvalue.value < 10.0 ? 10.0 : fontvalue.value,
                  onChanged: (double value) {
                    fontvalue.value = value;
                  },
                  min: 10.0,
                  max: 40.0,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: fontHvalue,
              builder: (context, child) {
                return Slider(
                  value: fontHvalue.value,
                  onChanged: (double value) {
                    fontHvalue.value = value;
                  },
                  min: 1,
                  max: 3.0,
                );
              },
            ),
          ),
        ),
      ],
    );
    var fontSize = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
                animation: fontvalue,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '字体大小: ${fontvalue.value.toInt()}',
                      softWrap: false,
                    ),
                  );
                }),
          ),
        ),
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
                animation: fontHvalue,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '行间距: ${fontHvalue.value.toStringAsFixed(2)}',
                      softWrap: false,
                    ),
                  );
                }),
          ),
        ),
      ],
    );
    var autoValue = Row(
      children: [
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: bloc.autoValue,
              builder: (context, child) {
                return Slider(
                  value: bloc.autoValue.value.clamp(1, 10),
                  onChanged: (double value) {
                    bloc.autoValue.value = value;
                  },
                  min: 1,
                  max: 10,
                );
              },
            ),
          ),
        ),
      ],
    );
    var bottom = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
          child: btn1(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            radius: 40,
            onTap: update,
            child: Center(
                child: Text(
              '重置',
              style: TextStyle(color: Colors.white),
            )),
            bgColor: Colors.blueGrey.shade800,
            splashColor: Colors.blueAccent.shade100,
          ),
        ),
        Container(
          width: 120,
          padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
          child: btn1(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            radius: 40,
            onTap: () {
              bloc.setPrefs(bloc.config.value.copyWith(
                bgcolor: bgColor.value,
                fontSize: fontvalue.value.floorToDouble(),
                lineTweenHeight: fontHvalue.value,
                fontColor: ftColor.value,
              ));
            },
            child: Center(
                child: Text(
              '保存设置',
              style: TextStyle(color: Colors.white),
            )),
            bgColor: Colors.blueGrey.shade800,
            splashColor: Colors.blueAccent.shade100,
          ),
        ),
      ],
    );
    var padding2 = Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: bgColor,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: bgColor.value,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: AnimatedBuilder(
                    animation: ftColor,
                    builder: (context, child) {
                      return Text('字体颜色',
                          style: TextStyle(color: ftColor.value));
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  padding2,
                  RepaintBoundary(
                    child: Container(
                      height: 106,
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        children: [
                          fontSize,
                          fontSlider,
                          const SizedBox(height: 5),
                          RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: bloc.autoValue,
                              builder: (context, child) {
                                return Text(
                                    '滚动速度: ${bloc.autoValue.value.toStringAsFixed(2)}');
                              },
                            ),
                          ),
                          autoValue,
                        ],
                      ),
                    ),
                  ),
                  RepaintBoundary(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                                animation: bloc.brightness,
                                builder: (context, _) {
                                  return Slider(
                                      value: bloc.brightness.value,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: bloc.setBrightness);
                                }),
                          ),
                        ),
                        AnimatedBuilder(
                            animation: bloc.follow,
                            builder: (context, _) {
                              return Checkbox(
                                  value: bloc.follow.value,
                                  onChanged: bloc.setFollow);
                            }),
                        Center(child: Text('跟随系统')),
                      ],
                    ),
                  )),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Flexible(
                        child: _builder(
                            !context.isDarkMode,
                            '选择背景颜色',
                            () => HueRingPicker(
                                  onColorChanged: (Color value) {
                                    bgColor.value = value;
                                  },
                                  pickerColor: bgColor.value,
                                )),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: _builder(
                            !context.isDarkMode,
                            '选择字体颜色',
                            () => HueRingPicker(
                                  onColorChanged: (Color value) {
                                    ftColor.value = value;
                                  },
                                  pickerColor: ftColor.value,
                                )),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        RepaintBoundary(child: bottom)
      ],
    );
  }

  Widget _builder(bool light, String text, Widget Function() builder) {
    return btn1(
      elevation: 0.5,
      radius: 10.0,
      bgColor: light ? null : Color.fromRGBO(25, 25, 25, 1),
      splashColor: light ? null : Color.fromARGB(255, 99, 99, 99),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
          child: Text(
        text,
        style: TextStyle(
            color: light ? Colors.grey.shade700 : Colors.grey.shade400),
      )),
      onTap: () {
        showDialog(
            builder: (BuildContext context) {
              return Center(
                  child: RepaintBoundary(
                child: Material(
                  color: !context.isDarkMode
                      ? Color.fromARGB(255, 224, 224, 224)
                      : Color.fromARGB(255, 41, 41, 41),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicWidth(
                      child: SingleChildScrollView(child: builder()),
                    ),
                  ),
                ),
              ));
            },
            context: context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: widget.showSettings,
      builder: (context, child) {
        final children = [
          IndexsWidget(
            onTap: (context, id, cid) {
              final index = context.read<BookIndexNotifier>();
              // 先完成动画再调用
              widget.close(() {
                index.loadIndexs(id, cid, api: bloc.api);
                bloc.newBookOrCid(id, cid, 1, api: bloc.api);
              });
            },
          ),
          settings(),
          const SizedBox(),
        ];
        return children[widget.showSettings.value.index];
      },
    );

    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbColor: Colors.grey.shade300,
          inactiveTrackColor: Colors.grey,
          activeTrackColor: Colors.blue,
          minThumbSeparation: 2,
          valueIndicatorTextStyle: TextStyle(),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
          thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6, pressedElevation: 4, elevation: 5),
        ),
        child: RepaintBoundary(child: child));
  }
}
