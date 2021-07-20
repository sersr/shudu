import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../provider/text_styles.dart';
import 'list_shudan.dart';
import 'top_view.dart';

class ListBangdanPage extends StatefulWidget {
  @override
  _ListBangdanPageState createState() => _ListBangdanPageState();
}

class _ListBangdanPageState extends State<ListBangdanPage> {
  final colorv = ValueNotifier(HSVColor.fromColor(Colors.black));
  final change = ValueNotifier(false);

  late TextStyleConfig ts;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ts = context.read<TextStyleConfig>();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
          body: BarLayout(
        title: Text('榜单'),
        bottom: TabBar(
          labelColor: TextStyleConfig.blackColor7,
          unselectedLabelColor: TextStyleConfig.blackColor2,
          labelStyle: TextStyle(fontSize: 15),
          tabs: const <Widget>[Text('周榜'), Text('月榜'), Text('总榜')],
        ),
        body: TabBarView(
          children: List.generate(3, (index) => Top(index: index)),
        ),
      )),
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
    return Row(
      children: [
        Container(
            width: 60,
            child: ListView.builder(
              // shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                return Material(
                  color: _currentIndex == index
                      ? const Color.fromARGB(255, 210, 210, 210)
                      : null,
                  child: InkWell(
                    onTap: () {
                      // if (_currentIndex != index)
                      setState(() => _currentIndex = index);
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
          child: TopListView(
              ctg: _urlKeys[_currentIndex], date: _urlDates[widget.index]),
        ))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
