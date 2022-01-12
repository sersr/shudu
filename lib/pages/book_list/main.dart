import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:useful_tools/useful_tools.dart';

import '../demo/view_one_inner.dart';
import '../setting/setting.dart';
import 'book_history.dart';
import 'booklist.dart';
import 'cache_manager.dart';
import 'category.dart';
import 'top.dart';

class ListMainPage extends StatelessWidget {
  ListMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final light = !context.isDarkMode;
    Widget _builder(String text, VoidCallback onTap) {
      return btn1(
        elevation: 0.05,
        radius: 10.0,
        bgColor: light ? null : Color.fromRGBO(25, 25, 25, 1),
        splashColor: light ? null : Color.fromRGBO(60, 60, 60, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
            child: Text(
          text,
          style: TextStyle(
              color: light ? Colors.grey.shade700 : Colors.grey.shade400),
        )),
        onTap: onTap,
      );
    }

    var count = 0;
    var index = 0;
    return Container(
      color: light ? Color.fromARGB(255, 231, 231, 231) : Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              row(
                left: _builder('书单', () {
                  Nav.push(MaterialPageRoute(builder: (context) {
                    return BooklistPage();
                  }));
                }),
                right: _builder('分类', () {
                  Nav.push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: ListCatetoryPage());
                  }));
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('缓存管理', () {
                  Nav.push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: CacheManager());
                  }));
                }),
                right: _builder('浏览历史', () {
                  Nav.push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: BookHistory());
                  }));
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('榜单', () {
                  Nav.push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: TopPage());
                  }));
                }),
                right: _builder('设置', () {
                  Nav.push(MaterialPageRoute(builder: (context) {
                    return Setting();
                  }));
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('nav snackbar', () {
                  // setOrientation(false);
                  // Timer(const Duration(seconds: 5), () {
                  //   ScaffoldMessenger.of(context)
                  //       .showSnackBar(SnackBar(content: Text('.hello')));
                  // });

                  Nav.snackBar(
                    Container(
                      // color: Color.fromARGB(255, 61, 61, 61),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      height: 50,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('hello snackbar')),
                    ),
                  );
                  count++;

                  final value = count.isOdd ? 'blue' : 'red';
                  Nav.toast(
                    Center(child: Text('toast: $value')),
                    radius: const BorderRadius.all(Radius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12.0),
                  );
                }),
                right: _builder('nav banner', () {
                  Nav.banner(
                    Container(
                      // color: Color.fromARGB(255, 61, 61, 61),
                      padding: const EdgeInsets.all(8),
                      height: 76,
                      child: Text('hello banner'),
                    ),
                  );
                  final builder =
                      OverlayPannelBuilder(builder: (context, self) {
                    final offset =
                        Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0));
                    final key = GlobalKey();
                    return OverlaySideGesture(
                        entry: self,
                        left: null,
                        builder: (context) {
                          return Center(
                            child: SizedBox(
                              key: key,
                              height: 100,
                              width: 300,
                              child: Material(
                                  color: Colors.blue, child: Text('hell0')),
                            ),
                          );
                        },
                        transition: (child) {
                          return AnimatedBuilder(
                            animation: self.userGesture,
                            builder: (context, child) {
                              if (self.userGesture.value) {
                                final position =
                                    self.owner.controller.drive(offset);

                                return SlideTransition(
                                    position: position, child: child);
                              }

                              return CurvedAnimationWidget(
                                builder: (context, animation) {
                                  final position = animation.drive(offset);
                                  return SlideTransition(
                                      position: position, child: child);
                                },
                                controller: self.owner.controller,
                              );
                            },
                            child: child,
                          );
                        },
                        sizeKey: key);
                  });
                  final delegate = OverlayMixinDelegate(
                      builder, const Duration(milliseconds: 300));
                  delegate.show().whenComplete(() =>
                      release(const Duration(seconds: 3))
                          .whenComplete(delegate.hide));
                }),
              ),
              if (kDebugMode) const SizedBox(height: 5),
              if (kDebugMode)
                _builder('clear', () {
                  CacheBinding.instance?.imageRefCache?.clear();
                }),
              const SizedBox(height: 5),
              row(
                left: AnimatedBuilder(
                    animation: _eventQueueLength,
                    builder: (context, child) {
                      return _builder(
                        'EventQueue length: ${_eventQueueLength.value}',
                        () => _eventQueueLength.value =
                            EventQueue.checkTempQueueLength(),
                      );
                    }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('nav horizontal', () {
                  final content = Container(
                    // color: Color.fromARGB(255, 61, 61, 61),
                    padding: const EdgeInsets.all(8),
                    child: Text('horizontal side'),
                  );
                  switch (index % 6) {
                    case 0:
                      show(content, align: OverlayAliment.start);
                      break;
                    case 1:
                      show(content);
                      break;
                    case 2:
                      show(content, align: OverlayAliment.end);
                      break;
                    case 3:
                      show(content, align: OverlayAliment.end, rightSide: true);
                      break;
                    case 4:
                      show(content, rightSide: true);
                      break;
                    case 5:
                      show(content,
                          align: OverlayAliment.start, rightSide: true);
                      break;
                    default:
                  }
                  index++;
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('list body', () {
                  Nav.push(
                    MaterialPageRoute(
                      builder: (context) => ViewOne(
                        title: Text('title'),
                        backgroundChild: Container(
                            child: Center(child: Text('background')),
                            color: Colors.cyan),
                        body: ListViewBuilder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: 200,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 50,
                              child: Text('$index'),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
                right: _builder('list body, header', () {
                  Nav.push(
                    MaterialPageRoute(
                      builder: (context) => ViewOne(
                          child: Center(child: Text('hello')),
                          title: Text('title'),
                          backgroundChild: Container(
                              child: Center(child: Text('background')),
                              color: Colors.cyan),
                          body: ListViewBuilder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: 200,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: 50,
                                child: Text('$index'),
                              );
                            },
                          )),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('widget body, header', () {
                  Nav.push(
                    MaterialPageRoute(
                      builder: (context) => ViewOne(
                        child: Center(child: Text('hello')),
                        title: Text('title'),
                        backgroundChild: Container(
                            child: Center(child: Text('background')),
                            color: Colors.cyan),
                        body: Center(
                          child: Container(
                            height: 500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void show(Widget content,
      {bool rightSide = false,
      OverlayAliment align = OverlayAliment.center,
      Duration stay = const Duration(seconds: 3),
      Duration duration = const Duration(milliseconds: 300),
      Radius radius = const Radius.circular(4)}) {
    showOverlay(content,
        animationDuration: duration,
        duration: stay,
        showKey: [align, rightSide],
        radius: BorderRadius.horizontal(
            left: rightSide ? radius : Radius.zero,
            right: !rightSide ? radius : Radius.zero),
        position: rightSide ? Position.right : Position.left,
        builder: (context, child) {
      return SafeArea(
        child: Align(
          alignment: getAlignment(rightSide, align),
          child: child,
        ),
      );
    });
  }

  final _eventQueueLength = ValueNotifier(0);

  Widget row({Widget? left, Widget? right}) {
    if (left == null) {
      left = right;
      right = null;
    }
    final hasChild = right != null;
    return Row(
      children: [
        if (left != null) Expanded(child: left),
        if (hasChild) const SizedBox(width: 5),
        if (hasChild) Expanded(child: right)
      ],
    );
  }
}

enum OverlayAliment {
  start,
  center,
  end,
}
Alignment getAlignment(bool rightSide, OverlayAliment align) {
  late Alignment _alignment;
  if (rightSide) {
    switch (align) {
      case OverlayAliment.center:
        _alignment = Alignment.centerLeft;
        break;
      case OverlayAliment.start:
        _alignment = Alignment.topLeft;
        break;
      case OverlayAliment.end:
        _alignment = Alignment.bottomLeft;
        break;

      default:
    }
  } else {
    switch (align) {
      case OverlayAliment.center:
        _alignment = Alignment.centerRight;
        break;
      case OverlayAliment.start:
        _alignment = Alignment.topRight;
        break;
      case OverlayAliment.end:
        _alignment = Alignment.bottomRight;
        break;

      default:
    }
  }
  return _alignment;
}
