import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../provider/export.dart';
import '../../widgets/page_animation.dart';
import '../book_info/info_page.dart';

class BookHistory extends StatefulWidget {
  const BookHistory({Key? key}) : super(key: key);

  @override
  _BookHistoryState createState() => _BookHistoryState();
}

class _BookHistoryState extends State<BookHistory> with PageAnimationMixin {
  late BookCacheNotifier notifier;
  final show = ValueNotifier(false);
  late Listenable _listenable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifier = context.read<BookCacheNotifier>();
    if (!show.value) {
      _listenable = show;
      addListener(complete);
    }
  }

  void complete() {
    show.value = true;
    _listenable = notifier;
    removeListener(complete);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = !context.isDarkMode;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('浏览历史'),
          elevation: 1.0,
        ),
        body: AnimatedBuilder(
            animation: _listenable,
            builder: (context, _) {
              final data = notifier.rawList;
              if (!notifier.initialized || !show.value)
                return loadingIndicator(radius: 30);
              else if (data!.isEmpty) {
                return reloadBotton(notifier.load);
              }
              return ListViewBuilder(
                cacheExtent: 100,
                itemCount: data.length,
                padding: const EdgeInsets.only(bottom: 12.0),
                color: isLight ? null : Color.fromRGBO(25, 25, 25, 1),
                itemBuilder: (context, index) {
                  final item = data[index];
                  return ListItem(
                      bgColor: isLight ? null : Colors.grey.shade900,
                      splashColor:
                          isLight ? null : Color.fromRGBO(60, 60, 60, 1),
                      onTap: () {
                        if (item.bookId != null)
                          BookInfoPage.push(
                              context, item.bookId!, ApiType.biquge);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(item.name ?? ''))),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: btn1(
                                radius: 6.0,
                                bgColor: Colors.blue.shade400,
                                splashColor: Colors.blue.shade200,
                                onTap: () =>
                                    notifier.deleteBook(item.bookId, item.api),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 6.0),
                                child: Text(
                                  '删除记录',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              );
            }));
  }
}
