import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'pan_slide.dart';

import '../../../bloc/bloc.dart';
import '../../../utils/utils.dart';
import '../../book_info_view/book_info_page.dart';
import '../../embed/indexs.dart';
import '../book_content_page.dart';
import 'color_picker.dart';
import 'page_view_controller.dart';

class Pannel extends StatefulWidget {
  const Pannel({
    Key? key,
    required this.controller,
    required this.showCname,
  }) : super(key: key);

  final NopPageViewController controller;
  final ValueNotifier<bool> showCname;
  @override
  _PannelState createState() => _PannelState();
}

class _PannelState extends State<Pannel> {
  Timer? timer;
  late ContentNotifier bloc;
  late BookIndexBloc indexBloc;

  @override
  void initState() {
    super.initState();
    widget.showCname.value = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    indexBloc = context.read<BookIndexBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final child = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: Colors.grey.shade300,
        inactiveTrackColor: Colors.grey,
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
                showCname: widget.showCname,
                indexBloc: indexBloc,
                bloc: bloc,
                getTimer: () => timer),
          ),
          RepaintBoundary(
            child: Container(
              color: Colors.grey.shade900,
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
                      padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          btn1(
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
                                    fontSize: 13, color: Colors.grey.shade300),
                              )),
                              bgColor: Colors.transparent,
                              splashColor: Colors.grey.shade700),
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
                                        widget.showCname.value = false;
                                        indexBloc.slide.value =
                                            indexBloc.sldvalue.index;
                                      });
                                    },
                                    onChangeStart: (value) {
                                      timer?.cancel();
                                      widget.showCname.value = true;
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
                      child: BottomEnd(
                        showCname: widget.showCname,
                        controller: widget.controller,
                      ),
                    ),
                  ],
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
    required this.showCname,
  }) : super(key: key);

  final BookIndexBloc indexBloc;
  final ContentNotifier bloc;
  // timer 会更改，回调得到当前的引用
  final Timer? Function() getTimer;
  final ValueNotifier<bool> showCname;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: showCname,
      builder: (context, child) {
        if (showCname.value) {
          return BlocBuilder<BookIndexBloc, BookIndexState>(
            builder: (context, state) {
              if (state is BookIndexWidthData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AnimatedBuilder(
                    animation: indexBloc.slide,
                    builder: (context, child) {
                      var v = indexBloc.slide.value.toInt();
                      var text = '';
                      var cid = -1;
                      for (var l in state.bookIndexs) {
                        if (v < l.length - 1) {
                          final BookIndexShort ins = l[v + 1];
                          text = ins.cname!;
                          cid = ins.cid!;
                          break;
                        }
                        v -= (l.length - 1);
                      }
                      return GestureDetector(
                        onTap: () {
                          if (!bloc.loading.value) {
                            getTimer()?.cancel();
                            showCname.value = false;
                            bloc.newBookOrCid(state.id, cid, 1, inBook: true);
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
              } else {
                return Container();
              }
            },
            buildWhen: (_, newState) => newState is BookIndexWidthData,
          );
        }
        return Container();
      },
    );
  }
}

class BottomEnd extends StatefulWidget {
  const BottomEnd({
    Key? key,
    required this.showCname,
    required this.controller,
  }) : super(key: key);

  final ValueNotifier<bool> showCname;
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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    // child: Material(
    //   color: Colors.transparent,
    child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        // borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
        )),
    // ),
  );
}

Widget _topButton(
    {Widget? child,
    String? text,
    required VoidCallback onTap,
    VoidCallback? onLongPress}) {
  assert(child != null || text != null);
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: child ??
            Text(
              '$text',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
            ),
      ));
}

class _BottomEndState extends State<BottomEnd> {
  late ContentNotifier bloc;
  late BookIndexBloc indexBloc;
  PanSlideController? controller;
  final ValueNotifier<SettingView> showSettings =
      ValueNotifier(SettingView.none);
  Size bsize = const Size(0.0, 10);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    indexBloc = context.read<BookIndexBloc>();
  }

  PanSlideController getController() {
    // 只要不被释放，就意味着还可用
    if (controller != null && !controller!.close) return controller!;
    controller = PanSlideController.showPan(
      context,
      onhide: onhideEnd,
      builder: (contxt, _controller) {
        return RepaintBoundary(
          child: PannelSlide(
            useDefault: false,
            controller: _controller,
            middleChild: (context, animation) {
              // return Center(child: Container(color: Colors.blue, height: 100, width: 100));
              final op = Tween<Offset>(
                  begin: const Offset(-0.25, 0), end: Offset.zero);
              final curve = CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                  reverseCurve: Curves.ease.flipped);
              final position = curve.drive(op);
              return RepaintBoundary(
                child: SlideTransition(
                  position: position,
                  child: FadeTransition(
                    opacity: curve,
                    child: BookSettingsView(
                      showSettings: showSettings,
                      bottomHeight: bsize.height,
                      close: _controller.hideOnCallback,
                    ),
                  ),
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
  void onshowEnd() =>
      indexBloc.add(BookIndexShowEvent(id: bloc.bookid, cid: bloc.tData.cid));

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = size.height >= size.width ? bloc.safeBottom : 0.0;
    return Padding(
      padding: EdgeInsets.only(top: 6.0, bottom: 12.0 + bottom),
      child: Row(
        children: [
          Expanded(
            child: bottomButton(
              onTap: () {
                bsize = context.size ?? bsize;
                if (showSettings.value != SettingView.indexs) {
                  getController().show();
                  widget.showCname.value = false;
                  context.read<BookIndexBloc>().add(
                      BookIndexShowEvent(id: bloc.bookid, cid: bloc.tData.cid));
                  showSettings.value = SettingView.indexs;
                } else {
                  getController().trigger();
                }
              },
              onLongPress: () {
                bsize = context.size ?? bsize;

                if (showSettings.value != SettingView.indexs) {
                  getController().show();
                  widget.showCname.value = false;
                  context.read<BookIndexBloc>()
                    ..bookUpDateTime.remove(bloc.bookid)
                    ..add(BookIndexShowEvent(
                        id: bloc.bookid, cid: bloc.tData.cid));
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
                  widget.showCname.value = false;
                  showSettings.value = SettingView.setting;
                } else {
                  getController().trigger();
                }
              },
              text: '设置',
              icon: Icons.settings_rounded,
            ),
          ),
          // Expanded(
          //   child: StatefulBuilder(builder: (context, setstate) {
          //     return bottomButton(
          //       onTap: () {
          //         setstate(bloc.auto);
          //       },
          //       child: Text(
          //         '${!bloc.isActive ? '开始' : '停止'}滚动',
          //         style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
          //       ),
          //       icon: Icons.auto_stories,
          //     );
          //   }),
          // ),
          Expanded(
            child: bottomButton(
              onTap: bloc.auto,
              child: AnimatedBuilder(
                animation: bloc.isActive,
                builder: (context, child) {
                  return Text(
                    '${!bloc.isActive.value ? '开始' : '停止'}滚动',
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
                bloc.stopAuto();
                final portrait = !bloc.config.value.portrait!;
                uiOverlay(hide: !portrait);
                bloc.setPrefs(bloc.config.value.copyWith(portrait: portrait));
              },
              child: AnimatedBuilder(
                animation: bloc.config,
                builder: (context, _) {
                  return Text(
                    '切换${bloc.config.value.portrait! ? '横屏' : '竖屏'}',
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
                // widget.controller.axis = _axis;
                bloc.stopAuto();
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
    );
  }
}

class TopPannel extends StatefulWidget {
  const TopPannel({
    Key? key,
    required this.showCname,
  }) : super(key: key);

  final ValueNotifier<bool> showCname;

  @override
  _TopPannelState createState() => _TopPannelState();
}

class _TopPannelState extends State<TopPannel> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Colors.grey.shade900,
        child: Consumer<ContentNotifier>(
          builder: (context, bloc, child) {
            return Padding(
              padding: EdgeInsets.only(
                top: bloc.safePadding.top + 12.0,
                bottom: 12.0,
                left: 10.0 + bloc.safePadding.left,
                right: 10.0 + bloc.safePadding.right,
              ),
              child: Container(
                  height: 40,
                  child: Row(
                    children: [
                      _topButton(
                        onTap: () {
                          // 调用 [WillPopScope] 注册的回调
                          Navigator.maybePop(context);
                        },
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
                                  widget.showCname.value = false;

                                  /// 由于只有一个[PainterBloc]实例，保存状态
                                  final route = MaterialPageRoute(
                                      builder: (_) => BookInfoPage());

                                  var cid = bloc.tData.cid!;
                                  var page = bloc.currentPage;
                                  var bookid = bloc.bookid!;

                                  context
                                      .read<BookInfoBloc>()
                                      .add(BookInfoEventSentWithId(bookid));
                                  bloc
                                    ..dump()
                                    ..out();
                                  context.read<BookCacheBloc>().load();
                                  final cache = context.read<BookCacheBloc>();
                                  Navigator.of(context).push(route).then((_) {
                                    // 重复进入相同书籍，会改变状态
                                    for (final bookCache
                                        in cache.state.sortChildren) {
                                      if (bookCache.id == bookid) {
                                        cid = bookCache.chapterId!;
                                        page = bookCache.page!;
                                        break;
                                      }
                                    }
                                    bloc.newBookOrCid(bookid, cid, page);
                                  });
                                },
                                text: '详情页',
                              ),
                              _topButton(
                                  text: '性能图层',
                                  onTap: () {
                                    final opt = context.read<OptionsNotifier>();
                                    opt.options = ConfigOptions(
                                      showPerformanceOverlay: opt.options
                                                  .showPerformanceOverlay !=
                                              null
                                          ? !opt.options.showPerformanceOverlay!
                                          : true,
                                    );
                                  }),
                              _topButton(
                                  text: '重新下载',
                                  onTap: () => bloc.updateCurrent()),
                              _topButton(
                                  text: '阴影', onTap: () => bloc.showdow()),
                              _topButton(
                                  text: '删除缓存',
                                  onTap: () => bloc.deleteCache(bloc.bookid!)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }
}

/// 属性设置页面
class BookSettingsView extends StatefulWidget {
  const BookSettingsView(
      {Key? key,
      required this.showSettings,
      required this.close,
      this.bottomHeight = 0.0})
      : super(key: key);
  final ValueNotifier<SettingView> showSettings;
  final void Function([void Function()?]) close;
  final double bottomHeight;
  @override
  _BookSettingsViewState createState() => _BookSettingsViewState();
}

class _BookSettingsViewState extends State<BookSettingsView> {
  final ValueNotifier<double> bgBrightness = ValueNotifier(1.0);
  final ValueNotifier<double> ftBrightness = ValueNotifier(1.0);
  final ValueNotifier<double> fontvalue = ValueNotifier(10.0);
  final ValueNotifier<double> fontHvalue = ValueNotifier(1.0);
  late ValueNotifier<HSVColor> bgColor;
  late ValueNotifier<HSVColor> ftColor;
  late ContentNotifier bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ContentNotifier>();
    final color = bloc.config.value.bgcolor!;
    final fcolor = bloc.config.value.fontColor!;
    fontvalue.value = bloc.config.value.fontSize!;
    fontHvalue.value = bloc.config.value.lineTweenHeight!;
    final hsv = HSVColor.fromColor(color);
    final hsvf = HSVColor.fromColor(fcolor);
    bgColor = ValueNotifier(hsv);
    ftColor = ValueNotifier(hsvf);
    bgBrightness.value = hsv.value;
    ftBrightness.value = hsvf.value;
  }

  Widget background({required Widget child}) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                    onTap: widget.close,
                    child: Container(color: Colors.transparent)),
                Positioned(
                  top: 10.0 + bloc.safePadding.top,
                  left: 24.0 + bloc.safePadding.left,
                  right: 24.0 + bloc.safePadding.right,
                  bottom: 0,
                  child: GestureDetector(
                    child: RepaintBoundary(
                      child: Material(
                        borderRadius: BorderRadius.circular(6.0),
                        color: Colors.grey.shade300,
                        clipBehavior: Clip.hardEdge,
                        elevation: 4.0,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 10 + widget.bottomHeight)
        ],
      ),
    );
  }

  void onChange(HSVColor c) {
    ftColor.value = c;
  }

  void onChangev(HSVColor c) {
    bgColor.value = c;
  }

  Widget settings() {
    return background(
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: AnimatedBuilder(
                                      animation: ftColor,
                                      builder: (context, child) {
                                        return Text('字体颜色',
                                            style: TextStyle(
                                                color:
                                                    ftColor.value.toColor()));
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: Container(
                          height: 150,
                          child: Row(
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
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: bgBrightness,
                                        builder: (context, child) {
                                          return Slider(
                                            value: bgBrightness.value,
                                            onChanged: (double value) {
                                              bgColor.value = bgColor.value
                                                  .withValue(value);
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
                                              ftColor.value = ftColor.value
                                                  .withValue(value);
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
                              ),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                          animation: fontvalue,
                                          builder: (context, child) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(
                                                '行间距: ${fontHvalue.value.toStringAsFixed(2)}',
                                                softWrap: false,
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: fontvalue,
                                        builder: (context, child) {
                                          return Slider(
                                            value: fontvalue.value < 10.0
                                                ? 10.0
                                                : fontvalue.value,
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
                              ),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: bloc.autoValue,
                                        builder: (context, child) {
                                          return Slider(
                                            value: bloc.autoValue.value
                                                .clamp(1, 10),
                                            onChanged: (double value) {
                                              bloc.resetAuto();
                                              bloc.autoValue.value = value;
                                            },
                                            min: 1,
                                            max: 10,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Expanded(
                                  //   child: RepaintBoundary(
                                  //     child: AnimatedBuilder(
                                  //       animation: fontHvalue,
                                  //       builder: (context, child) {
                                  //         return Slider(
                                  //           value: fontHvalue.value,
                                  //           onChanged: (double value) {
                                  //             fontHvalue.value = value;
                                  //           },
                                  //           min: 1,
                                  //           max: 3.0,
                                  //         );
                                  //       },
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            RepaintBoundary(
              child: Container(
                width: 120,
                padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
                child: btn1(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: widget.showSettings,
      builder: (context, child) {
        switch (widget.showSettings.value) {
          case SettingView.indexs:
            return background(
              child: Container(
                child: IndexsWidget(
                  onTap: (context, id, cid) {
                    final index = context.read<BookIndexBloc>();
                    // 先完成动画再调用
                    widget.close(() {
                      index.add(BookIndexShowEvent(id: id, cid: cid));
                      bloc.newBookOrCid(id, cid, 1, inBook: true);
                    });
                  },
                ),
              ),
            );
          case SettingView.setting:
            return settings();
          default:
            return Container();
        }
      },
    );
    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbColor: Colors.grey.shade300,
          inactiveTrackColor: Colors.grey,
          minThumbSeparation: 2,
          valueIndicatorTextStyle: TextStyle(),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
          thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6, pressedElevation: 4, elevation: 5),
        ),
        child: child);
  }
}

typedef ChildBuilder = Widget Function(
    BuildContext, Animation<double> animation);

class PannelSlide extends StatefulWidget {
  const PannelSlide(
      {this.milliseconds,
      this.middleChild,
      this.botChild,
      this.topChild,
      this.leftChild,
      this.rightChild,
      required this.controller,
      this.useDefault = true})
      : assert(botChild != null ||
            topChild != null ||
            leftChild != null ||
            rightChild != null ||
            middleChild != null);
  final int? milliseconds;

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

  final _topInOffset =
      Tween<Offset>(begin: const Offset(0.0, -1), end: Offset.zero);
  final _botInOffset =
      Tween<Offset>(begin: const Offset(0.0, 1), end: Offset.zero);
  final _leftInOffset =
      Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);
  final _rightInOffset =
      Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero);
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
    botPositions = CurvedAnimation(
            parent: panSlideController.controller, curve: Curves.ease)
        .drive(_botInOffset);
    topPositions = CurvedAnimation(
            parent: panSlideController.controller, curve: Curves.ease)
        .drive(_topInOffset);
    leftPositions = CurvedAnimation(
            parent: panSlideController.controller, curve: Curves.ease)
        .drive(_leftInOffset);
    rightPositions = CurvedAnimation(
            parent: panSlideController.controller, curve: Curves.ease)
        .drive(_rightInOffset);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.botChild != null) {
      var bot = widget.botChild!(context, panSlideController.controller);
      if (widget.useDefault) {
        bot = SlideTransition(position: botPositions, child: bot);
      }
      children.add(Positioned(bottom: 0.0, left: 0.0, right: 0.0, child: bot));
    }
    if (widget.topChild != null) {
      var top = widget.topChild!(context, panSlideController.controller);
      if (widget.useDefault) {
        top = SlideTransition(position: topPositions, child: top);
      }
      children.add(Positioned(top: 0.0, left: 0.0, right: 0.0, child: top));
    }
    if (widget.rightChild != null) {
      var right = widget.rightChild!(context, panSlideController.controller);
      if (widget.useDefault) {
        right = SlideTransition(position: rightPositions, child: right);
      }
      children.add(Positioned(top: 0.0, bottom: 0.0, right: 0.0, child: right));
    }

    if (widget.leftChild != null) {
      var left = widget.leftChild!(context, panSlideController.controller);
      if (widget.useDefault) {
        left = SlideTransition(position: leftPositions, child: left);
      }
      children.add(Positioned(top: 0.0, left: 0.0, bottom: 0.0, child: left));
    }
    if (widget.middleChild != null) {
      var milldle = widget.middleChild!(context, panSlideController.controller);
      if (widget.useDefault) {
        milldle = SlideTransition(position: leftPositions, child: milldle);
      }
      children.add(Positioned.fill(child: RepaintBoundary(child: milldle)));
    }
    return Stack(children: children);
  }
}
