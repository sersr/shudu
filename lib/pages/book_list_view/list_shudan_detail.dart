import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/book_list_detail.dart';
import '../../event/event.dart';
import '../../provider/provider.dart';
import '../../utils/utils.dart';
import '../../widgets/async_text.dart';
import '../../widgets/image_text.dart';
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
            id: 'image',
            child: Container(
              width: 80,
              height: 120,
              child: ImageResolve(img: data.cover),
            ),
          ),
          LayoutId(
            id: 'text',
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text('${data.title}', maxLines: 2, style: ts.title2),
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
    final ts = context.read<TextStyleConfig>();
    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: 'image',
            child: Container(
              // width: 72,
              // height: 108,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ImageResolve(img: l.bookIamge),
            ),
          ),
          LayoutId(
            id: 'text',
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: _DetailLayout(l: l, ts: ts),
            ),
          ),
        ],
      ),
      // ),
    );
  }
}

class _DetailLayout extends StatelessWidget {
  const _DetailLayout({
    Key? key,
    required this.l,
    required this.ts,
  }) : super(key: key);

  final BookListDetail l;
  final TextStyleConfig ts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topRight = AsyncText.asyncLayout(
            constraints.maxWidth,
            TextPainter(
                text: TextSpan(
                  text: '${l.score}分',
                  style: ts.title3.copyWith(color: Colors.yellow.shade700),
                ),
                maxLines: 2,
                textDirection: TextDirection.ltr));

        return FutureBuilder<List<TextPainter>>(
            future: Future.wait<TextPainter>([
              topRight.then((value) => AsyncText.asyncLayout(
                  constraints.maxWidth - value.width,
                  TextPainter(
                      text: TextSpan(text: '${l.bookName}', style: ts.title3),
                      maxLines: 2,
                      textDirection: TextDirection.ltr))),
              topRight,
              AsyncText.asyncLayout(
                  constraints.maxWidth,
                  TextPainter(
                      text: TextSpan(
                          text: '${l.categoryName} | ${l.author}',
                          style: ts.body1
                              .copyWith(color: TextStyleConfig.blackColor6)),
                      maxLines: 1,
                      textDirection: TextDirection.ltr)),
              AsyncText.asyncLayout(
                  constraints.maxWidth,
                  TextPainter(
                      text: TextSpan(text: '${l.description}', style: ts.body3),
                      maxLines: 2,
                      textDirection: TextDirection.ltr)),
            ]),
            builder: (context, snap) {
              if (snap.hasData) {
                final data = snap.data!;
                return CustomMultiChildLayout(
                  delegate: ItemDetailWidget(108),
                  children: [
                    LayoutId(id: 'top', child: AsyncText.async(data[0])),
                    LayoutId(id: 'topRight', child: AsyncText.async(data[1])),
                    LayoutId(id: 'center', child: AsyncText.async(data[2])),
                    LayoutId(id: 'bottom', child: AsyncText.async(data[3])),
                  ],
                );
              }
              return SizedBox();
            });
      },
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

class ItemDetailWidget extends MultiChildLayoutDelegate {
  ItemDetailWidget(this.height);
  final double height;

  @override
  void performLayout(Size size) {
    final _top = 'top';
    final _topRight = 'topRight';
    final _center = 'center';
    final _bottom = 'bottom';
    final constraints = BoxConstraints.loose(size);

    var topRight = Size.zero;
    if (hasChild(_topRight)) topRight = layoutChild(_topRight, constraints);

    final top = layoutChild(_top,
        constraints.copyWith(minWidth: constraints.maxWidth - topRight.width));

    final center = layoutChild(_center, constraints);
    final bottom = layoutChild(_bottom, constraints);
    var cHeight = 0.0;
    var height = 0.0;
    final _topHeight = math.max(top.height, topRight.height);
    height = _topHeight + center.height + bottom.height;

    final d = (size.height - 10 - height) / 4;
    cHeight = d + 2.5;

    positionChild(_top, Offset(0, cHeight));
    if (hasChild(_topRight))
      positionChild(_topRight, Offset(size.width - topRight.width, cHeight));
    cHeight += _topHeight + d;
    positionChild(_center, Offset(0, cHeight));
    cHeight += center.height + d;
    positionChild(_bottom, Offset(0, cHeight));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }

  @override
  Size getSize(BoxConstraints constraints) =>
      Size(constraints.biggest.width, constraints.constrainHeight(height));
}
