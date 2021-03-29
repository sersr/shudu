import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class ListBangdanPage extends StatefulWidget {
  @override
  _ListBangdanPageState createState() => _ListBangdanPageState();
}

class _ListBangdanPageState extends State<ListBangdanPage> {
  final colorv = ValueNotifier(HSVColor.fromColor(Colors.black));
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
  var listnotf = <ValueNotifier<bool>>[];
  for (var i = 0; i < 6; i++) {
    listnotf.add(ValueNotifier(i == 0));
  }
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

Widget animationBuilder(String text, List<ValueNotifier<bool>> notifier, int index, int? div) {
  return GestureDetector(
    onTap: () {
      notifier.forEach((element) {
        if (element == notifier[index]) {
          if (!element.value) {
            element.value = true;
          }
        } else {
          element.value = false;
        }
      });
    },
    child: Container(
      color: Colors.white.withAlpha(0),
      child: AnimatedBuilder(
          animation: notifier[index],
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              color: notifier[index].value ? Colors.grey[300] : null,
              child: Text(text),
            );
          }),
    ),
  );
}
