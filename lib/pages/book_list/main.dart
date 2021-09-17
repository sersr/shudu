import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../provider/provider.dart';
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
    var v = 0;
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
                                StatefulBuilder(builder: (context, setstate) {
                                  return _builder(
                                    'count: !done: $v',
                                    () {
                                      setstate(() {
                                        v = imageRefCache?.printDone() ?? 0;
                                      });
                                    },
                                  );
                                }),
                                SelectableText('aa')
                              ],
                            ),
                          ],
                        ),
                      )));
            }));
          }),
          if (kDebugMode) const SizedBox(height: 5),
          if (kDebugMode)
            _builder('content clear(在调试控制台中观察是否正确释放Picture)', () {
              // ignore: invalid_use_of_visible_for_testing_member
              context.read<ContentNotifier>().clear();
            }),
        ],
      ),
    );
  }
}
