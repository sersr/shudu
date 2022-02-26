import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../event/export.dart';
import '../../provider/text_styles.dart';
import 'booklist.dart';
import 'top_item.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  late TextStyleConfig ts;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ts = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        body: RepaintBoundary(
          child: BarLayout(
            title: Text('榜单'),
            bottom: TabBar(
              unselectedLabelColor: !context.isDarkMode
                  ? const Color.fromARGB(255, 204, 204, 204)
                  : const Color.fromARGB(255, 110, 110, 110),
              labelColor: const Color.fromARGB(255, 255, 255, 255),
              indicatorColor: const Color.fromARGB(255, 252, 137, 175),
              labelStyle: TextStyle(fontSize: 15),
              tabs: ['周榜', '月榜', '总榜'].map(map).toList(),
            ),
            body: TabBarView(
              children: List.generate(3, (index) => Top(index: index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget map(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(text),
    );
  }
}

class Top extends StatefulWidget {
  const Top({Key? key, required this.index}) : super(key: key);
  final int index;
  @override
  _TopState createState() => _TopState();
}

class _TopState extends State<Top> with AutomaticKeepAliveClientMixin {
  final _titles = <String>['最热榜', '完结榜', '推荐榜', '新书榜', '评分榜', '收藏榜'];
  final _urlKeys = <String>['hot', 'over', 'commend', 'new', 'vote', 'collect'];
  final _urlDates = <String>['week', 'month', 'total'];
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final key = _urlKeys[_currentIndex];
    final date = _urlDates[widget.index];

    return Row(
      children: [
        SizedBox(
            width: 60,
            child: ListView.builder(
              // shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                return Material(
                  color: _currentIndex == index
                      ? !context.isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600
                      : null,
                  child: InkWell(
                    splashFactory: InkRipple.splashFactory,
                    onTap: () {
                      // if (_currentIndex != index)
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 4.0),
                      child: Center(child: Text(_titles[index])),
                    ),
                  ),
                );
              },
              itemCount: _titles.length,
            )),
        Expanded(
            child: RepaintBoundary(
          child: ChangeNotifierProvider(
            key: ValueKey(key),
            create: (context) {
              return TopNotifier<String>(
                  context.read<Repository>().getTopLists, key, date);
            },
            child: TopCtgListView<String>(index: widget.index),
          ),
        ))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
