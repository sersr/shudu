import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../provider/provider.dart';
import '../../utils/utils.dart';
import '../book_info_view/book_info_page.dart';
import '../embed/list_builder.dart';

class BookHistory extends StatefulWidget {
  const BookHistory({Key? key}) : super(key: key);

  @override
  _BookHistoryState createState() => _BookHistoryState();
}

class _BookHistoryState extends State<BookHistory> {
  late BookCacheNotifier notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifier = context.read<BookCacheNotifier>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('浏览历史'),
          backgroundColor: Colors.white,
          elevation: 1.0,
        ),
        body: AnimatedBuilder(
            animation: notifier,
            builder: (context, _) {
              final data = notifier.sortChildren;
              if (!notifier.initialized)
                return loadingIndicator(radius: 30);
              else if (data.isEmpty) {
                return reloadBotton(notifier.load);
              }
              return ListViewBuilder(
                itemCount: data.length,
                padding: const EdgeInsets.only(bottom: 12.0),
                itemBuilder: (context, index) {
                  final item = data[index];
                  return ListItemBuilder(
                      onTap: () {
                        if (item.bookId != null)
                          BookInfoPage.push(context, item.bookId!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text('${item.name}'))),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: btn1(
                                radius: 6.0,
                                bgColor: Colors.blue.shade400,
                                splashColor: Colors.blue.shade200,
                                onTap: () => notifier.deleteBook(item.id),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Text(
                                  '删除',
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
