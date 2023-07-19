import 'package:flutter/material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:flutter_nop/nop_state.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../api/api.dart';
import '../../../widgets/page_animation.dart';
import '../../book_info/views/info_page.dart';
import '../../home/providers/book_cache_notifier.dart';

class BookHistory extends StatefulWidget {
  const BookHistory({super.key});

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
    notifier = context.getType<BookCacheNotifier>();
    if (!show.value) {
      _listenable = show;
      addListener(complete);
    }
  }

  void complete() {
    show.value = true;
    _listenable = notifier.state.rawLists;
    removeListener(complete);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = !context.isDarkMode;

    final bgColor = isLight ? null : Colors.grey.shade900;
    final splashColor = isLight ? null : Color.fromRGBO(60, 60, 60, 1);
    final color = isLight
        ? const Color.fromRGBO(236, 236, 236, 1)
        : Color.fromRGBO(25, 25, 25, 1);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('浏览历史'), elevation: 1.0),
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
            color: color,
            itemBuilder: (context, index) {
              final item = data[index];

              Widget child = Text(
                '删除记录',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
              );

              final left = Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(item.name ?? ''),
              );

              child = Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: btn1(
                        radius: 6.0,
                        bgColor: Colors.blue.shade400,
                        splashColor: Colors.blue.shade200,
                        onTap: () => notifier.deleteBook(item.bookId, item.api),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 6.0),
                        child: child,
                      ),
                    ),
                  ],
                ),
              );

              return ListItem(
                bgColor: bgColor,
                splashColor: splashColor,
                onTap: () {
                  if (item.bookId != null) {
                    BookInfoPage.push(item.bookId!, ApiType.biquge);
                  }
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
