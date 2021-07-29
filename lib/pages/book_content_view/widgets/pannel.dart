import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../provider/provider.dart';
import '../../../widgets/indexs.dart';
import '../../book_info_view/book_info_page.dart';
import '../book_content_page.dart';
import 'color_picker.dart';
import 'page_view_controller.dart';
import 'pan_slide.dart';

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
                  animation: bloc.safePaddingNotifier,
                  builder: (context, child) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 10.0 + bloc.safePadding.left,
                        right: 10.0 + bloc.safePadding.right,
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
                return reloadBotton(indexBloc.loadIndexs);
              }
              final indexs = data.allChapters!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AnimatedBuilder(
                  animation: indexBloc.slide,
                  builder: (context, child) {
                    var v = indexBloc.slide.value.toInt();
                    var text = '';
                    var cid = -1;

                    if (v < indexs.length) {
                      final chapter = indexs[v];
                      text = chapter.name ?? text;
                      cid = chapter.id ?? cid;
                    }

                    return GestureDetector(
                      onTap: () {
                        if (!bloc.loading.value) {
                          getTimer()?.cancel();
                          bloc.showCname.value = false;
                          if (cid != -1)
                            bloc.newBookOrCid(data.bookid!, cid, 1,
                                inBook: true);
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
                Text('$text',
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
  return InkWell(
    onTap: onTap,
    onLongPress: onLongPress,
    borderRadius: BorderRadius.circular(10.0),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: child ??
          Text(
            '$text',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
          ),
    ),
  );
}

class _BottomEndState extends State<BottomEnd> {
  late ContentNotifier bloc;
  late BookIndexNotifier indexBloc;
  PanSlideController? controller;
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

  PanSlideController getController() {
    // 只要不被释放，就意味着还可用
    if (controller != null && !controller!.close) return controller!;
    context;
    controller = PanSlideController.showPan(
      this,
      onhideEnd: onhideEnd,
      builder: (contxt, _controller) {
        return RepaintBoundary(
          child: PannelSlide(
            useDefault: false,
            controller: _controller,
            middleChild: (context, animation, state) {
              // return Center(child: Container(color: Colors.blue, height: 100, width: 100));

              final curve =
                  CurveTween(curve: Curves.easeInOut).animate(animation);
              final position = curve.drive(op);
              final colors = debx.animate(animation);
              final padding = EdgeInsets.only(
                  top: 10.0 + bloc.safePadding.top,
                  left: 24.0 + bloc.safePadding.left,
                  right: 24.0 + bloc.safePadding.right,
                  bottom: 0);
              // if (state.hide.value) return const SizedBox();

              final bottom = 30 + bsize.height;
              return RepaintBoundary(
                child: CustomMultiChildLayout(
                  delegate: ModalPart(bottom),
                  children: [
                    LayoutId(
                      id: 'body',
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: state.hide,
                          builder: (context, _) {
                            return IgnorePointer(
                              ignoring: state.hide.value,
                              child: GestureDetector(
                                onTap: _controller.hideOnCallback,
                                child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: colors,
                                    builder: (context, child) {
                                      return ColoredBox(
                                        color:
                                            colors.value ?? Colors.transparent,
                                        child: GestureDetector(
                                            onTap: () {}, child: child),
                                      );
                                    },
                                    child: RepaintBoundary(
                                      child: SlideTransition(
                                        position: position,
                                        child: FadeTransition(
                                          opacity: curve,
                                          child: Padding(
                                            padding: padding,
                                            child: Material(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                              color: Colors.grey.shade300,
                                              clipBehavior: Clip.hardEdge,
                                              child: BookSettingsView(
                                                showSettings: showSettings,
                                                close:
                                                    _controller.hideOnCallback,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    LayoutId(
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
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    return controller!;
  }

  void onhideEnd() => showSettings.value = SettingView.none;
  void onshowEnd() => indexBloc.loadIndexs(bloc.bookid, bloc.tData.cid);

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final size = data.size;
    return RepaintBoundary(
        child: AnimatedBuilder(
      animation: bloc.safeBottom,
      builder: (context, child) {
        final bottom = size.height >= size.width ? bloc.safeBottom.value : 0.0;
        return Padding(
            padding: EdgeInsets.only(top: 6.0, bottom: 8.0 + bottom),
            child: child);
      },
      child: Row(
        children: [
          Expanded(
            child: bottomButton(
              onTap: () {
                bsize = context.size ?? bsize;
                if (showSettings.value != SettingView.indexs) {
                  getController().show();

                  bloc.showCname.value = false;
                  context
                      .read<BookIndexNotifier>()
                      .loadIndexs(bloc.bookid, bloc.tData.cid);
                  showSettings.value = SettingView.indexs;
                } else {
                  getController().trigger();
                }
              },
              onLongPress: () {
                bsize = context.size ?? bsize;

                if (showSettings.value != SettingView.indexs) {
                  getController().show();
                  bloc.showCname.value = false;
                  context.read<BookIndexNotifier>()
                    ..bookUpDateTime.remove(bloc.bookid)
                    ..loadIndexs(bloc.bookid, bloc.tData.cid);
                  showSettings.value = SettingView.indexs;
                } else {
                  getController().trigger();
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
                  getController().show();
                  bloc.showCname.value = false;
                  showSettings.value = SettingView.setting;
                } else {
                  getController().trigger();
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
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
                  );
                },
              ),
              icon: Icons.auto_stories,
            ),
          ),
          Expanded(
            child: bottomButton(
              onTap: () {
                getController().hide();
                bloc.autoRun.stopTicked();
                final portrait = !bloc.config.value.orientation!;
                uiOverlay(hide: !portrait);
                bloc.setPrefs(
                    bloc.config.value.copyWith(orientation: portrait));
              },
              child: AnimatedBuilder(
                animation: bloc.config,
                builder: (context, _) {
                  return Text(
                    '切换${bloc.config.value.orientation! ? '横屏' : '竖屏'}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
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
                    '${bloc.config.value.axis == Axis.horizontal ? '上下滚动' : '左右滑动'}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
                  );
                },
              ),
              icon: Icons.swap_vert_circle_rounded,
            ),
          ),
        ],
      ),
    ));
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
          animation: contentNtf.safePaddingNotifier,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.only(
                top: contentNtf.safePadding.top + 6.0,
                bottom: 6.0,
                left: 4 + contentNtf.safePadding.left,
                right: 4 + contentNtf.safePadding.right,
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
                                var bookid = contentNtf.bookid!;
              
                                contentNtf
                                  ..dump()
                                  ..out();
                                uiStyle();
                                final cache = context.read<BookCacheNotifier>();
                                BookInfoPage.push(context, bookid)
                                    .then((_) async {
                                  final list = await cache.getList;
                                  for (final bookCache in list) {
                                    if (bookCache.bookId == bookid) {
                                      cid = bookCache.chapterId ?? cid;
                                      page = bookCache.page ?? page;
                                      break;
                                    }
                                  }
              
                                  contentNtf.newBookOrCid(bookid, cid, page);
                                });
                              },
                              text: '详情页',
                            ),
                            _topButton(
                                text: '性能图层',
                                onTap: () {
                                  final opt = context.read<OptionsNotifier>();
                                  opt.options = ConfigOptions(
                                    showPerformanceOverlay:
                                        opt.options.showPerformanceOverlay != null
                                            ? !opt.options.showPerformanceOverlay!
                                            : true,
                                  );
                                }),
                            _topButton(
                                text: '重新下载',
                                onTap: () => contentNtf.updateCurrent()),
                            _topButton(
                                text: '阴影', onTap: () => contentNtf.showdow()),
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
  final ValueNotifier<double> bgBrightness = ValueNotifier(1.0);
  final ValueNotifier<double> ftBrightness = ValueNotifier(1.0);
  final ValueNotifier<double> fontvalue = ValueNotifier(10.0);
  final ValueNotifier<double> fontHvalue = ValueNotifier(1.0);
  late ValueNotifier<HSVColor> bgColor =
      ValueNotifier(HSVColor.fromColor(Colors.transparent));
  late ValueNotifier<HSVColor> ftColor =
      ValueNotifier(HSVColor.fromColor(Colors.transparent));

  late ContentNotifier bloc;
  Widget? _setting;

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
    final hsv = HSVColor.fromColor(color);
    final hsvf = HSVColor.fromColor(fcolor);
    bgColor.value = hsv;
    ftColor.value = hsvf;
    bgBrightness.value = hsv.value;
    ftBrightness.value = hsvf.value;
  }

  void onChange(HSVColor c) {
    ftColor.value = c;
  }

  void onChangev(HSVColor c) {
    bgColor.value = c;
  }

  Widget settings() {
    if (_setting != null) return _setting!;
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
    var colorSelector = Row(
      children: [
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: bgBrightness,
              builder: (context, child) {
                return Slider(
                  value: bgBrightness.value,
                  onChanged: (double value) {
                    bgColor.value = bgColor.value.withValue(value);
                    bgBrightness.value = value;
                  },
                  min: 0.0,
                  max: 1.0,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: ftBrightness,
              builder: (context, child) {
                return Slider(
                  value: ftBrightness.value,
                  onChanged: (double value) {
                    ftColor.value = ftColor.value.withValue(value);
                    ftBrightness.value = value;
                  },
                  min: 0.0,
                  max: 1.0,
                );
              },
            ),
          ),
        ),
      ],
    );
    var onChangeChild = Row(
      children: [
        Expanded(
          child: Center(
            child: SelectColor(
              onChangeUpdate: onChangev,
              onChangeDown: onChangev,
              onChangeEnd: onChangev,
              value: bgBrightness,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SelectColor(
              onChangeUpdate: onChange,
              onChangeDown: onChange,
              onChangeEnd: onChange,
              value: ftBrightness,
            ),
          ),
        ),
      ],
    );
    var fontSize = Row(
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
                bgcolor: bgColor.value.toColor(),
                fontSize: fontvalue.value.floorToDouble(),
                lineTweenHeight: fontHvalue.value,
                fontColor: ftColor.value.toColor(),
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
                color: bgColor.value.toColor(),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: AnimatedBuilder(
                    animation: ftColor,
                    builder: (context, child) {
                      return Text('字体颜色',
                          style: TextStyle(color: ftColor.value.toColor()));
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    return _setting = Column(
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
                      height: 150,
                      child: onChangeChild,
                    ),
                  ),
                  RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        children: [
                          colorSelector,
                        ],
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: Container(
                      height: 106,
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        children: [
                          fontSize,
                          fontSlider,
                          SizedBox(height: 5),
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
                ],
              ),
            ),
          ),
        ),
        RepaintBoundary(child: bottom)
      ],
    );
  }

  List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    children ??= [
      IndexsWidget(
        onTap: (context, id, cid) {
          final index = context.read<BookIndexNotifier>();
          // 先完成动画再调用
          widget.close(() {
            index.loadIndexs(id, cid);
            bloc.newBookOrCid(id, cid, 1, inBook: true);
          });
        },
      ),
      settings(),
      const SizedBox(),
    ];
    Widget child = AnimatedBuilder(
      animation: widget.showSettings,
      builder: (context, child) {
        return IndexedStack(
            index: widget.showSettings.value.index, children: children!);
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

typedef ChildBuilder = Widget Function(
    BuildContext, Animation<double>, _PannelSlideState);

class PannelSlide extends StatefulWidget {
  const PannelSlide(
      {this.middleChild,
      this.botChild,
      this.topChild,
      this.leftChild,
      this.rightChild,
      this.modal = false,
      this.ignoreBottomHeight = 0.0,
      required this.controller,
      this.useDefault = true})
      : assert(botChild != null ||
            topChild != null ||
            leftChild != null ||
            rightChild != null ||
            middleChild != null);
  final bool modal;
  final double ignoreBottomHeight;
  final PanSlideController controller;
  final ChildBuilder? botChild;
  final ChildBuilder? topChild;
  final ChildBuilder? leftChild;
  final ChildBuilder? rightChild;
  final ChildBuilder? middleChild;
  final bool useDefault;
  @override
  _PannelSlideState createState() => _PannelSlideState();
}

class _PannelSlideState extends State<PannelSlide> {
  late PanSlideController panSlideController;
  late Animation<Offset> botPositions;
  late Animation<Offset> topPositions;
  late Animation<Offset> leftPositions;
  late Animation<Offset> rightPositions;
  late Animation<double> modalAnimation;
  late Animation<Color?> colorsAnimation;
  final _topInOffset =
      Tween<Offset>(begin: const Offset(0.0, -1), end: Offset.zero);
  final _botInOffset =
      Tween<Offset>(begin: const Offset(0.0, 1), end: Offset.zero);
  final _leftInOffset =
      Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);
  final _rightInOffset =
      Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero);
  final modalTween = Tween<double>(begin: 0.0, end: 1.0);
  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  void didUpdateWidget(covariant PannelSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateState();
  }

  void updateState() {
    panSlideController = widget.controller;
    final controller = panSlideController.controller;
    // final _curve = CurvedAnimation(parent: controller, curve: Curves.ease);
    // final _curveAnimation = _curve;
    botPositions = CurvedAnimation(parent: controller, curve: Curves.ease)
        .drive(_botInOffset);
    topPositions = CurvedAnimation(parent: controller, curve: Curves.ease)
        .drive(_topInOffset);
    leftPositions = CurvedAnimation(parent: controller, curve: Curves.ease)
        .drive(_leftInOffset);
    rightPositions = CurvedAnimation(parent: controller, curve: Curves.ease)
        .drive(_rightInOffset);
    modalAnimation = CurvedAnimation(parent: controller, curve: Curves.ease)
        .drive(modalTween);

    colorsAnimation = debx.animate(modalAnimation);

    controller.removeStatusListener(statusListen);
    controller.addStatusListener(statusListen);
    statusListen(controller.status);
  }

  @override
  void dispose() {
    panSlideController.controller.removeStatusListener(statusListen);
    super.dispose();
  }

  void statusListen(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      hide.value = true;
    } else {
      hide.value = false;
    }
  }

  final debx =
      ColorTween(begin: Colors.transparent, end: Colors.black87.withAlpha(100));

  final hide = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.modal) {
      children.add(Positioned.fill(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: colorsAnimation,
            builder: (context, child) {
              if (hide.value) return const SizedBox();

              return child!;
            },
            child: ColoredBox(
              color: colorsAnimation.value ?? Colors.transparent,
              child: widget.ignoreBottomHeight == 0.0
                  ? GestureDetector(
                      onTap: panSlideController.hideOnCallback,
                      child: const SizedBox.expand())
                  : Column(
                      children: [
                        GestureDetector(
                            onTap: panSlideController.hideOnCallback,
                            child: Expanded(child: const SizedBox())),
                        SizedBox(height: widget.ignoreBottomHeight)
                      ],
                    ),
            ),
          ),
        ),
      ));
    }
    if (widget.botChild != null) {
      var bot = widget.botChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        bot = SlideTransition(position: botPositions, child: bot);
      }
      children.add(Positioned(bottom: 0.0, left: 0.0, right: 0.0, child: bot));
    }
    if (widget.topChild != null) {
      var top = widget.topChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        top = SlideTransition(position: topPositions, child: top);
      }
      children.add(Positioned(top: 0.0, left: 0.0, right: 0.0, child: top));
    }
    if (widget.rightChild != null) {
      var right =
          widget.rightChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        right = SlideTransition(position: rightPositions, child: right);
      }
      children.add(Positioned(top: 0.0, bottom: 0.0, right: 0.0, child: right));
    }

    if (widget.leftChild != null) {
      var left =
          widget.leftChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        left = SlideTransition(position: leftPositions, child: left);
      }
      children.add(Positioned(top: 0.0, left: 0.0, bottom: 0.0, child: left));
    }
    if (widget.middleChild != null) {
      var milldle =
          widget.middleChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        milldle = SlideTransition(position: leftPositions, child: milldle);
      }
      children.add(Positioned.fill(child: RepaintBoundary(child: milldle)));
    }
    return Stack(children: children);
  }
}

class ModalPart extends MultiChildLayoutDelegate {
  ModalPart(this.bottom);
  final double bottom;

  @override
  void performLayout(Size size) {
    final _body = 'body';
    final _bottom = 'bottom';
    final height = size.height;
    final width = size.width;

    final constraints =
        BoxConstraints.tightFor(width: width, height: height - bottom);
    layoutChild(_body, constraints);
    positionChild(_body, Offset.zero);
    final bottomConstraints =
        BoxConstraints.tightFor(width: width, height: bottom);
    layoutChild(_bottom, bottomConstraints);
    positionChild(_bottom, Offset(0, height - bottom));
  }

  @override
  bool shouldRelayout(covariant ModalPart oldDelegate) {
    return bottom != oldDelegate.bottom;
  }
}
