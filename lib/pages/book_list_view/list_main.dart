import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cacheManager.dart';

import '../../event/event.dart';
import '../../utils/utils.dart';
import 'chat_room.dart';
import 'list_bandan.dart';
import 'list_category.dart';
import 'list_shudan.dart';

class ListMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: btn1(
                    radius: 10.0,
                    bgColor: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Center(child: Text('书单')),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return BlocProvider(
                          create: (context) =>
                              ShudanBloc(context.read<Repository>()),
                          child: RepaintBoundary(
                              child: wrapData(ListShudanPage())),
                        );
                      }));
                    }),
              ),
              SizedBox(width: 5),
              Expanded(
                child: btn1(
                    radius: 10.0,
                    bgColor: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      child: Center(
                        child: Text('分类'),
                      ),
                    ),
                    // bgColor: Color.fromRGBO(222, 222, 222, 1),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return RepaintBoundary(
                            child: wrapData(ListCatetoryPage()));
                      }));
                    }),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: btn1(
                    radius: 10.0,
                    bgColor: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      child: Center(child: Text('榜单')),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return RepaintBoundary(
                            child: wrapData(ListBangdanPage()));
                      }));
                    }),
              ),
              SizedBox(width: 5),
              Expanded(
                child: btn1(
                    radius: 10.0,
                    bgColor: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      child: Center(child: Text('IM')),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return RepaintBoundary(child: wrapData(ChatRoom()));
                      }));
                    }),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
              child: btn1(
                  radius: 10.0,
                  bgColor: Colors.white,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    child: Center(child: Text('缓存管理')),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return RepaintBoundary(child: wrapData(CacheManager()));
                    }));
                  }),
            ),
          ]),
        ],
      ),
    );
  }
}

class TranslationView extends StatefulWidget {
  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView>
    with TickerProviderStateMixin {
  late AnimationController animation;
  late AnimationController secondaryAnimation;
  late Animation<Offset> s;
  late Animation<Offset> m;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
        vsync: this, value: 0.0, duration: Duration(milliseconds: 400));
    secondaryAnimation = AnimationController(
        vsync: this, value: 0.0, duration: Duration(milliseconds: 400));
    s = CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.linearToEaseOut,
            reverseCurve: Curves.easeInToLinear)
        .drive(Tween<Offset>(begin: Offset.zero, end: Offset(-1.0 / 3, 0.0)));
    m = CurvedAnimation(
            parent: animation,
            curve: Curves.linearToEaseOut,
            reverseCurve: Curves.easeInToLinear)
        .drive(Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero));
    animation.forward();
    animation.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SlideTransition(
                position: s,
                transformHitTests: false,
                child: SlideTransition(
                  position: m,
                  child: Container(color: Colors.blue, height: 300, width: 400),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (animation.status == AnimationStatus.completed) {
                      animation.reverse();
                      secondaryAnimation.reverse();
                    } else {
                      animation.forward();
                      secondaryAnimation.forward();
                    }
                  },
                  child: Text('click'),
                ),
              ))
        ],
      ),
    );
  }
}
