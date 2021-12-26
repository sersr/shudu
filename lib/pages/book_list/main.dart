import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:useful_tools/useful_tools.dart';

import '../setting/setting.dart';
import 'book_history.dart';
import 'booklist.dart';
import 'cache_manager.dart';
import 'category.dart';
import 'top.dart';

class ListMainPage extends StatelessWidget {
  const ListMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final light = !context.isDarkMode;
    Widget _builder(String text, VoidCallback onTap) {
      return btn1(
        elevation: 0.05,
        radius: 10.0,
        bgColor: light ? null : Color.fromRGBO(25, 25, 25, 1),
        splashColor: light ? null : Color.fromRGBO(60, 60, 60, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
            child: Text(
          text,
          style: TextStyle(
              color: light ? Colors.grey.shade700 : Colors.grey.shade400),
        )),
        onTap: onTap,
      );
    }

    var count = 0;
    return Container(
      color: light ? Color.fromARGB(255, 231, 231, 231) : Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              row(
                left: _builder('书单', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return BooklistPage();
                  }));
                }),
                right: _builder('分类', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: ListCatetoryPage());
                  }));
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('缓存管理', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: CacheManager());
                  }));
                }),
                right: _builder('浏览历史', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: BookHistory());
                  }));
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('榜单', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return RepaintBoundary(child: TopPage());
                  }));
                }),
                right: _builder('设置', () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return Setting();
                  }));
                }),
              ),
              const SizedBox(height: 5),
              row(
                left: _builder('nav snackbar', () {
                  // setOrientation(false);
                  // Timer(const Duration(seconds: 5), () {
                  //   ScaffoldMessenger.of(context)
                  //       .showSnackBar(SnackBar(content: Text('.hello')));
                  // });

                  Nav.snackBar(
                    Container(
                      // color: Color.fromARGB(255, 61, 61, 61),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      height: 50,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('hello snackbar')),
                    ),
                  );
                  count++;

                  final value = count.isOdd ? 'blue' : 'red';
                  Nav.toast(
                    Center(child: Text('toast: $value')),
                    radius: const BorderRadius.all(Radius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12.0),
                  );
                }),
                right: _builder('nav banner', () {
                  Nav.banner(
                    Container(
                      // color: Color.fromARGB(255, 61, 61, 61),
                      padding: const EdgeInsets.all(8),
                      height: 76,
                      child: Text('hello banner'),
                    ),
                  );
                }),
              ),
              if (kDebugMode) const SizedBox(height: 5),
              if (kDebugMode)
                _builder('clear', () {
                  CacheBinding.instance?.imageRefCache?.clear();
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget row({Widget? left, Widget? right}) {
    return Row(
      children: [if (left != null) Expanded(child: left), ...ig(right)],
    );
  }

  Iterable<Widget> ig(Widget? child) sync* {
    if (child != null) {
      yield const SizedBox(width: 5);
      yield Expanded(child: child);
    }
  }
}
