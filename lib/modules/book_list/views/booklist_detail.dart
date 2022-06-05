import 'package:flutter/material.dart';
import 'package:nop/event_queue.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../api/api.dart';
import '../../../data/data.dart';
import '../../../event/export.dart';
import '../../../widgets/image_text.dart';
import '../../../widgets/images.dart';
import '../../book_info/views/info_page.dart';
import '../../text_style/text_style.dart';

/// 书单详情页面
class BooklistDetailPage extends StatefulWidget {
  const BooklistDetailPage({Key? key, this.total, this.index})
      : super(key: key);
  final int? total;
  final int? index;
  @override
  _BooklistDetailPageState createState() => _BooklistDetailPageState();
}

class _BooklistDetailPageState extends State<BooklistDetailPage> {
  final provider = ShudanProvider();
  final refreshDelegate2 = RefreshDelegate(
      maxExtent: 100,
      onRefreshing: () {
        return release(const Duration(seconds: 1));
      },
      builder: (context, currentHeight, maxExtent, mode, refreshing) {
        return ColoredBox(
          color: Colors.blue,
          child: Center(
            child: Text('$mode $refreshing'),
          ),
        );
      });
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider.repository = context.getType<Repository>();
    provider.load(widget.index);
  }

  @override
  void didUpdateWidget(covariant BooklistDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    provider.load(widget.index);
  }

  bool get isLight => !context.isDarkMode;
  @override
  Widget build(BuildContext context) {
    final ts = context.getType<TextStyleConfig>().data;
    final listColor = isLight
        ? const Color.fromRGBO(236, 236, 236, 1)
        : Color.fromRGBO(25, 25, 25, 1);

    final titleColor =
        isLight ? Color.fromARGB(255, 250, 250, 250) : Colors.grey.shade900;
    const titlePadding = EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0);

    final bgColor = isLight ? null : Colors.grey.shade900;
    final splashColor = isLight ? null : Color.fromRGBO(60, 60, 60, 1);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text('书单详情'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: provider,
          builder: (context, child) {
            final data = provider.data;
            if (data == null) {
              return loadingIndicator();
            } else if (data.listId == null) {
              return reloadBotton(() => provider.load(widget.index));
            }

            // 头部
            final children = <Widget>[
              TitleWidget(data: data, total: widget.total),
              const SizedBox(height: 6),
              _DescWidget(description: data.description),
              const SizedBox(height: 6),
              Container(
                color: titleColor,
                padding: titlePadding,
                child: Text('书单列表', style: ts.title2),
              ),
              const SizedBox(height: 3)
            ];

            var headLength = children.length;
            var length = headLength;

            final bookList = data.bookList;

            if (bookList != null) {
              length += bookList.length;
            }

            return ListViewBuilder(
              color: listColor,
              itemCount: length,
              // refreshDelegate: refreshDelegate2,
              padding: const EdgeInsets.only(bottom: 12.0),
              itemBuilder: (context, index) {
                if (index < headLength) {
                  return children[index];
                }
                final dataIndex = index - headLength;
                final item = bookList![dataIndex];
                return ListItem(
                  bgColor: bgColor,
                  splashColor: splashColor,
                  height: 108,
                  onTap: () => BookInfoPage.push(item.bookId!, ApiType.biquge),
                  child: RepaintBoundary(
                    child: ShudanListDetailItemWidget(item: item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// desc
class _DescWidget extends StatelessWidget {
  _DescWidget({Key? key, this.description}) : super(key: key);
  final String? description;

  final hide = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    final color = !context.isDarkMode
        ? Color.fromARGB(255, 250, 250, 250)
        : Colors.grey.shade900;

    final ts = context.getType<TextStyleConfig>().data;

    final title = Text('简介', style: ts.title2);
    final body = Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: AnimatedBuilder(
        animation: hide,
        builder: (context, child) {
          final iconData = hide.value
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_up_rounded;

          return InkWell(
            onTap: () => hide.value = !hide.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  description ?? '',
                  maxLines: hide.value ? 2 : null,
                  overflow: TextOverflow.fade,
                  style: ts.body3,
                ),
                Center(child: Icon(iconData, color: Colors.grey[700])),
              ],
            ),
          );
        },
      ),
    );

    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, body],
      ),
    );
  }
}

/// head
class TitleWidget extends StatelessWidget {
  const TitleWidget({
    Key? key,
    required this.data,
    this.total,
  }) : super(key: key);

  final BookListDetailData data;
  final int? total;
  @override
  Widget build(BuildContext context) {
    final ts = context.getType<TextStyleConfig>().data;
    return Container(
      height: 120,
      color: !context.isDarkMode
          ? const Color.fromARGB(255, 250, 250, 250)
          : Colors.grey.shade900,
      padding: const EdgeInsets.all(12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 80),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: RepaintBoundary(
              child: ImageResolve(img: data.cover),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child:
                          Text(data.title ?? '', maxLines: 2, style: ts.title2),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Text('共$total本书', style: ts.body2),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Text(data.updateTime ?? '', style: ts.body3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShudanListDetailItemWidget extends StatelessWidget {
  const ShudanListDetailItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  final BookListDetail item;

  @override
  Widget build(BuildContext context) {
    return ImageTextLayout(
        img: item.bookIamge,
        topRightScore: '${item.score}分',
        top: item.bookName ?? '',
        center: '${item.categoryName} | ${item.author}',
        bottom: item.description ?? '');
  }
}

class ShudanProvider extends ChangeNotifierBase {
  ShudanProvider();
  Repository? repository;
  int? lastIndex;
  BookListDetailData? data;

  bool get _isEmpty => data == null || data == _none;
  final _none = const BookListDetailData();

  Future<void> load(int? index) async {
    if (index == null || repository == null || index == lastIndex) return;
    final _data = data;
    if (_data == _none) {
      data = null;
      notifyListeners();
    }

    data = await repository!.customEvent.getShudanDetail(index) ?? _none;

    if (!_isEmpty) lastIndex = index;

    if (_data == null) await release(const Duration(milliseconds: 300));

    notifyListeners();
  }
}
