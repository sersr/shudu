import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../event/event.dart';
import '../../provider/provider.dart';
import '../../widgets/image_text.dart';
import '../../widgets/images.dart';
import '../../widgets/indexs.dart';
import '../../widgets/page_animation.dart';
import '../../widgets/text_builder.dart';
import '../book_content/book_content_page.dart';
import 'app_bar.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({Key? key, required this.id, required this.api})
      : super(key: key);
  final int id;
  final ApiType api;
  @override
  _BookInfoPageState createState() => _BookInfoPageState();

  static Future push(BuildContext context, int bookid, ApiType api) async {
    return pushRecoder(
      key: 'navigator.push',
      saveCount: 3,
      callback: (pushNotifier) =>
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return AnimatedBuilder(
            animation: pushNotifier,
            builder: (context, child) {
              return TickerMode(
                  enabled: !pushNotifier.value,
                  child: Offstage(offstage: pushNotifier.value, child: child));
            },
            child: RepaintBoundary(child: BookInfoPage(id: bookid, api: api)));
      })),
    );
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
          if (widget.api == ApiType.biquge) {
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

            children.addAll(desc(
                infos.id,
                infos.author,
                infos.desc,
                infos.firstChapterId,
                infos.lastChapter,
                infos.lastTime,
                infos.sameUserBooks,
                ts));
          } else if (widget.api == ApiType.zhangdu) {
            final data = infoData as ZhangduDetailData?;
            final _bookId = data?.id;
            if (data == null || _bookId == null) {
              return reloadBotton(() => info.reload(widget.id, widget.api));
            }
            bookId = _bookId;
            firstChapterId = info.firstCid ?? data.chapterId ?? firstChapterId;
            children.add(header(data.author, data.bookStatus, data.name,
                data.score, data.categoryName, data.picture, ts));
            children.addAll(desc(
              data.id,
              data.author,
              data.intro,
              firstChapterId,
              data.chapterName,
              data.updatedTime,
              info.sameUsers
                  ?.map((e) => SameUserBook(
                        id: e.id,
                        img: e.picture,
                        lastChapter: e.intro,
                        name: e.name,
                        score: e.score,
                      ))
                  .toList(),
              ts,
              api: ApiType.zhangdu,
            ));
          }

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: getOverlayStyle(dark: context.isDarkMode, statusDark: true),
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
                            color:
                                isLight ? null : Color.fromRGBO(25, 25, 25, 1),
                            cacheExtent: 100,
                            itemBuilder: (context, index) {
                              return children[index];
                            },
                            itemCount: children.length,
                          ),
                        ),
                      ),
                    ),
                    Material(
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

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: btn1(
                                    splashColor: isLight
                                        ? Color.fromARGB(255, 110, 188, 248)
                                        : Color.fromARGB(255, 107, 108, 109),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: bottom > 0.0 &&
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.iOS
                                              ? 10.0
                                              : 0.0),
                                      child: SizedBox(
                                        height: 56,
                                        child: Center(
                                          child: Text(
                                            show ? '阅读' : '试读',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 224, 224, 224),
                                                fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    ),
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

                                      BookContentPage.push(context, bookId,
                                          _cid, _page, widget.api);
                                    },
                                    background: false,
                                  ),
                                ),
                                Expanded(
                                  child: btn1(
                                    background: false,
                                    splashColor: isLight
                                        ? Color.fromARGB(255, 110, 188, 248)
                                        : Color.fromARGB(255, 107, 108, 109),
                                    onTap: () => cache.updateShow(
                                        bookId, !show, widget.api),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: bottom > 0.0 &&
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.iOS
                                              ? 10.0
                                              : 0.0),
                                      child: SizedBox(
                                          height: 56,
                                          child: Center(
                                              child: Text(
                                            '${show ? '移除' : '添加到'}书架',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 224, 224, 224),
                                                fontSize: 15),
                                          ))),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  height: 56 + (MediaQuery.maybeOf(context)?.padding.top ?? 0),
                  child: AppBarHide(
                    values: notifierValue,
                    begincolor:
                        isLight ? Color.fromARGB(255, 13, 157, 224) : null,
                    title: Text(
                      '书籍详情',
                      style:
                          TextStyle(color: Colors.grey.shade100, fontSize: 20),
                    ),
                  ),
                ),
                Positioned.fill(
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
                                        BookContentPage.push(
                                            context, id, cid, 1, widget.api);
                                        showIndexs.value = false;
                                      },
                                    ),
                                    // child: Container(),
                                  )
                                : const SizedBox());
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    ));
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
  Iterable<Widget> desc(
      int? bookid,
      String? author,
      String? desc,
      int? firstChapterId,
      String? lastChapter,
      String? lastTime,
      List<SameUserBook>? sameUserBooks,
      TextStyleData ts,
      {ApiType api = ApiType.biquge}) sync* {
    yield const SizedBox(height: 6);
    yield Container(
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
    );

    yield const SizedBox(height: 6);
    yield ColoredBox(
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

            // bgColor: Color.fromARGB(255, 250, 250, 250),
            // splashColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
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
    );
    yield const SizedBox(height: 6);

    yield Container(
      color: isLight
          ? const Color.fromRGBO(250, 250, 250, 1)
          : Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Text('$author 还写过', style: ts.body1),
    );

    yield const SizedBox(height: 3);

    if (sameUserBooks != null)
      for (var l in sameUserBooks)
        yield ListItem(
            height: 108,
            bgColor: isLight ? null : Colors.grey.shade900,
            splashColor: isLight ? null : Color.fromRGBO(60, 60, 60, 1),
            child: _BookInfoSameItemWidget(l: l, author: author, api: api),
            onTap: () => l.id == null
                ? null
                : BookInfoPage.push(context, l.id!, widget.api));
  }

  bool get isLight => !context.isDarkMode;

  Widget header(String? author, String? bookStatus, String? name, double? scroe,
      String? cName, String? img, TextStyleData ts) {
    final realImg =
        img ?? '${PinyinHelper.getPinyinE(name ?? '', separator: '')}.jpg';
    final top = MediaQuery.maybeOf(context)?.padding.top ?? 0;
    return SizedBox(
      height: 180 + top,
      child: Stack(
        children: [
          ImageResolve(boxFit: BoxFit.fitWidth, img: realImg, shadow: false),
          RepaintBoundary(
            child: Container(
              padding: EdgeInsets.only(top: 56.0 + top),
              color: Color.fromARGB(148, 0, 0, 0),
              child: Container(
                height: 130,
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
                                padding: const EdgeInsets.only(
                                    top: 2.0, bottom: 5.0),
                                child: Text(
                                  name ?? '',
                                  style: ts.bigTitle1.copyWith(
                                      color: const Color.fromARGB(
                                          255, 223, 223, 223)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _wrapText('作者：$author'),
                                    _wrapText('类型：$cName'),
                                    _wrapText('状态：$bookStatus'),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 2.0),
                                      child: _wrapText('评分：$scroe分'),
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
    required this.l,
    required this.api,
  }) : super(key: key);

  final SameUserBook l;
  final String? author;
  final ApiType api;
  @override
  Widget build(BuildContext context) {
    final nText = api == ApiType.biquge ? '最新: ' : '';
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
                  bottom: '$nText${l.lastChapter}',
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
