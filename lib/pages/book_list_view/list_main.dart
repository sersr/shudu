import 'package:flutter/material.dart';

import '../../utils/binding/widget_binding.dart';
import '../../utils/utils.dart';
import '../../widgets/text_builder.dart';
import 'book_history.dart';
import 'cacheManager.dart';
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
                        return ListShudanPage();
                      }));
                    }),
              ),
              const SizedBox(width: 5),
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
                        return RepaintBoundary(child: ListBangdanPage());
                      }));
                    }),
              ),
              const SizedBox(width: 5),
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
                        return RepaintBoundary(child: ChatRoom());
                      }));
                    }),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(children: [
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
                      return RepaintBoundary(child: CacheManager());
                    }));
                  }),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: btn1(
                  radius: 10.0,
                  bgColor: Colors.white,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    child: Center(child: Text('浏览历史')),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return RepaintBoundary(child: BookHistory());
                    }));
                  }),
            ),
          ]),
          btn1(
              radius: 10.0,
              bgColor: Colors.white,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Center(child: Text('清除')),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return RepaintBoundary(
                      child: Scaffold(
                    appBar: AppBar(
                      title: Text('清除'),
                    ),
                    body: Center(
                      child: btn1(
                          onTap: () {
                            NopWidgetsFlutterBinding.instance?.clear();
                          },
                          child: Text('清除')),
                    ),
                  ));
                }));
              }),
        ],
      ),
    );
  }
}
