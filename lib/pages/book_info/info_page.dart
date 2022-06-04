import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../event/export.dart';
import '../../provider/export.dart';
import '../../routes/routes.dart';
import '../../widgets/image_text.dart';
import '../../widgets/images.dart';
import '../../widgets/indexs.dart';
import '../../widgets/page_animation.dart';
import '../book_content/book_content_page.dart';
import '../../widgets/app_bar.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({Key? key, required this.id, required this.api})
      : super(key: key);
  final int id;
  final ApiType api;
  @override
  _BookInfoPageState createState() => _BookInfoPageState();

  static Future push(int bookid, ApiType api) async {
    final notifier = ShuduRoute.getInfo;
    notifier.value += 1;
    return NavRoutes.bookInfoPage(id: bookid, api: api).go
      ..whenComplete(() {
        notifier.value -= 1;
        if (notifier.value == 0) ShuduRoute.removeInfo;
      });
    // return pushRecoder(
    //   key: 'navigator.push',
    //   saveCount: 3,
    //   callback: (pushNotifier) =>
    //       Nav.push(MaterialPageRoute(builder: (context) {
    //     return AnimatedBuilder(
    //         animation: pushNotifier,
    //         builder: (context, child) {
    //           return TickerMode(
    //               enabled: !pushNotifier.value,
    //               child: Offstage(offstage: pushNotifier.value, child: child));
    //         },
    //         child: RepaintBoundary(child: BookInfoPage(id: bookid, api: api)));
    //   })),
    // );
  }
}

class _BookInfoPageState extends State<BookInfoPage> with PageAnimationMixin {
  ValueNotifier<bool> showIndexs = ValueNotifier(false);
  // 确保关闭动画结束
  ValueNotifier<bool> showSecondary = ValueNotifier(false);
  final info = BookInfoProvider();
  late TextStyleData ts;
  late BookCacheNotifier cache;

  final parentValue = ValueNotifier(0.0);
  late ValueListenable<double> notifierValue;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    ts = context.read<TextStyleConfig>().data;
    info.repository = repository;
    cache = context.read<BookCacheNotifier>();
  }

  @override
  void initState() {
    super.initState();
    addListener(complete);
    notifierValue =
        parentValue.selector((parent) => parent.value.clamp(0.0, 120.0));
  }

  void complete() {
    info.getData(widget.id, widget.api);
    removeListener(complete);
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final value = parentValue.value + (notification.scrollDelta ?? 0);
      parentValue.value = value;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    const height = 48.0;

    final appBar = Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      child: AppBarHide(
        values: notifierValue,
        begincolor: isLight ? Color.fromARGB(255, 13, 157, 224) : null,
        title: Text(
          '书籍详情',
          style: TextStyle(color: Colors.grey.shade100, fontSize: 20),
        ),
      ),
    );

    final indexView = Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([showIndexs, showSecondary]),
          builder: (_, child) {
            final show = showIndexs.value;
            if (show) showSecondary.value = true;
            return AnimatedOpacity(
              opacity: show ? 1 : 0,
              onEnd: () {
                if (!show) showSecondary.value = false;
              },
              duration: const Duration(milliseconds: 300),
              child: showSecondary.value
                  ? background(
                      child: IndexsWidget(
                        onTap: (_, id, cid) {
                          BookContentPage.push(context, id, cid, 1, widget.api);
                          showIndexs.value = false;
                        },
                      ),
                    )
                  : const SizedBox(),
            );
          },
        ),
      ),
    );

    final child = Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        top: false,
        child: AnimatedBuilder(
          animation: info,
          builder: (context, child) {
            final infoData = info.get(widget.id);
            if (infoData == null) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: getOverlayStyle(dark: context.isDarkMode),
                child: loadingIndicator(),
              );
            }
            var children = <Widget>[];
            int bookId = 0;
            int? firstChapterId = -1;
            List<SameUserBook>? sameUserBooks;
            String? author;

            final _infoData = infoData as BookInfoRoot;
            final _bookId = _infoData.data?.id;

            if ((_infoData.data == null || _bookId == null)) {
              return reloadBotton(() => info.reload(widget.id, widget.api));
            }
            bookId = _bookId;
            final infos = _infoData.data!;
            firstChapterId = infos.firstChapterId;

            children.add(header(infos.author, infos.bookStatus, infos.name,
                infos.bookVote?.scroe, infos.cName, infos.img, ts));

            sameUserBooks = infos.sameUserBooks;
            author = infos.author;

            children.addAll(desc(infos.id, infos.author, infos.desc,
                infos.firstChapterId, infos.lastChapter, infos.lastTime, ts));

            final headLength = children.length;
            var length = headLength;
            final hasSameUserBook = sameUserBooks != null;
            if (hasSameUserBook) {
              length += sameUserBooks.length;
            }

            final bgColor = isLight ? null : Colors.grey.shade900;
            final splashColor = isLight ? null : Color.fromRGBO(60, 60, 60, 1);
            final color = isLight
                ? const Color.fromRGBO(236, 236, 236, 1)
                : Color.fromRGBO(25, 25, 25, 1);

            final bottomBar = Material(
              color: isLight ? Color.fromARGB(255, 13, 157, 224) : null,
              child: SafeArea(
                top: false,
                child: AnimatedBuilder(
                  animation: cache,
                  builder: (context, _) {
                    var show = false;
                    int? cid;
                    int? currentPage;
                    final list = cache.sortChildren;

                    for (var l in list) {
                      if (l.bookId == bookId) {
                        if (l.isShow ?? false) {
                          show = true;
                          cid = l.chapterId;
                          currentPage = l.page;
                        }
                        break;
                      }
                    }

                    final splashColor = isLight
                        ? Color.fromARGB(255, 110, 188, 248)
                        : Color.fromARGB(255, 107, 108, 109);

                    final ios = bottom > 0.0 &&
                        defaultTargetPlatform == TargetPlatform.iOS;

                    final padding = EdgeInsets.only(bottom: ios ? 10.0 : 0.0);
                    final style = TextStyle(
                        color: Color.fromARGB(255, 224, 224, 224),
                        fontSize: 15);

                    Widget child = Text(show ? '阅读' : '试读', style: style);
                    Widget rightChild =
                        Text('${show ? '移除' : '添加到'}书架', style: style);

                    child =
                        SizedBox(height: height, child: Center(child: child));

                    rightChild = SizedBox(
                        height: height, child: Center(child: rightChild));

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: btn1(
                            background: false,
                            splashColor: splashColor,
                            child: Padding(padding: padding, child: child),
                            onTap: () async {
                              final _list = await cache.getList;
                              int? _cid, _page;
                              for (final bookCache in _list) {
                                if (bookCache.bookId == bookId) {
                                  _cid = bookCache.chapterId;
                                  _page = bookCache.page;
                                  break;
                                }
                              }
                              _cid ??= cid ?? firstChapterId!;
                              _page ??= currentPage ?? 1;

                              BookContentPage.push(
                                  context, bookId, _cid, _page, widget.api);
                            },
                          ),
                        ),
                        Expanded(
                          child: btn1(
                            background: false,
                            splashColor: splashColor,
                            onTap: () =>
                                cache.updateShow(bookId, !show, widget.api),
                            child: Padding(padding: padding, child: rightChild),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value:
                  getOverlayStyle(dark: context.isDarkMode, statusDark: true),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SafeArea(
                          top: false,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: onScrollNotification,
                            child: ListViewBuilder(
                              color: color,
                              cacheExtent: 100,
                              itemCount: length,
                              itemBuilder: (context, index) {
                                if (index < headLength) {
                                  return children[index];
                                }
                                final bookIndex = index - headLength;
                                final data = sameUserBooks![bookIndex];

                                return ListItem(
                                  height: 108,
                                  bgColor: bgColor,
                                  splashColor: splashColor,
                                  onTap: () {
                                    if (data.id != null) {
                                      BookInfoPage.push(data.id!, widget.api);
                                    }
                                  },
                                  child: _BookInfoSameItemWidget(
                                      book: data,
                                      author: author,
                                      api: widget.api),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      bottomBar,
                    ],
                  ),
                  appBar,
                  indexView,
                ],
              ),
            );
          },
        ),
      ),
    );
    return child;
  }

  Widget background({required Widget child}) {
    final top = MediaQuery.maybeOf(context)?.padding.top ?? 0;
    return GestureDetector(
      onTap: () {
        showIndexs.value = !showIndexs.value;
      },
      child: Container(
        color: Colors.black.withAlpha(100),
        child: Stack(
          children: [
            Positioned(
              top: 10.0 + top,
              left: 24.0,
              right: 24.0,
              bottom: 66.0,
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                color: isLight ? Colors.grey.shade300 : Colors.grey.shade900,
                clipBehavior: Clip.hardEdge,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  var hide = true;
  List<Widget> desc(
    int? bookid,
    String? author,
    String? desc,
    int? firstChapterId,
    String? lastChapter,
    String? lastTime,
    TextStyleData ts,
  ) {
    return [
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        color: isLight
            ? const Color.fromRGBO(250, 250, 250, 1)
            : Colors.grey.shade900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('简介', style: ts.title2),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: StatefulBuilder(builder: (context, setstate) {
                return InkWell(
                  onTap: () => setstate(() => hide = !hide),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        desc ?? '',
                        style: ts.body3,
                        maxLines: hide ? 2 : null,
                      ),
                      Center(
                          child: Icon(
                        hide
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
      ),
      const SizedBox(height: 6),
      ColoredBox(
        color: isLight
            ? const Color.fromRGBO(250, 250, 250, 1)
            : Colors.grey.shade900,
        child: AnimatedBuilder(
          animation: cache,
          builder: (context, _) {
            int? cid;
            final list = cache.sortChildren;

            list.any((e) {
              if (e.bookId == bookid) {
                cid = e.chapterId;
                return true;
              }
              return false;
            });

            return btn1(
              onTap: () {
                final _cid = cid ?? firstChapterId;

                context
                    .read<BookIndexNotifier>()
                    .loadIndexs(bookid, _cid, api: widget.api);
                showIndexs.value = !showIndexs.value;
              },
              bgColor: isLight ? null : Colors.grey.shade900,
              splashColor: isLight
                  ? const Color.fromRGBO(225, 225, 225, 1)
                  : Color.fromRGBO(60, 60, 60, 1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('目录 最近更新 ', style: ts.title2),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  lastTime ?? '',
                                  softWrap: false,
                                  style: ts.body3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            lastChapter ?? '',
                            style: ts.body2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[600])
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Container(
        color: isLight
            ? const Color.fromRGBO(250, 250, 250, 1)
            : Colors.grey.shade900,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Text('$author 还写过', style: ts.body1),
      ),
      const SizedBox(height: 3),
    ];
  }

  bool get isLight => !context.isDarkMode;

  Widget header(String? author, String? bookStatus, String? name, double? scroe,
      String? cName, String? img, TextStyleData ts) {
    final realImg =
        img ?? '${PinyinHelper.getPinyinE(name ?? '', separator: '')}.jpg';
    final top = MediaQuery.maybeOf(context)?.padding.top ?? 0;
    return SizedBox(
      height: 200 + top,
      child: Stack(
        children: [
          ImageResolve(boxFit: BoxFit.fitWidth, img: realImg, shadow: false),
          ColoredBox(
            color: const Color.fromARGB(148, 0, 0, 0),
            child: const SizedBox.expand(),
          ),
          Container(
            padding: EdgeInsets.only(top: kToolbarHeight + top),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
              child: CustomMultiChildLayout(
                delegate: ImageLayout(width: 90),
                children: [
                  LayoutId(
                    id: ImageLayout.image,
                    child: ImageResolve(img: realImg, shadow: false),
                  ),
                  LayoutId(
                    id: ImageLayout.text,
                    child: Container(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: DefaultTextStyle(
                        style: ts.body2.copyWith(
                            color: const Color.fromARGB(255, 223, 223, 223)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 2.0, bottom: 5.0),
                              child: Text(
                                name ?? '',
                                style: ts.bigTitle1.copyWith(
                                    color: const Color.fromARGB(
                                        255, 223, 223, 223)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: false,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _wrapText('作者: $author'),
                                  _wrapText('类型: $cName'),
                                  _wrapText('状态: $bookStatus'),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: _wrapText('评分: $scroe分'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _wrapText(String? text) {
    return Text(
      text ?? '',
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

class _BookInfoSameItemWidget extends StatelessWidget {
  const _BookInfoSameItemWidget({
    Key? key,
    required this.author,
    required this.book,
    required this.api,
  }) : super(key: key);

  final SameUserBook book;
  final String? author;
  final ApiType api;
  @override
  Widget build(BuildContext context) {
    final nText = api == ApiType.biquge ? '最新: ' : '';
    return ImageTextLayout(
      height: 108,
      img: book.img,
      top: book.name ?? '',
      center: '作者: $author',
      bottom: '$nText${book.lastChapter}',
      bottomLines: 1,
    );
  }
}
