import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';

import '../../bloc/book_index_bloc.dart';
import '../../bloc/book_info_bloc.dart';
import '../../bloc/book_repository.dart';
import '../../bloc/painter_bloc.dart';
import '../../utils/utils.dart';
import '../book_info_view/book_info_page.dart';
import '../embed/indexs.dart';
import 'color_picker.dart';
import 'context_view.dart';
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
  final ValueNotifier<double> slide = ValueNotifier(0.0);
  var sldvalue = SliderValue(index: 0, max: 200);

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

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            child: BookSettingsView(
              showSettings: widget.showSettings,
            ),
          ),
        ),
        RepaintBoundary(
          child: BlocBuilder<BookIndexBloc, BookIndexState>(
            builder: (context, state) {
              if (state is BookIndexWidthData) {
                return AnimatedBuilder(
                    animation: widget.showCname,
                    builder: (context, child) {
                      if (widget.showCname.value) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AnimatedBuilder(
                            animation: slide,
                            builder: (context, child) {
                              var v = slide.value.toInt();
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
                                child: Container(
                                  child: Text(
                                    text,
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),
                                    overflow: TextOverflow.fade,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: Colors.grey.shade900.withAlpha(210),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                ),
                                onTap: () {
                                  if (!bloc.loading.value) {
                                    // timer?.cancel();
                                    widget.showCname.value = false;
                                    final bloc = context.read<PainterBloc>();
                                    bloc.add(PainterNewBookIdEvent(state.id, cid, 1));
                                  }
                                },
                              );
                            },
                          ),
                        );
                      } else {
                        return Container();
                      }
                    });
              }
              return Container();
            },
            buildWhen: (_, newState) => newState is BookIndexWidthData,
          ),
        ),
        RepaintBoundary(
          child: Container(
            color: Colors.grey.shade900.withAlpha(218),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                              bloc.add(PainterPreEvent());
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Center(
                                child: Text(
                              '上一章',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                            )),
                          ),
                          bgColor: Colors.grey.shade900,
                          splashColor: Colors.grey.shade700),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                          child: BlocListener<BookIndexBloc, BookIndexState>(
                              listener: (context, state) {
                                var index = 0;
                                var max = 200;
                                if (state is BookIndexWidthData) {
                                  index = state.index;

                                  for (var i = 0; i < state.bookIndexs.length; i++) {
                                    if (i < state.volIndex) {
                                      index += state.bookIndexs[i].length - 1;
                                    } else {
                                      break;
                                    }
                                  }
                                  max = 0;
                                  state.bookIndexs.forEach((element) {
                                    max += element.length - 1;
                                  });
                                  max--;
                                  max = math.max(index, max);
                                }
                                slide.value = index.toDouble();
                                sldvalue = SliderValue(index: index, max: max);
                              },
                              child: AnimatedBuilder(
                                animation: slide,
                                builder: (context, child) {
                                  return Slider(
                                    value: slide.value,
                                    // divisions: sldvalue.max,
                                    onChanged: (double value) {
                                      slide.value = value;
                                    },
                                    onChangeEnd: (value) {
                                      timer?.cancel();
                                      timer = Timer(Duration(milliseconds: 1500), () {
                                        widget.showCname.value = false;
                                        slide.value = sldvalue.index.toDouble();
                                      });
                                    },
                                    onChangeStart: (value) {
                                      timer?.cancel();
                                      widget.showCname.value = true;
                                      widget.showSettings.value = SettingView.none;
                                    },
                                    min: 0.0,
                                    max: sldvalue.max.toDouble(),
                                  );
                                },
                              )
                              // buildWhen: (oldstate, state) => state is BookIndexWidthData
                              )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: btn1(
                          radius: 40,
                          onTap: () {
                            if (!bloc.loading.value) {
                              widget.showSettings.value = SettingView.none;
                              final bloc = context.read<PainterBloc>();
                              bloc.add(PainterNextEvent());
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Center(
                              child: Text(
                                '下一章',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          bgColor: Colors.grey.shade900,
                          // radius: 6.0,
                          splashColor: Colors.grey.shade700),
                    ),
                  ],
                ),
                BottomEnd(
                  showSettings: widget.showSettings,
                  showCname: widget.showCname,
                  willPop: widget.willPop,
                  controller: widget.controller,
                ),
              ],
            ),
          ),
        ),
      ],
    );
    // 初始不显示
    var end = ValueNotifier<bool>(true);
    return AnimatedBuilder(
      animation: widget.showPannel,
      builder: (context, child) {
        if (widget.showPannel.value) {
          end.value = false;
          indexBloc.add(BookIndexShowEvent(id: bloc.bookid, cid: bloc.tData.cid));
        }
        return AnimatedOpacity(
          opacity: widget.showPannel.value ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedBuilder(
              animation: end,
              builder: (context, _) {
                return IgnorePointer(ignoring: end.value, child: child!);
              }),
          onEnd: () {
            end.value = !widget.showPannel.value;
            if (widget.showPannel.value) {
              SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            } else {
              SystemChrome.setEnabledSystemUIOverlays([]);
            }
          },
        );
      },
      child: RepaintBoundary(child: child),
    );
  }
}

class BottomEnd extends StatefulWidget {
  const BottomEnd({
    Key? key,
    required this.showSettings,
    required this.showCname,
    required this.willPop,
    required this.controller,
  }) : super(key: key);

  final ValueNotifier<SettingView> showSettings;
  final ValueNotifier<bool> showCname;
  final Future<bool> Function() willPop;
  final NopPageViewController controller;

  @override
  _BottomEndState createState() => _BottomEndState();
}

class _BottomEndState extends State<BottomEnd> {
  late PainterBloc bloc;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
  }

  Widget bottomButton({Widget? child, String? text, required VoidCallback onTap}) {
    assert(child != null || text != null);
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: btn1(
          onTap: onTap,
          child: child ??
              Text(
                text!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
              ),
          bgColor: Colors.grey.shade900,
          radius: 6.0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          splashColor: Colors.grey.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 6.0,
          bottom: 12.0 +
              (ui.window.padding.bottom / ui.window.devicePixelRatio +
                  ui.window.systemGestureInsets.bottom / ui.window.devicePixelRatio),
          left: 10.0,
          right: 10.0),
      child: Row(
        children: [
          btn1(
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
              child: Text(
                '目录',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
              ),
              bgColor: Colors.grey.shade900,
              radius: 6.0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              splashColor: Colors.grey.shade700),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: btn1(
                onTap: () {
                  if (widget.showSettings.value == SettingView.setting) {
                    widget.showSettings.value = SettingView.none;
                  } else {
                    widget.showCname.value = false;
                    widget.showSettings.value = SettingView.setting;
                  }
                },
                child: Text(
                  '设置',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                ),
                bgColor: Colors.grey.shade900,
                radius: 6.0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                splashColor: Colors.grey.shade700),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: btn1(
                onTap: () async {
                  widget.showCname.value = false;
                  if (widget.showSettings.value != SettingView.none) {
                    widget.showSettings.value = SettingView.none;
                    return;
                  }
                  await widget.willPop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  '返回',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                ),
                bgColor: Colors.grey.shade900,
                radius: 6.0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                splashColor: Colors.grey.shade700),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  bottomButton(
                    child: RepaintBoundary(
                      child: BlocBuilder<PainterBloc, PainterState>(
                        builder: (context, state) {
                          return Text(
                            '${bloc.config.axis == Axis.horizontal ? '上下' : '左右'}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                          );
                        },
                      ),
                    ),
                    onTap: () {
                      bloc.add(
                        PainterSetPreferencesEvent(
                          config: bloc.config.copyWith(
                              axis: widget.controller.axis == Axis.horizontal ? Axis.vertical : Axis.horizontal),
                        ),
                      );
                    },
                  ),
                  bottomButton(
                    text: '详情页',
                    onTap: () async {
                      widget.showCname.value = false;
                      await widget.willPop();

                      /// 无限嵌套？？？
                      /// bookid, cid, page: 返回时确保状态正确；
                      /// 由于[BookInfoPage]也能进入[PainterPage]页面，
                      /// 当发生时，[PainterBloc] 状态改变，
                      /// 传递上一页面的信息，在返回时恢复状态
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            return BlocProvider(
                              create: (context) => BookInfoBloc(context.read<BookRepository>()),
                              child: Builder(
                                builder: (context) {
                                  BlocProvider.of<BookInfoBloc>(context).add(BookInfoEventSentWithId(bloc.bookid!));
                                  return BookInfoPage(bookid: bloc.bookid, cid: bloc.tData.cid, page: bloc.currentPage);
                                },
                              ),
                            );
                          },
                        ),
                      );
                      await Future.delayed(Duration(milliseconds: 300));
                      bloc.completerCanLoad();
                    },
                  ),
                  bottomButton(
                      text: '性能图层',
                      onTap: () {
                        final opt = context.read<OptionsBloc>();
                        opt.add(OptionsEvent(showPerformmanceOverlay: !opt.showPerformmanceOverlay));
                      }),
                  bottomButton(text: '阴影', onTap: () => bloc.add(PainterShowShadowEvent())),
                  bottomButton(text: '重新下载', onTap: () => bloc.add(PainterReloadEvent())),
                  bottomButton(text: '取消', onTap: () => bloc.completerResolve(Status.ignore)),
                  bottomButton(text: '删除缓存', onTap: () => bloc.add(PainterDeleteCachesEvent(bloc.bookid!))),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.grey.shade900, fontSize: 16, fontFamily: 'NotoSansSC', height: 1.0),
              child: child,
            ),
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
                      height: 150,
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
                                  child: RepaintBoundary(
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
                    Container(
                      height: 150,
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: RepaintBoundary(
                                child: SelectColor(
                                  radius: 150,
                                  onChangeUpdate: onChangev,
                                  onChangeDown: onChangev,
                                  onChangeEnd: onChangev,
                                  value: bgBrightness,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: RepaintBoundary(
                                child: SelectColor(
                                  radius: 150,
                                  onChangeUpdate: onChange,
                                  onChangeDown: onChange,
                                  onChangeEnd: onChange,
                                  value: ftBrightness,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                                        activeColor: Colors.cyan,
                                        inactiveColor: Colors.cyan.shade800,
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
                                        activeColor: Colors.cyan,
                                        inactiveColor: Colors.cyan.shade800,
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
                    Container(
                      height: 106,
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9),
                                    color: Colors.blueGrey.shade600,
                                  ),
                                  child: RepaintBoundary(
                                    child: AnimatedBuilder(
                                      animation: fontvalue,
                                      builder: (context, child) {
                                        return Slider(
                                          activeColor: Colors.cyan,
                                          inactiveColor: Colors.cyan.shade600,
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
                              ),
                              RepaintBoundary(
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
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9),
                                      color: Colors.blueGrey.shade600,
                                    ),
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: fontHvalue,
                                        builder: (context, child) {
                                          return Slider(
                                            activeColor: Colors.indigo.shade300,
                                            inactiveColor: Colors.indigo,
                                            value: fontHvalue.value,
                                            onChanged: (double value) {
                                              fontHvalue.value = value;
                                            },
                                            min: 1.0,
                                            max: 3.0,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                RepaintBoundary(
                                  child: AnimatedBuilder(
                                      animation: fontHvalue,
                                      builder: (context, child) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Center(
                                            child: Text(
                                              '行间距: ${fontHvalue.value.toStringAsFixed(2)}',
                                              softWrap: false,
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 120,
            padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
            child: btn1(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              radius: 40,
              onTap: () {
                final bloc = context.read<PainterBloc>();
                bloc.add(PainterSetPreferencesEvent(
                    config: bloc.config.copyWith(
                  bgcolor: bgColor.value.toColor().value,
                  fontSize: fontvalue.value.floorToDouble(),
                  lineBwHeight: fontHvalue.value,
                  fontColor: ftColor.value.toColor().value,
                )));
              },
              child: Center(
                  child: Text(
                '设置',
                style: TextStyle(color: Colors.white),
              )),
              bgColor: Colors.blueGrey.shade800,
              splashColor: Colors.blueAccent.shade100,
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
                  context.read<PainterBloc>().add(PainterNewBookIdEvent(id, cid, 1));
                  widget.showSettings.value = SettingView.none;
                },
              ),
              // child: Container(),
            );
          case SettingView.setting:
            final bloc = context.read<PainterBloc>();
            final color = Color(bloc.config.bgcolor!);
            final fcolor = Color(bloc.config.fontColor!);
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

class SliderValue {
  SliderValue({required this.max, required this.index});
  final int max;
  final int index;
}
