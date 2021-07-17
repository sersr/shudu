import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/book_list_detail.dart';
import '../../event/event.dart';
import '../../provider/provider.dart';
import '../../utils/utils.dart';
import '../../widgets/image_text.dart';
import '../../widgets/text_builder.dart';
import '../book_info_view/book_info_page.dart';
import '../embed/images.dart';
import '../embed/list_builder.dart';

class ShudanDetailPage extends StatefulWidget {
  const ShudanDetailPage({Key? key, this.total, this.index}) : super(key: key);
  final int? total;
  final int? index;
  @override
  _ShudanDetailPageState createState() => _ShudanDetailPageState();
}

class _ShudanDetailPageState extends State<ShudanDetailPage> {
  final provider = ShudanProvider();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider.repository = context.read<Repository>();
    provider.load(widget.index);
  }

  @override
  void didUpdateWidget(covariant ShudanDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    provider.load(widget.index);
  }

  Iterable<Widget> _getChildren(
      BookListDetailData data, TextStyleConfig ts) sync* {
    // header
    yield Container(
      height: 120,
      color: const Color.fromARGB(255, 250, 250, 250),
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 80),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: Container(
              // width: 80,
              // height: 120,
              child: ImageResolve(img: data.cover),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: RepaintBoundary(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child:
                          Text('${data.title}', maxLines: 2, style: ts.title2),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Text('共${widget.total}本书', style: ts.body2),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Text('${data.updateTime}', style: ts.body3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    yield const SizedBox(height: 6);
    // intro
    yield buildIntro(ts, data.description);
    // body
    yield const SizedBox(height: 6);

    yield Container(
      color: Color.fromARGB(255, 250, 250, 250),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Text('书单列表', style: ts.title2),
    );

    yield const SizedBox(height: 3);

    if (data.bookList != null)
      for (var l in data.bookList!)
        yield ListItemBuilder(
          onTap: () => BookInfoPage.push(context, l.bookId!),
          child: ShudanListDetailItemWidget(l: l),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ts = context.read<TextStyleConfig>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('书单详情'),
      ),
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, child) {
          final data = provider.data;
          if (data == null) {
            return loadingIndicator();
          } else if (data.listId == null) {
            return reloadBotton(() => provider.load(widget.index));
          }

          final children = _getChildren(data, ts);
          return ListViewBuilder(
            padding: const EdgeInsets.only(bottom: 12.0),
            itemBuilder: (context, index) {
              return children.elementAt(index);
            },
            itemCount: children.length,
          );
        },
      ),
    );
  }

  var hide = ValueNotifier(true);

  Widget buildIntro(TextStyleConfig ts, String? description) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      color: Color.fromARGB(255, 250, 250, 250),
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
                          '$description',
                          maxLines: hide.value ? 2 : null,
                          overflow: TextOverflow.fade,
                          style: ts.body2,
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

class ShudanListDetailItemWidget extends StatelessWidget {
  const ShudanListDetailItemWidget({
    Key? key,
    required this.l,
  }) : super(key: key);

  final BookListDetail l;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ImageResolve(img: l.bookIamge),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: TextBuilder(
                  height: 108,
                  topRightScore: '${l.score}分',
                  top: l.bookName,
                  center: '${l.categoryName} | ${l.author}',
                  bottom: '${l.description}'),
            ),
          ),
        ],
      ),
    );
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
        await repository!.bookEvent.customEvent.getShudanDetail(index) ?? _none;

    if (!_isEmpty) lastIndex = index;

    if (_data == null) await release(const Duration(milliseconds: 300));

    notifyListeners();
  }
}
