import 'dart:async';

import 'package:flutter/material.dart';
import 'package:useful_tools/useful_tools.dart';

import 'book_history.dart';
import 'booklist.dart';
import 'cache_manager.dart';
import 'category.dart';
import 'chat_room.dart';
import 'top.dart';

class ListMainPage extends StatelessWidget {
  const ListMainPage({Key? key}) : super(key: key);

  Widget _builder(String text, VoidCallback onTap) {
    return btn1(
      radius: 10.0,
      bgColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(child: Text(text)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _builder('书单', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return BooklistPage();
                  }));
                }),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _builder('分类', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: ListCatetoryPage());
                  }));
                }),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _builder('榜单', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: TopPage());
                  }));
                }),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _builder('IM', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: ChatRoom());
                  }));
                }),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(children: [
            Expanded(
              child: _builder('缓存管理', () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return RepaintBoundary(child: CacheManager());
                }));
              }),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _builder('浏览历史', () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return RepaintBoundary(child: BookHistory());
                }));
              }),
            ),
          ]),
          const SizedBox(height: 5),
          _builder('清除', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return RepaintBoundary(
                  child: Scaffold(
                      appBar: AppBar(
                        title: Text('清除'),
                      ),
                      body: Container(
                        color: Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _builder(
                                  '清除',
                                  () {
                                    imageCache?.clear();
                                    imageRefCache?.clear();
                                    textCache?.clear();
                                  },
                                ),
                                _builder(
                                  'count: !done',
                                  () {
                                    imageRefCache?.printDone();
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                      color: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      child: Text('scheduleMicrotask')),
                                  onTap: () {
                                    Timer(const Duration(milliseconds: 500),
                                        () {
                                      Log.e('scheduleMicrotask....Timer',
                                          onlyDebug: false);
                                    });
                                    // Future.delayed(
                                    //     const Duration(milliseconds: 500), () {
                                    //   Log.w('scheduleMicrotask...',
                                    //       onlyDebug: false);
                                    //   scheduleMicrotask(() {
                                    //     Log.w('scheduleMicrotask 微任务。。。',
                                    //         onlyDebug: false);
                                    //   });
                                    // });
                                  },
                                ),
                              ],
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                        color: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        child: Text('scheduleMicrotask no')),
                                    onTap: () {
                                      Log.e('scheduleMicrotask....Timer',
                                          onlyDebug: false);

                                      // Future.delayed(
                                      //     const Duration(milliseconds: 500), () {
                                      //   Log.w('scheduleMicrotask...',
                                      //       onlyDebug: false);
                                      //   scheduleMicrotask(() {
                                      //     Log.w('scheduleMicrotask 微任务。。。',
                                      //         onlyDebug: false);
                                      //   });
                                      // });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                        color: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        child: Text('tet')),
                                    onTap: () {
                                      tet();
                                    },
                                  ),
                                ]),
                          ],
                        ),
                      )));
            }));
          }),
        ],
      ),
    );
  }
}

Future<void> tet() async {
  Foo? result;
  for (var i = 0; i < 100; i++) {
    // result = null;
    result = await calc(result);
    // result.foo = null;
  }
  print('done');
}

Future<Foo> calc(Foo? oldResult) async {
  // final _old = oldResult;
  // oldResult?.foo?.call();
  oldResult;
  var newResult = calcInternal(null);
  final foo = () {
    print('hello world');
  };
  // print(foo.hashCode);
  newResult.foo = foo;
  return newResult;
}

Foo calcInternal(Foo? oldResult) {
  return Foo(List.filled(100000, 0));
}

class Foo {
  void Function()? foo;
  final List<int> data;
  Foo(this.data);
}
