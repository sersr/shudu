import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../../data/book_info.dart';
import '../../database/nop_database.dart';
import '../../event/event.dart';
import '../../utils/utils.dart';
import '../../utils/widget/page_animation.dart';
import '../../widgets/async_text.dart';
import '../book_content_view/book_content_page.dart';
import '../book_list_view/list_shudan_detail.dart';
import '../embed/images.dart';
import '../embed/indexs.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({Key? key, required this.id}) : super(key: key);
  final int id;
  @override
  _BookInfoPageState createState() => _BookInfoPageState();

  static Future push(BuildContext context, int bookid) async {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return wrapData(BookInfoPage(id: bookid));
    }));
  }
}

class _BookInfoPageState extends State<BookInfoPage> with PageAnimationMixin {
  ValueNotifier<bool> showIndexs = ValueNotifier(false);
  final info = BookInfoProvider();
  late TextStyleConfig ts;
  late BookCacheNotifier cache;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    ts = context.read<TextStyleConfig>();
    info.repository = repository;
    cache = context.read<BookCacheNotifier>();
  }

  @override
  void complete() => info.getData(widget.id);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final child = Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('书籍详情'),
          backgroundColor: Colors.white,
          elevation: 1.0,
        ),
        body: AnimatedBuilder(
          animation: info,
          builder: (context, child) {
            final infoData = info.get(widget.id);
            if (infoData == null) {
              return loadingIndicator();
            } else if (infoData.data == null) {
              return reloadBotton(() => info.reload(widget.id));
            }

            var children = <Widget>[];
            final infos = infoData.data!;

            children.add(header(infos.author, infos.bookStatus, infos.name,
                infos.bookVote!, infos.cName, infos.desc, infos.img, ts));

            children.addAll(desc(infos, ts));
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Color.fromARGB(255, 242, 242, 242),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return children[index];
                          },
                          itemCount: children.length,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.cyan,
                      child: AnimatedBuilder(
                        animation: cache,
                        builder: (context, child) {
                          final bookid = infos.id!;
                          var contain = false;
                          int? cid;
                          int? currentPage;
                          var added = false;
                          final list = cache.sortChildren;
                          for (var l in list) {
                            if (l.bookId == bookid) {
                              added = true;
                              if (l.isShow ?? false) {
                                contain = true;
                                cid = l.chapterId;
                                currentPage = l.page;
                              }
                              break;
                            }
                          }

                          if (!added) {
                            var addCache = BookCache(
                              name: infos.name,
                              img: infos.img,
                              updateTime: infos.lastTime,
                              lastChapter: infos.lastChapter,
                              chapterId: infos.firstChapterId,
                              bookId: infos.id,
                              sortKey: DateTime.now().millisecondsSinceEpoch,
                              isTop: false,
                              page: 1,
                              isNew: true,
                              isShow: false,
                            );
                            Provider.of<BookIndexNotifier>(context)
                                .repository
                                .bookEvent
                                .bookCacheEvent
                                .insertBook(addCache);
                          }

                          return Container(
                            padding: EdgeInsets.only(
                                bottom: bottom > 0.0 &&
                                        defaultTargetPlatform ==
                                            TargetPlatform.iOS
                                    ? 10.0
                                    : 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: btn1(
                                    child: Container(
                                      height: 56,
                                      child: Center(
                                        child: Text('${contain ? '阅读' : '试读'}'),
                                      ),
                                    ),
                                    onTap: () async {
                                      final _list = await cache.getList;
                                      int? _cid, _page;
                                      for (final bookCache in _list) {
                                        if (bookCache.bookId == bookid) {
                                          _cid = bookCache.chapterId;
                                          _page = bookCache.page;
                                          break;
                                        }
                                      }
                                      _cid ??= cid ?? infos.firstChapterId!;
                                      _page ??= currentPage ?? 1;
                                      BookContentPage.push(
                                          context, bookid, _cid, _page);
                                    },
                                    background: false,
                                  ),
                                ),
                                Expanded(
                                  child: btn1(
                                    background: false,
                                    onTap: () {
                                      if (contain) {
                                        cache.deleteBook(bookid);
                                      } else {
                                        cache.updateTop(infos.id!, false);
                                      }
                                      Future.delayed(
                                          Duration(milliseconds: 400),
                                          cache.load);
                                    },
                                    child: Container(
                                        height: 56,
                                        child: Center(
                                            child: Text(
                                                '${contain ? '移除' : '添加到'}书架'))),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: showIndexs,
                    builder: (_, child) {
                      if (showIndexs.value) {
                        return background(
                          child: IndexsWidget(
                            onTap: (_, id, cid) {
                              BookContentPage.push(context, id, cid, 1);
                              showIndexs.value = false;
                            },
                          ),
                          // child: Container(),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                )
              ],
            );
          },
        ));
    return child;
  }

  Widget background({required Widget child}) {
    return GestureDetector(
      onTap: () {
        showIndexs.value = !showIndexs.value;
      },
      child: Container(
        color: Colors.black.withAlpha(100),
        child: Stack(
          children: [
            Positioned(
              top: 10.0,
              left: 24.0,
              right: 24.0,
              bottom: 66.0,
              child: Material(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.grey.shade300,
                clipBehavior: Clip.hardEdge,
                elevation: 4.0,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  var hide = true;
  Iterable<Widget> desc(BookInfo info, TextStyleConfig ts) sync* {
    yield Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      color: Color.fromARGB(255, 250, 250, 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('简介', style: ts.title2),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: StatefulBuilder(builder: (context, setstate) {
              return InkWell(
                onTap: () {
                  setstate(() => hide = !hide);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AsyncText(
                      text: info.desc!,
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
    );
    yield Container(
      margin: const EdgeInsets.only(top: 10.0),
      color: Color.fromARGB(255, 250, 250, 250),
      child: AnimatedBuilder(
        animation: cache,
        builder: (context, _) {
          final bookid = info.id;

          int? cid;
          final list = cache.sortChildren;
          list.forEach((element) {
            if (element.bookId == bookid) {
              cid = element.chapterId;
            }
          });

          return btn1(
            onTap: () {
              final _cid = cid ?? info.firstChapterId;

              context.read<BookIndexNotifier>().sendIndexs(bookid, _cid);
              showIndexs.value = !showIndexs.value;
            },
            radius: 0,
            bgColor: Color.fromARGB(255, 250, 250, 250),
            splashColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '目录 最近更新 ',
                            style: ts.title2,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                info.lastTime!,
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
                          '${info.lastChapter}',
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
    );

    yield Container(
      color: Color.fromARGB(255, 250, 250, 250),
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Text('${info.author} 还写过'),
    );
    yield const SizedBox(height: 1);
    if (info.sameUserBooks != null)
      for (var l in info.sameUserBooks!)
        yield _BookInfoSameItemWidget(l: l, author: info.author);
  }

  Widget header(
      String? author,
      String? bookStatus,
      String? name,
      BookVote bookvote,
      String? cName,
      String? desc,
      String? img,
      TextStyleConfig ts) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RepaintBoundary(
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          color: Color.fromARGB(255, 250, 250, 250),
          child: Row(
            children: [
              Container(
                  height: 130,
                  width: 86,
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ImageResolve(img: img))),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: DefaultTextStyle(
                    style: ts.body2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
                          child: Text(
                            '$name',
                            style: ts.title2,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: false,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _wrapText('类型：$cName'),
                                _wrapText('状态：$bookStatus'),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: _wrapText('评分：${bookvote.scroe}分'),
                                ),
                              ],
                            ),
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
    );
  }

  Text _wrapText(String? text) {
    return Text(
      '$text',
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

class _BookInfoSameItemWidget extends StatelessWidget {
  const _BookInfoSameItemWidget({
    Key? key,
    required this.author,
    required this.l,
  }) : super(key: key);

  final SameUserBook l;
  final String? author;
  @override
  Widget build(BuildContext context) {
    final ts = Provider.of<TextStyleConfig>(context);
    return Container(
      decoration: BoxDecoration(
          border: BorderDirectional(
              bottom: BorderSide(width: 1, color: Colors.grey.shade300))),
      child: btn1(
        radius: 0,
        bgColor: Color.fromARGB(255, 250, 250, 250),
        splashColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        onTap: () {
          if (l.id != null) BookInfoPage.push(context, l.id!);
        },
        child: Row(children: [
          Container(
            width: 72,
            height: 108,
            child: ImageResolve(img: l.img),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: _InfoItem(l: l, ts: ts, author: author),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    Key? key,
    required this.l,
    required this.ts,
    required this.author,
  }) : super(key: key);

  final SameUserBook l;
  final TextStyleConfig ts;
  final String? author;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<List<TextPainter>>(
            future: Future.wait<TextPainter>([
              AsyncText.asyncLayout(
                  constraints.maxWidth,
                  TextPainter(
                      text: TextSpan(text: '${l.name}', style: ts.title3),
                      maxLines: 1,
                      textDirection: TextDirection.ltr)),
              AsyncText.asyncLayout(
                  constraints.maxWidth,
                  TextPainter(
                      text: TextSpan(text: '作者：$author', style: ts.body2),
                      maxLines: 1,
                      textDirection: TextDirection.ltr)),
              AsyncText.asyncLayout(
                  constraints.maxWidth,
                  TextPainter(
                      text: TextSpan(
                        text: '最新: ${l.lastChapter}',
                        style: ts.body3,
                      ),
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
                    LayoutId(id: 'center', child: AsyncText.async(data[1])),
                    LayoutId(id: 'bottom', child: AsyncText.async(data[2])),
                  ],
                );
              }
              return SizedBox();
            },
          );
        },
      ),
    );
  }
}
