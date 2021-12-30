import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../event/export.dart';
import '../../provider/export.dart';
import '../../widgets/image_text.dart';
import '../../widgets/images.dart';
import '../book_info/info_page.dart';

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
    provider.repository = context.read<Repository>();
    provider.load(widget.index);
  }

  @override
  void didUpdateWidget(covariant BooklistDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    provider.load(widget.index);
  }

  Iterable<Widget> _getChildren(
      BookListDetailData data, TextStyleData ts) sync* {
    // header
    yield TitleWidget(data: data, total: widget.total);
    yield const SizedBox(height: 6);
    // intro
    yield buildIntro(ts, data.description);
    // body
    yield const SizedBox(height: 6);

    yield Container(
      color:
          isLight ? Color.fromARGB(255, 250, 250, 250) : Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Text('书单列表', style: ts.title2),
    );

    yield const SizedBox(height: 3);

    if (data.bookList != null)
      for (var l in data.bookList!)
        yield ListItem(
          bgColor: isLight ? null : Colors.grey.shade900,
          splashColor: isLight ? null : Color.fromRGBO(60, 60, 60, 1),
          height: 108,
          onTap: () => BookInfoPage.push(context, l.bookId!, ApiType.biquge),
          child: ShudanListDetailItemWidget(l: l),
        );
  }

  bool get isLight => !context.isDarkMode;
  @override
  Widget build(BuildContext context) {
    final ts = context.read<TextStyleConfig>().data;

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

            final children = _getChildren(data, ts);
            return Stack(
              children: [
                RepaintBoundary(
                  child: ListViewBuilder(
                    color: isLight ? null : Color.fromRGBO(25, 25, 25, 1),

                    refreshDelegate: refreshDelegate2,
                    padding: const EdgeInsets.only(bottom: 12.0),
                    // cacheExtent: 100,
                    itemBuilder: (context, index) {
                      return children.elementAt(index);
                    },
                    itemCount: children.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  var hide = ValueNotifier(true);

  Widget buildIntro(TextStyleData ts, String? description) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      color:
          isLight ? Color.fromARGB(255, 250, 250, 250) : Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('简介', style: ts.title2),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: AnimatedBuilder(
                animation: hide,
                builder: (context, child) {
                  return InkWell(
                    onTap: () {
                      hide.value = !hide.value;
                    },
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
                        Center(
                            child: Icon(
                          hide.value
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          color: Colors.grey[700],
                        )),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class TitleWidget extends StatefulWidget {
  const TitleWidget({
    Key? key,
    required this.data,
    this.total,
  }) : super(key: key);

  final BookListDetailData data;
  final int? total;
  @override
  State<TitleWidget> createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ts = context.read<TextStyleConfig>().data;
    final data = widget.data;
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
                      child: Text('共${widget.total}本书', style: ts.body2),
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

  @override
  bool get wantKeepAlive => true;
}

class ShudanListDetailItemWidget extends StatelessWidget {
  const ShudanListDetailItemWidget({
    Key? key,
    required this.l,
  }) : super(key: key);

  final BookListDetail l;

  @override
  Widget build(BuildContext context) {
    return ImageTextLayout(
        img: l.bookIamge,
        topRightScore: '${l.score}分',
        top: l.bookName ?? '',
        center: '${l.categoryName} | ${l.author}',
        bottom: l.description ?? '');
  }
}

class ShudanProvider extends ChangeNotifier {
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

    data =
        await repository!.customEvent.getShudanDetail(index) ?? _none;

    if (!_isEmpty) lastIndex = index;

    if (_data == null) await release(const Duration(milliseconds: 300));

    notifyListeners();
  }
}
