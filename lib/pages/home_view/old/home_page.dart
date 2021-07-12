// import 'dart:async';
// import 'dart:ui' as ui;

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// import '../../database/nop_database.dart';
// import '../../provider/book_cache_notifier.dart';
// import '../../provider/options_notifier.dart';
// import '../../provider/painter_notifier.dart';
// import '../../provider/provider.dart';
// import '../../provider/search_notifier.dart';
// import '../../utils/utils.dart';
// import '../book_content_view/book_content_page.dart';
// import '../book_content_view/widgets/pan_slide.dart';
// import '../book_content_view/widgets/pannel.dart';
// import '../book_info_view/book_info_page.dart';
// import '../book_list_view/list_main.dart';
// import '../embed/list_builder.dart';
// import 'book_item.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends PanSlideState<MyHomePage>
//     with WidgetsBindingObserver {
//   int currentIndex = 0;
//   late ContentNotifier painterBloc;
//   late OptionsNotifier opts;
//   late BookCacheNotifier cache;
//   Future? _future;
//   final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     painterBloc = context.read<ContentNotifier>();
//     opts = context.read<OptionsNotifier>();
//     final search = context.read<SearchNotifier>();
//     cache = context.read<BookCacheNotifier>();
//     if (_future == null) {
//       cache.repository
//         // ..addInitCallback()
//         ..addInitCallback(painterBloc.initConfigs)
//         ..addInitCallback(search.init);

//       _future ??= cache.repository.initState.then((_) {
//         opts.init();
//         return Future.wait([
//           painterBloc.metricsChange(),
//           cache.load(),
//         ]);
//       });
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       painterBloc.autoRun.stopSave();
//     } else if (state == AppLifecycleState.resumed) {
//       painterBloc.autoRun.stopAutoRun();
//       // scheduleMicrotask(opts.changeRate);
//     }
//   }

//   Timer? timer;
//   @override
//   void didChangeMetrics() {
//     // 桌面窗口大小改变
//     final w = ui.window;
//     assert(Log.i(
//         'data: systemGestureInsets${w.systemGestureInsets}\ndata: viewPadding ${w.viewPadding} \ndata: padding'
//         ' ${w.padding} \ndata: viewInsets ${w.viewInsets} \ndata: physicalGeometry ${w.physicalGeometry}'));
//     timer?.cancel();
//     timer = Timer(Duration(milliseconds: 100), () {
//       if (mounted) {
//         painterBloc.metricsChange();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance!.removeObserver(this);
//     super.dispose();
//   }

//   Timer? _exitTimer;
//   @override
//   Future<bool> didPopRoute() async {
//     final inTime = _exitTimer?.isActive == true;
//     if (inTime) {
//       // 退出 app
//       return false;
//     }
//     final entry = OverlayEntry(builder: (context) {
//       return Positioned(
//         bottom: 70,
//         left: 0.0,
//         right: 0.0,
//         child: Center(
//           child: Material(
//             borderRadius: BorderRadius.circular(6.0),
//             color: Colors.grey.shade900.withAlpha(210),
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//               child: Text(
//                 '再按一次退出',
//                 style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//     Overlay.of(context)!.insert(entry);
//     _exitTimer = Timer(const Duration(seconds: 2), entry.remove);
//     return true;
//   }

//   late var indexedStack = <Widget>[
//     RepaintBoundary(child: buildBlocBuilder()),
//     RepaintBoundary(child: ListMainPage())
//   ];

//   Widget _build(BuildContext context) {
//     final child = Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text('shudu'),
//         elevation: 1 / ui.window.devicePixelRatio,
//         centerTitle: true,
//         actions: [
//           Column(
//             children: [
//               Expanded(
//                 child: LayoutBuilder(
//                   builder: (context, contraints) {
//                     final height = contraints.maxHeight;
//                     return InkWell(
//                       borderRadius: BorderRadius.circular(height / 2),
//                       onTap: () => showSearch(
//                           context: context, delegate: MySearchPage()),
//                       child: Container(
//                         height: height,
//                         width: height,
//                         child: Icon(Icons.search),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ],
//         leading: Column(
//           children: [
//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, contraints) {
//                   final height = contraints.maxHeight;
//                   return InkWell(
//                     borderRadius: BorderRadius.circular(height / 2),
//                     onTap: () {
//                       getController().trigger();
//                     },
//                     child: Container(
//                       height: height,
//                       width: height,
//                       child: Icon(Icons.menu),
//                     ),
//                   );
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//       body: RepaintBoundary(
//         child: IndexedStack(
//           index: currentIndex,
//           children: indexedStack,
//           // children: <Widget>[
//           //   RepaintBoundary(child: buildBlocBuilder()),
//           //   RepaintBoundary(child: ListMainPage())
//           // ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         iconSize: 18.0,
//         selectedFontSize: 11.0,
//         unselectedFontSize: 11.0,
//         items: [
//           BottomNavigationBarItem(label: '主页', icon: Icon(Icons.home_rounded)),
//           BottomNavigationBarItem(
//               label: '书城', icon: Icon(Icons.local_grocery_store_rounded))
//         ],
//         onTap: (index) {
//           if (index == currentIndex) {
//             if (currentIndex == 0) _refreshKey.currentState!.show(atTop: true);

//             return;
//           }
//           setState(() => currentIndex = index);
//         },
//         currentIndex: currentIndex,
//       ),
//     );

//     /// 安全地初始化
//     return FutureBuilder<void>(
//       future: _future,
//       builder: (context, snap) {
//         return AbsorbPointer(
//             absorbing: snap.connectionState != ConnectionState.done,
//             child: child);
//       },
//     );
//   }

//   PanSlideController? controller;
//   final op = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);

//   PanSlideController getController() {
//     if (controller != null && !controller!.close) return controller!;
//     controller = PanSlideController.showPan(this,
//         //  onhide: () {
//         //   controller?.dispose();
//         //   removeHide();
//         // },
//         // onshow: onshowEnd,
//         // onanimating: onanimating,
//         builder: (contxt, _controller) {
//       return RepaintBoundary(
//         child: PannelSlide(
//           useDefault: false,
//           modal: true,
//           controller: _controller,
//           botChild: (context, animation) {
//             final curve = CurveTween(curve: Curves.ease).animate(animation);
//             final position = curve.drive(op);
//             return RepaintBoundary(
//               child:
//                   SlideTransition(position: position, child: showbts(context)),
//             );
//           },
//         ),
//       );
//     });
//     return controller!;
//   }

//   Widget showbts(BuildContext context) {
//     // showModalBottomSheet(
//     //   context: context,
//     //   builder: (context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadiusDirectional.vertical(top: Radius.circular(6.0)),
//       ),
//       padding: const EdgeInsets.only(left: 12.0, right: 4.0, bottom: 4.0),
//       child: RepaintBoundary(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.only(top: 8.0),
//                 child: Text('选择平台样式'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   btn1(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       child: Text(
//                         'Android',
//                         style: TextStyle(color: Colors.grey.shade100),
//                       ),
//                     ),
//                     radius: 5,
//                     bgColor: Colors.cyan.shade600,
//                     splashColor: Colors.cyan.shade200,
//                     onTap: () {
//                       opts.options =
//                           ConfigOptions(platform: TargetPlatform.android);
//                       Future.delayed(Duration(milliseconds: 200), () {
//                         Navigator.of(context).maybePop();
//                       });
//                     },
//                   ),
//                   btn1(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       child: Text(
//                         'IOS',
//                         style: TextStyle(color: Colors.grey.shade100),
//                       ),
//                     ),
//                     radius: 5,
//                     bgColor: Colors.cyan.shade600,
//                     splashColor: Colors.cyan.shade200,
//                     onTap: () {
//                       opts.options =
//                           ConfigOptions(platform: TargetPlatform.iOS);
//                       Future.delayed(Duration(milliseconds: 200), () {
//                         Navigator.of(context).maybePop();
//                       });
//                     },
//                   )
//                 ],
//               ),
//             ),
//             // Divider(height: 1),
//             // Center(
//             //   child: Padding(
//             //     padding: const EdgeInsets.only(top: 8.0),
//             //     child: Text('页面过度动画'),
//             //   ),
//             // ),
//             // Padding(
//             //   padding: const EdgeInsets.symmetric(vertical: 4),
//             //   child: Wrap(
//             //     spacing: 12.0,
//             //     runSpacing: 8.0,
//             //     children: [
//             //       btn1(
//             //         child: Container(
//             //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             //           child: Text(
//             //             'FadeUpwards',
//             //             style: TextStyle(color: Colors.grey.shade100),
//             //           ),
//             //         ),
//             //         radius: 5,
//             //         bgColor: Colors.lightBlue.shade700,
//             //         splashColor: Colors.lightBlue.shade400,
//             //         onTap: () {
//             //           opts.add(OptionsEvent(ConfigOptions(pageBuilder: PageBuilder.fadeUpwards)));
//             //           Future.delayed(Duration(milliseconds: 200), () {
//             //             Navigator.of(context).pop();
//             //           });
//             //         },
//             //       ),
//             //       btn1(
//             //         child: Container(
//             //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             //           child: Text(
//             //             'OpenUpwards',
//             //             style: TextStyle(color: Colors.grey.shade100),
//             //           ),
//             //         ),
//             //         radius: 5,
//             //         bgColor: Colors.lightBlue.shade700,
//             //         splashColor: Colors.lightBlue.shade400,
//             //         onTap: () {
//             //           opts.add(OptionsEvent(ConfigOptions(pageBuilder: PageBuilder.openUpwards)));
//             //           Future.delayed(Duration(milliseconds: 200), () {
//             //             Navigator.of(context).pop();
//             //           });
//             //         },
//             //       ),
//             //       btn1(
//             //         child: Container(
//             //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             //           child: Text(
//             //             'Cupertino',
//             //             style: TextStyle(color: Colors.grey.shade100),
//             //           ),
//             //         ),
//             //         radius: 5,
//             //         bgColor: Colors.lightBlue.shade700,
//             //         splashColor: Colors.lightBlue.shade400,
//             //         onTap: () {
//             //           opts.add(OptionsEvent(ConfigOptions(pageBuilder: PageBuilder.cupertino)));
//             //           Future.delayed(Duration(milliseconds: 200), () {
//             //             Navigator.of(context).pop();
//             //           });
//             //         },
//             //       ),
//             //       btn1(
//             //         child: Container(
//             //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             //           child: Text(
//             //             'FadeThrough',
//             //             style: TextStyle(color: Colors.grey.shade100),
//             //           ),
//             //         ),
//             //         radius: 5,
//             //         bgColor: Colors.lightBlue.shade700,
//             //         splashColor: Colors.lightBlue.shade400,
//             //         onTap: () {
//             //           opts.add(OptionsEvent(ConfigOptions(pageBuilder: PageBuilder.fadeThrough)));
//             //           Future.delayed(Duration(milliseconds: 200), () {
//             //             Navigator.of(context).pop();
//             //           });
//             //         },
//             //       ),
//             //       btn1(
//             //         child: Container(
//             //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             //           child: Text(
//             //             'Zoom',
//             //             style: TextStyle(color: Colors.grey.shade100),
//             //           ),
//             //         ),
//             //         radius: 5,
//             //         bgColor: Colors.lightBlue.shade700,
//             //         splashColor: Colors.lightBlue.shade400,
//             //         onTap: () {
//             //           opts.add(OptionsEvent(ConfigOptions(pageBuilder: PageBuilder.zoom)));
//             //           Future.delayed(Duration(milliseconds: 200), () {
//             //             Navigator.of(context).pop();
//             //           });
//             //         },
//             //       )
//             //     ],
//             //   ),
//             // ),
//             Divider(height: 1),
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Text('指针采样'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Consumer<OptionsNotifier>(
//                 builder: (context, opt, _) {
//                   return Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Center(child: Text('采样时间差:')),
//                           IconButton(
//                               icon: Icon(Icons.remove),
//                               onPressed: () {
//                                 if (opt.options.resampleOffset != null) {
//                                   final offset =
//                                       opt.options.resampleOffset! - 1;
//                                   opt.options =
//                                       ConfigOptions(resampleOffset: offset);
//                                 }
//                               }),
//                           Center(child: Text('${opt.options.resampleOffset}')),
//                           IconButton(
//                             icon: Icon(Icons.add),
//                             onPressed: () {
//                               if (opt.options.resampleOffset != null) {
//                                 final offset = opt.options.resampleOffset! + 1;
//                                 opt.options =
//                                     ConfigOptions(resampleOffset: offset);
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                       // },
//                       // ),
//                       Center(child: Text('当前状态:')),
//                       Switch(
//                         value: opt.options.resample ?? true,
//                         onChanged: (v) {
//                           opts.options = ConfigOptions(resample: v);
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 100)
//           ],
//         ),
//       ),
//     );
//     //   },
//     // );
//   }

//   Widget bottomSheet(BuildContext context, BookCache item) {
//     return Container(
//       decoration: BoxDecoration(
//         // color: Colors.grey[200].withAlpha(240),
//         borderRadius:
//             BorderRadiusDirectional.vertical(top: Radius.circular(6.0)),
//       ),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12.0,
//         vertical: 8.0,
//       ),
//       height: 260,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           btn2(
//               icon: Icons.book,
//               text: '书籍详情',
//               onTap: () {
//                 // Navigator.of(context).pop();
//                 Navigator.of(context)
//                     .pushReplacement(MaterialPageRoute(builder: (context) {
//                   return BookInfoPage(id: item.bookId!);
//                 }));
//                 // BookInfoPage.push(context, item.bookId!);
//               }),
//           btn2(
//               icon: Icons.touch_app_sharp,
//               text: item.isTop ?? false ? '取消置顶' : '书籍置顶',
//               onTap: () {
//                 final isTop = item.isTop;
//                 if (isTop != null) cache.updateTop(item.bookId!, !isTop);
//                 // Navigator.of(context).pop();
//               }),
//           btn2(
//               icon: Icons.delete_forever_outlined,
//               text: '删除书籍',
//               onTap: () {
//                 cache.deleteBook(item.bookId!);
//                 // Navigator.of(context).pop();
//               }),
//         ],
//       ),
//     );
//   }

//   Widget buildBlocBuilder() {
//     return RefreshIndicator(
//       key: _refreshKey,
//       displacement: 20.0,
//       // triggerMode: RefreshIndicatorTriggerMode.anywhere,
//       onRefresh: () => cache.load(update: true),
//       child: NotificationListener<OverscrollIndicatorNotification>(
//         onNotification: (OverscrollIndicatorNotification no) {
//           no.disallowGlow();
//           return false;
//         },
//         child: AnimatedBuilder(
//           animation: cache,
//           builder: (context, state) {
//             if (!cache.initialized) return SizedBox();

//             final children = cache.showChildren;

//             if (children.isEmpty) return const Center(child: Text('点击右上角按钮搜索'));

//             return Scrollbar(
//               child: ColoredBox(
//                 color: const Color.fromRGBO(242, 242, 242, 1.0),
//                 child: ListViewBuilder(
//                   padding: EdgeInsets.zero,
//                   itemCount: children.length,
//                   itemBuilder: (context, index) {
//                     final item = children[index];

//                     return ListItemBuilder(
//                       onTap: () {
//                         BookContentPage.push(
//                             context, item.bookId!, item.chapterId!, item.page!);
//                       },
//                       onLongPress: () {
//                         showModalBottomSheet(
//                             context: context,
//                             builder: (context) => bottomSheet(context, item));
//                       },
//                       child: BookItem(
//                         img: item.img,
//                         bookName: item.name,
//                         bookUdateItem: item.lastChapter,
//                         bookUpdateTime: item.updateTime,
//                         isTop: item.isTop ?? false,
//                         isNew: item.isNew ?? false,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget wrapOverlay(BuildContext context, Widget overlay) {
//     return Scaffold(
//       body: Material(
//         child: Stack(children: [
//           Positioned.fill(child: RepaintBoundary(child: _build(context))),
//           Positioned.fill(child: RepaintBoundary(child: overlay)),
//         ]),
//       ),
//     );
//   }
// }

// class MySearchPage extends SearchDelegate<void> {
//   MySearchPage({
//     String? hintText,
//   }) : super(
//           searchFieldLabel: '书名关键字',
//           keyboardType: TextInputType.multiline,
//           textInputAction: TextInputAction.search,
//         );

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     final theme = Theme.of(context);
//     return theme.copyWith(
//       primaryColor: Colors.white,
//       primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
//       primaryColorBrightness: Brightness.light,
//       primaryTextTheme: theme.textTheme,
//     );
//   }

//   @override
//   Widget buildLeading(BuildContext context) => Center(
//       child: Container(
//           // color: Colors.cyan,
//           height: 100,
//           width: 100,
//           child: Icon(
//             Icons.ac_unit,
//             size: 30,
//           )));
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return wrap(context, suggestions(context));
//   }

//   Widget suggestions(BuildContext context) {
//     final bloc = context.read<SearchNotifier>();
//     return StatefulBuilder(
//       builder: (context, setstate) {
//         return Padding(
//           padding: const EdgeInsets.all(6.0),
//           child: Wrap(
//             children: [
//               for (var i in bloc.searchHistory.reversed)
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Material(
//                     borderRadius: BorderRadius.circular(3.0),
//                     color: Color.fromARGB(255, 240, 240, 240),
//                     child: InkWell(
//                       onLongPress: () {
//                         bloc.delete(i);
//                         setstate(() {});
//                       },
//                       onTap: () {
//                         query = i;
//                         showResults(context);
//                       },
//                       borderRadius: BorderRadius.circular(3.0),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 4.0),
//                         child: Text(
//                           i,
//                           style: context
//                               .read<TextStyleConfig>()
//                               .body1
//                               .copyWith(color: Colors.grey.shade700),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget wrap(BuildContext context, Widget child) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         child,
//         Positioned(
//           left: 16.0,
//           bottom: 16.0,
//           child: Material(
//             color: Colors.grey[200],
//             elevation: 4.0,
//             borderRadius: BorderRadius.circular(50.0),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(50.0),
//               splashColor: Colors.grey[400],
//               onTap: () {
//                 close(context, null);
//               },
//               child: Container(
//                 height: 40,
//                 width: 70,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50.0),
//                 ),
//                 child: Center(child: Text('返回')),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     final search = context.read<SearchNotifier>();

//     return wrap(
//         context,
//         AnimatedBuilder(
//           animation: search,
//           builder: (context, _) {
//             final data = search.list;
//             if (data == null) {
//               return loadingIndicator();
//             }
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: ListView(
//                 children: [
//                   suggestions(context),
//                   if (search.searchHistory.isNotEmpty) const Divider(height: 1),
//                   if (data.data != null)
//                     for (var value in data.data!)
//                       GestureDetector(
//                         onTap: () =>
//                             BookInfoPage.push(context, int.parse(value.id!)),
//                         child: Container(
//                           height: 40,
//                           alignment: Alignment.centerLeft,
//                           decoration: BoxDecoration(
//                               border: Border(
//                                   bottom:
//                                       BorderSide(color: Colors.grey.shade300))),
//                           child: Text('${value.name}'),
//                         ),
//                       ),
//                 ],
//               ),
//             );
//           },
//         ));
//   }

//   @override
//   List<Widget> buildActions(BuildContext context) => [
//         InkWell(
//           splashColor: Colors.blue[700],
//           borderRadius: BorderRadius.circular(50.0),
//           onTap: () {
//             showResults(context);
//           },
//           child: Center(
//               child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text('搜索'),
//           )),
//         )
//       ];

//   @override
//   void showResults(BuildContext context) {
//     final search = context.read<SearchNotifier>();
//     search.load(query);
//     super.showResults(context);
//   }
// }
