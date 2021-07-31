import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/book_info.dart';
import '../../event/event.dart';
import '../../provider/provider.dart';
import '../../widgets/image_text.dart';
import '../../widgets/images.dart';
import '../../widgets/indexs.dart';
import '../../widgets/page_animation.dart';
import '../../widgets/text_builder.dart';
import '../book_content/book_content_page.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({Key? key, required this.id}) : super(key: key);
  final int id;
  @override
  _BookInfoPageState createState() => _BookInfoPageState();

  static Future push(BuildContext context, int bookid,
      {bool maintainState = true}) async {
    return Navigator.of(context).push(MaterialPageRoute(
        maintainState: maintainState, // 存在许多个[BookInfoPage]页面的可能，所以不应常驻内存
        builder: (context) {
          return BookInfoPage(id: bookid);
        }));
  }
}

class _BookInfoPageState extends State<BookInfoPage> with PageAnimationMixin {
  ValueNotifier<bool> showIndexs = ValueNotifier(false);
  // 确保关闭动画结束
  ValueNotifier<bool> showSecondary = ValueNotifier(false);
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
  void initState() {
    super.initState();
    addListener(complete);
  }

  void complete() {
    info.getData(widget.id);
    removeListener(complete);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final child = Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('书籍详情'),
          elevation: 1.0,
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: info,
            builder: (context, child) {
              final infoData = info.get(widget.id);
              if (infoData == null) {
                return loadingIndicator();
              } else if (infoData.data == null || infoData.data?.id == null) {
                return reloadBotton(() => info.reload(widget.id));
              }

              var children = <Widget>[];
              final infos = infoData.data!;

              children.add(header(infos.author, infos.bookStatus, infos.name,
                  infos.bookVote, infos.cName, infos.desc, infos.img, ts));

              children.addAll(desc(infos, ts));
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListViewBuilder(
                          cacheExtent: 100,
                          itemBuilder: (context, index) {
                            return children[index];
                          },
                          itemCount: children.length,
                        ),
                      ),
                      Material(
                        color: Colors.blue.shade300,
                        child: AnimatedBuilder(
                          animation: cache,
                          builder: (context, _) {
                            final bookid = infos.id!;

                            var show = false;

                            int? cid;
                            int? currentPage;

                            final list = cache.sortChildren;

                            for (var l in list) {
                              if (l.bookId == bookid) {
                                if (l.isShow ?? false) {
                                  show = true;
                                  cid = l.chapterId;
                                  currentPage = l.page;
                                }
                                break;
                              }
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: btn1(
                                      child: SizedBox(
                                        height: 56,
                                        child: Center(
                                          child: Text(show ? '阅读' : '试读'),
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
                                      onTap: () =>
                                          cache.updateShow(bookid, !show),
                                      child: SizedBox(
                                          height: 56,
                                          child: Center(
                                              child: Text(
                                                  '${show ? '移除' : '添加到'}书架'))),
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
                  // Widget层动画
                  // TODO: 优化动画
                  Positioned.fill(
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
                                        BookContentPage.push(
                                            context, id, cid, 1);
                                        showIndexs.value = false;
                                      },
                                    ),
                                    // child: Container(),
                                  )
                                : const SizedBox());
                      },
                    ),
                  )
                ],
              );
            },
          ),
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
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                color: Colors.grey.shade300,
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
  Iterable<Widget> desc(BookInfo info, TextStyleConfig ts) sync* {
    yield const SizedBox(height: 6);
    yield Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      color: const Color.fromRGBO(250, 250, 250, 1),
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
                      info.desc ?? '',
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
    yield const SizedBox(height: 6);

    yield Container(
      color: const Color.fromRGBO(250, 250, 250, 1),
      child: AnimatedBuilder(
        animation: cache,
        builder: (context, _) {
          final bookid = info.id;

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
              final _cid = cid ?? info.firstChapterId;

              context.read<BookIndexNotifier>().loadIndexs(bookid, _cid);
              showIndexs.value = !showIndexs.value;
            },
            bgColor: Color.fromARGB(255, 250, 250, 250),
            splashColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
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
                                info.lastTime ?? '',
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
                          info.lastChapter ?? '',
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
    yield const SizedBox(height: 6);

    yield Container(
      color: const Color.fromRGBO(250, 250, 250, 1),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Text('${info.author} 还写过'),
    );

    yield const SizedBox(height: 3);

    if (info.sameUserBooks != null)
      for (var l in info.sameUserBooks!)
        yield ListItem(
            height: 108,
            child: _BookInfoSameItemWidget(l: l, author: info.author),
            onTap: () => l.id == null
                ? null
                : BookInfoPage.push(context, l.id!, maintainState: false));
  }

  Widget header(
      String? author,
      String? bookStatus,
      String? name,
      BookVote? bookvote,
      String? cName,
      String? desc,
      String? img,
      TextStyleConfig ts) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      color: const Color.fromRGBO(250, 250, 250, 1),
      child: RepaintBoundary(
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: CustomMultiChildLayout(
            delegate: ImageLayout(width: 90),
            children: [
              LayoutId(
                id: ImageLayout.image,
                child: ImageResolve(
                    img: img ??
                        '${PinyinHelper.getPinyinE(name ?? '', separator: '')}.jpg'),
              ),
              LayoutId(
                id: ImageLayout.text,
                child: RepaintBoundary(
                  child: Container(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: DefaultTextStyle(
                      style: ts.body2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.only(top: 2.0, bottom: 5.0),
                            child: Text(
                              name ?? '',
                              style: ts.title2,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: false,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _wrapText('作者：$author'),
                                _wrapText('类型：$cName'),
                                _wrapText('状态：$bookStatus'),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: _wrapText('评分：${bookvote?.scroe}分'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
    required this.l,
  }) : super(key: key);

  final SameUserBook l;
  final String? author;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      height: 108,
      child: CustomMultiChildLayout(
        delegate: ImageLayout(width: 72),
        children: [
          LayoutId(
            id: ImageLayout.image,
            child: RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ImageResolve(img: l.img),
              ),
            ),
          ),
          LayoutId(
            id: ImageLayout.text,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: TextAsyncLayout(
                  height: 108,
                  top: l.name ?? '',
                  center: '作者：$author',
                  bottom: '最新: ${l.lastChapter}',
                ),
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }
}
