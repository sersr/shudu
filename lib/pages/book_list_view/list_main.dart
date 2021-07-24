import 'package:flutter/material.dart';

import '../../utils/binding/widget_binding.dart';
import '../../utils/utils.dart';
import 'book_history.dart';
import 'cacheManager.dart';
import 'chat_room.dart';
import 'list_bandan.dart';
import 'list_category.dart';
import 'list_shudan.dart';

class ListMainPage extends StatelessWidget {
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
                    return ListShudanPage();
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
                    return RepaintBoundary(child: ListBangdanPage());
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
                      body: _builder(
                        '清除',
                        () {
                          imageCache?.clear();
                          imageCacheLoop?.clear();
                          textCache?.clear();
                        },
                      )));
            }));
          }),
        ],
      ),
    );
  }
}
