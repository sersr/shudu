import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../bloc/bloc.dart';

import '../../../bloc/book_index_bloc.dart';
import '../../../bloc/book_info_bloc.dart';
import '../../../bloc/book_repository.dart';
import '../../../bloc/painter_bloc.dart';
import '../../../utils/utils.dart';
import '../../book_info_view/book_info_page.dart';
import '../../embed/indexs.dart';
import 'color_picker.dart';
import '../painter_page.dart';
import 'page_view_controller.dart';

class Pannel extends StatefulWidget {
  const Pannel({
    Key? key,
    required this.willPop,
    required this.showPannel,
    required this.controller,
    required this.showSettings,
    required this.showCname,
  }) : super(key: key);

  final ValueNotifier<bool> showPannel;
  final NopPageViewController controller;
  final Future<bool> Function() willPop;
  final ValueNotifier<SettingView> showSettings;
  final ValueNotifier<bool> showCname;
  @override
  _PannelState createState() => _PannelState();
}

class _PannelState extends State<Pannel> {
  Timer? timer;
  late PainterBloc bloc;
  late BookIndexBloc indexBloc;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
    indexBloc = context.read<BookIndexBloc>();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  var hide = ValueNotifier<bool>(true);
  @override
  Widget build(BuildContext context) {
    final child = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: Colors.grey.shade300,
        inactiveTrackColor: Colors.grey,
        minThumbSeparation: 2,
        valueIndicatorTextStyle: TextStyle(),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6, pressedElevation: 4, elevation: 5),
      ),
      child: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              child: BookSettingsView(
                showSettings: widget.showSettings,
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: widget.showCname,
              builder: (context, child) {
                if (widget.showCname.value) {
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
                                    timer?.cancel();
                                    widget.showCname.value = false;
                                    final bloc = context.read<PainterBloc>();
                                    bloc.newBookOrCid(state.id, cid, 1);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: Colors.grey.shade900.withAlpha(210),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                  child: Text(
                                    text,
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),
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
            ),
          ),
          AnimatedBuilder(
            animation: widget.showPannel,
            builder: (context, child) {
              if (widget.showPannel.value) {
                hide.value = false;
                indexBloc.add(BookIndexShowEvent(id: bloc.bookid, cid: bloc.tData.cid));
              }
              return AnimatedOpacity(
                opacity: widget.showPannel.value ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                onEnd: () {
                  hide.value = !widget.showPannel.value;
                  if (bloc.size.height > bloc.size.width) {
                    if (widget.showPannel.value) {
                      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                    } else {
                      uiOverlay();
                    }
                  }
                },
                child: AnimatedBuilder(
                    animation: hide,
                    builder: (context, _) {
                      if (hide.value) {
                        return Container();
                      }
                      return child!;
                    }),
              );
            },
            child: RepaintBoundary(
              child: Container(
                color: Colors.grey.shade900.withAlpha(218),
                child: Padding(
                  padding: EdgeInsets.only(left: bloc.safePadding.left),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: btn1(
                                  radius: 40,
                                  onTap: () {
                                    if (!bloc.loading.value) {
                                      widget.showSettings.value = SettingView.none;
                                      final bloc = context.read<PainterBloc>();
                                      bloc.goPre();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Center(
                                        child: Text(
                                      '上一章',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                                    )),
                                  ),
                                  bgColor: Colors.grey.shade900,
                                  splashColor: Colors.grey.shade700),
                            ),
                            Expanded(
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
                                      timer = Timer(Duration(milliseconds: 1500), () {
                                        widget.showCname.value = false;
                                        indexBloc.slide.value = indexBloc.sldvalue.index;
                                      });
                                    },
                                    onChangeStart: (value) {
                                      timer?.cancel();
                                      widget.showCname.value = true;
                                      widget.showSettings.value = SettingView.none;
                                    },
                                    min: 0.0,
                                    max: indexBloc.sldvalue.max.toDouble(),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: btn1(
                                  radius: 40,
                                  onTap: () {
                                    if (!bloc.loading.value) {
                                      widget.showSettings.value = SettingView.none;
                                      final bloc = context.read<PainterBloc>();
                                      bloc.goNext();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Center(
                                      child: Text(
                                        '下一章',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                  bgColor: Colors.grey.shade900,
                                  // radius: 6.0,
                                  splashColor: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      BottomEnd(
                        show: widget.showPannel,
                        showSettings: widget.showSettings,
                        showCname: widget.showCname,
                        willPop: widget.willPop,
                        controller: widget.controller,
                        end: hide,
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

class BottomEnd extends StatefulWidget {
  const BottomEnd({
    Key? key,
    required this.show,
    required this.showSettings,
    required this.showCname,
    required this.willPop,
    required this.controller,
    required this.end,
  }) : super(key: key);

  final ValueNotifier<SettingView> showSettings;
  final ValueNotifier<bool> showCname;
  final Future<bool> Function() willPop;
  final NopPageViewController controller;
  final ValueNotifier<bool> show;
  final ValueNotifier<bool> end;
  @override
  _BottomEndState createState() => _BottomEndState();
}

Widget bottomButton({Widget? child, String? text, required VoidCallback onTap, VoidCallback? onLongPress}) {
  assert(child != null || text != null);
  return Padding(
    padding: const EdgeInsets.only(left: 12.0),
    child: btn1(
        onTap: onTap,
        onLongPress: onLongPress,
        child: child ??
            Text(
              text!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
            ),
        bgColor: Colors.grey.shade900,
        radius: 6.0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        splashColor: Colors.grey.shade700),
  );
}

class _BottomEndState extends State<BottomEnd> {
  late PainterBloc bloc;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
  }

  final rate60 = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = size.height >= size.width ? bloc.repository.bottomHeight.toDouble() : 0.0;
    return Padding(
      padding: EdgeInsets.only(
        top: 6.0,
        bottom: 10.0 + bottom,
        right: 10.0 + bloc.paddingRect.right,
      ),
      child: Row(
        children: [
          bottomButton(
            onTap: () {
              if (widget.showSettings.value == SettingView.indexs) {
                widget.showSettings.value = SettingView.none;
              } else {
                widget.showCname.value = false;
                context.read<BookIndexBloc>().add(BookIndexShowEvent(id: bloc.bookid, cid: bloc.tData.cid));
                widget.showSettings.value = SettingView.indexs;
              }
            },
            onLongPress: () {
              if (widget.showSettings.value == SettingView.indexs) {
                widget.showSettings.value = SettingView.none;
              } else {
                widget.showCname.value = false;
                context.read<BookIndexBloc>()
                  ..bookUpDateTime.remove(bloc.bookid)
                  ..add(BookIndexShowEvent(id: bloc.bookid, cid: bloc.tData.cid));
                widget.showSettings.value = SettingView.indexs;
              }
            },
            text: '目录',
          ),
          bottomButton(
            onTap: () {
              if (widget.showSettings.value == SettingView.setting) {
                widget.showSettings.value = SettingView.none;
              } else {
                widget.showCname.value = false;
                widget.showSettings.value = SettingView.setting;
              }
            },
            text: '设置',
          ),
          bottomButton(
            onTap: () {
              // 调用 [WillPopScope] 注册的回调
              Navigator.maybePop(context);
            },
            text: '返回',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  bottomButton(
                    onTap: () {
                      final _axis = widget.controller.axis == Axis.horizontal ? Axis.vertical : Axis.horizontal;
                      // widget.controller.axis = _axis;
                      bloc.add(
                        PainterSetPreferencesEvent(
                          config: bloc.config.copyWith(axis: _axis),
                        ),
                      );
                    },
                    child: BlocBuilder<PainterBloc, PainterState>(
                      builder: (context, state) {
                        return Text(
                          '${bloc.config.axis == Axis.horizontal ? '上下滚动' : '左右滑动'}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                        );
                      },
                    ),
                  ),
                  bottomButton(
                    onTap: () {
                      final portrait = !bloc.config.portrait!;
                      uiOverlay();
                      bloc.add(
                        PainterSetPreferencesEvent(
                          config: bloc.config.copyWith(portrait: portrait),
                        ),
                      );
                      widget.show.value = false;
                      widget.end.value = true;
                      widget.showSettings.value = SettingView.none;
                    },
                    child: BlocBuilder<PainterBloc, PainterState>(
                      builder: (context, state) {
                        return Text(
                          '切换${bloc.config.portrait! ? '横屏' : '竖屏'}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                        );
                      },
                    ),
                  ),
                  bottomButton(
                    text: '详情页',
                    onTap: () async {
                      widget.showCname.value = false;

                      /// 由于只有一个[PainterBloc]实例，保存状态
                      final route = MaterialPageRoute(builder: (_) => BookInfoPage());

                      context.read<BookInfoBloc>().add(BookInfoEventSentWithId(bloc.bookid!));
                      bloc
                        ..undelayedDump()
                        ..out();
                      context.read<BookCacheBloc>().load();
                      final cache = context.read<BookCacheBloc>();
                      Navigator.of(context).push(route).then((value) {
                        var cid = bloc.tData.cid!;
                        var page = bloc.currentPage;
                        var bookid = bloc.bookid!;

                        // 重复进入相同书籍，并阅读会改变状态
                        for (final bookCache in cache.state.sortChildren) {
                          if (bookCache.id == bookid) {
                            cid = bookCache.chapterId!;
                            page = bookCache.page!;
                            break;
                          }
                        }
                        context.read<PainterBloc>()
                          ..inbook()
                          ..newBookOrCid(bookid, cid, page);
                        Future.delayed(route.transitionDuration * timeDilation, bloc.completerCanLoad);
                      });
                    },
                  ),
                  // bottomButton(
                  //     text: '性能图层',
                  //     onTap: () {
                  //       final opt = context.read<OptionsBloc>();
                  //       opt.add(
                  //         OptionsEvent(
                  //           ConfigOptions(
                  //             showPerformmanceOverlay: opt.state.options.showPerformmanceOverlay != null
                  //                 ? !opt.state.options.showPerformmanceOverlay!
                  //                 : true,
                  //           ),
                  //         ),
                  //       );
                  //     }),
                  AnimatedBuilder(
                      animation: rate60,
                      builder: (conext, child) {
                        return bottomButton(
                            text: '刷新率',
                            onTap: () {
                              rate60.value = !rate60.value;
                              bloc.repository.setRate(90);
                            });
                      }),

                  bottomButton(text: '阴影', onTap: () => bloc.add(const PainterShowShadowEvent())),
                  // bottomButton(text: '重新下载', onTap: () => bloc.add(PainterReloadEvent())),
                  // bottomButton(text: '取消', onTap: () => bloc.completerResolve(Status.ignore)),
                  bottomButton(text: '删除缓存', onTap: () => bloc.deleteCache(bloc.bookid!)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 属性设置页面
class BookSettingsView extends StatefulWidget {
  const BookSettingsView({Key? key, required this.showSettings}) : super(key: key);
  final ValueNotifier<SettingView> showSettings;
  @override
  _BookSettingsViewState createState() => _BookSettingsViewState();
}

class _BookSettingsViewState extends State<BookSettingsView> {
  // 亮度
  ValueNotifier<double> bgBrightness = ValueNotifier(1.0);
  ValueNotifier<double> ftBrightness = ValueNotifier(1.0);
  ValueNotifier<double> fontvalue = ValueNotifier(10.0);
  ValueNotifier<double> fontHvalue = ValueNotifier(1.0);
  ValueNotifier<bool> bgcolor = ValueNotifier(false);
  late ValueNotifier<HSVColor> bgColor;
  late ValueNotifier<HSVColor> ftColor;
  @override
  void dispose() {
    super.dispose();
  }

  Widget background({required Widget child}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            widget.showSettings.value = SettingView.none;
          },
          child: Container(
            color: Colors.black.withAlpha(100),
          ),
        ),
        Positioned(
          top: 12 + ui.window.padding.top / ui.window.devicePixelRatio,
          left: 24.0,
          right: 24.0,
          bottom: 10.0,
          child: Material(
            borderRadius: BorderRadius.circular(6.0),
            color: Color.fromRGBO(232, 232, 232, 1),
            child: child,
          ),
        ),
      ],
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
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Padding(
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
                                        return Text('字体颜色', style: TextStyle(color: ftColor.value.toColor()));
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
                                  radius: 150,
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
                                  radius: 150,
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
                                          // activeColor: Colors.cyan,
                                          // inactiveColor: Colors.cyan.shade800,
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
                            ),
                            Row(
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                radius: 40,
                onTap: () {
                  final bloc = context.read<PainterBloc>();
                  bloc.add(PainterSetPreferencesEvent(
                      config: bloc.config.copyWith(
                    bgcolor: bgColor.value.toColor(),
                    fontSize: fontvalue.value.floorToDouble(),
                    lineBwHeight: fontHvalue.value,
                    fontColor: ftColor.value.toColor(),
                  )));
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
              child: IndexsWidget(
                onTap: (context, id, cid) {
                  context.read<BookIndexBloc>().add(BookIndexShowEvent(id: id, cid: cid));
                  context.read<PainterBloc>().newBookOrCid(id, cid, 1);
                  widget.showSettings.value = SettingView.none;
                },
              ),
              // child: Container(),
            );
          case SettingView.setting:
            final bloc = context.read<PainterBloc>();
            final color = bloc.config.bgcolor!;
            final fcolor = bloc.config.fontColor!;
            fontvalue.value = bloc.config.fontSize!;
            fontHvalue.value = bloc.config.lineBwHeight!;
            final hsv = HSVColor.fromColor(color);
            final hsvf = HSVColor.fromColor(fcolor);
            bgColor = ValueNotifier(hsv);
            ftColor = ValueNotifier(hsvf);
            bgBrightness.value = hsv.value;
            ftBrightness.value = hsvf.value;
            return settings();
          default:
            return Container();
        }
      },
    );
    return child;
  }
}
