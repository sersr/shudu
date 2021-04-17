import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class ListBangdanPage extends StatefulWidget {
  @override
  _ListBangdanPageState createState() => _ListBangdanPageState();
}

class _ListBangdanPageState extends State<ListBangdanPage> {
  final colorv = ValueNotifier(HSVColor.fromColor(Colors.black));
  final change = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    var r = math.sqrt(math.pow(30, 2) + math.pow(40, 2)) / 50;
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 56,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(fontSize: 15),
            tabs: [
              Text('周榜'),
              Text('月榜'),
              Text('总榜'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ListView.builder(itemBuilder: (context, index) {
            //   if (index == 5) {
            //     return InkWell(
            //       onTap: () {
            //         change.value = !change.value;
            //       },
            //       child: RepaintBoundary(
            //         child: AnimatedBuilder(
            //             animation: change,
            //             builder: (context, child) {
            //               return Container(
            //                 height: change.value ? 50 : 100,
            //                 color: Colors.grey,
            //                 // child: Text('value :${change.value ? 'slslsl' : 'hello'}'),
            //               );
            //             }),
            //       ),
            //     );
            //   }
            //   return Container(
            //     color: Colors.blue,
            //     height: 50,
            //   );
            // }),
            wrap(
              child: Container(
                color: Colors.lightGreen,
              ),
              div: 1,
            ),
            wrap(
              child: Container(
                color: Colors.amber,
              ),
              div: 2,
            ),
            wrap(
              child: Container(
                color: HSVColor.fromAHSV(1.0, math.atan2(-10, 100) * 180 / math.pi + 180, r, 1).toColor(),
              ),
              div: 3,
            ),
          ],
        ),
      ),
    );
  }
}

Widget wrap({required Widget child, int? div}) {
  var listnotf = ValueNotifier(0);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Column(
        children: [
          animationBuilder('最热榜', listnotf, 0, div),
          animationBuilder('完结榜', listnotf, 1, div),
          animationBuilder('推荐榜', listnotf, 2, div),
          animationBuilder('新书榜', listnotf, 3, div),
          animationBuilder('评分榜', listnotf, 4, div),
          animationBuilder('收藏榜', listnotf, 5, div),
        ],
      ),
      Expanded(
        child: child,
      ),
    ],
  );
}

Widget animationBuilder(String text, ValueNotifier<int> notifier, int index, int? div) {
  return GestureDetector(
    onTap: () {
      notifier.value = index;
    },
    child: RepaintBoundary(
      child: AnimatedBuilder(
          animation: notifier,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              color: notifier.value == index ? Colors.grey[300] : Colors.transparent,
              child: Text(text),
            );
          }),
    ),
  );
}
