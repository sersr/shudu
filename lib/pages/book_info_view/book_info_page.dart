import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../data/book_info.dart';
import '../../database/table.dart';
import '../../event/event.dart';
import '../../utils/utils.dart';
import '../book_content_view/book_content_page.dart';
import '../embed/images.dart';
import '../embed/indexs.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({Key? key}) : super(key: key);

  @override
  _BookInfoPageState createState() => _BookInfoPageState();

  static Future push(BuildContext context, int bookid) async {
    BlocProvider.of<BookInfoBloc>(context).add(BookInfoEventSentWithId(bookid));
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return wrapData(BookInfoPage());
    }));
  }
}

class _BookInfoPageState extends State<BookInfoPage> {
  ValueNotifier<bool> showIndexs = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final child = Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('书籍详情'),
        ),
        body: BlocBuilder<BookInfoBloc, BookInfoState>(
          builder: (context, state) {
            final ts = BlocProvider.of<TextStylesBloc>(context);
            if (state is BookInfoStateWithoutData) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BookInfoStateWithData) {
              if (state.data!.data == null) {
                return Center(
                  child: btn1(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    bgColor: Colors.blue,
                    splashColor: Colors.blue[200],
                    radius: 40,
                    child: Text(
                      '重新加载',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      BlocProvider.of<BookInfoBloc>(context)
                          .add(BookInfoReloadEvent());
                    },
                  ),
                );
              }
              var children = <Widget>[];
              final info = state.data!.data!;

              children.add(header(info.author, info.bookStatus, info.name,
                  info.bookVote!, info.cName, info.desc, info.img, ts));

              children.addAll(desc(info, ts));
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Color.fromARGB(255, 242, 242, 242),
                          child: ListView.builder(
                            physics: ClampingScrollPhysicsNew(),
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
                        child: BlocBuilder<BookCacheBloc, BookChapterIdState>(
                          builder: (context, cState) {
                            final bookid = state.data!.data!.id!;
                            var contain = false;
                            int? cid;
                            int? currentPage;
                            var added = false;
                            for (var l in cState.sortChildren) {
                              if (l.id == bookid) {
                                added = true;
                                if (l.isShow == 0) break;
                                contain = true;
                                cid = l.chapterId;
                                currentPage = l.page;
                                break;
                              }
                            }
                            if (!added) {
                              var addCache = BookCache(
                                name: info.name,
                                img: info.img,
                                updateTime: info.lastTime,
                                lastChapter: info.lastChapter,
                                chapterId: info.firstChapterId,
                                id: info.id,
                                sortKey: DateTime.now().millisecondsSinceEpoch,
                                isTop: 0,
                                page: 1,
                                isNew: 1,
                                isShow: 0,
                              );
                              Provider.of<BookCacheBloc>(context)
                                  .repository
                                  .bookEvent
                                  .bookInfoEvent
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: btn1(
                                      child: Container(
                                        height: 56,
                                        child: Center(
                                          child:
                                              Text('${contain ? '阅读' : '试读'}'),
                                        ),
                                      ),
                                      onTap: () {
                                        final data = state.data!.data;
                                        final _cid =
                                            cid ?? data!.firstChapterId!;
                                        final page = currentPage ?? 1;
                                        BookContentPage.push(
                                            context, bookid, _cid, page);
                                      },
                                      background: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: btn1(
                                      background: false,
                                      onTap: () {
                                        if (contain) {
                                          context
                                              .read<BookCacheBloc>()
                                              .deleteBook(bookid);
                                        } else {
                                          context
                                              .read<BookCacheBloc>()
                                              .updateTop(info.id!, 0);
                                        }
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
                                context
                                    .read<BookIndexBloc>()
                                    .add(BookIndexShowEvent(id: id, cid: cid));
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
            }
            return Container();
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
  Iterable<Widget> desc(BookInfo info, TextStylesBloc ts) sync* {
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
                    Text(
                      info.desc!,
                      maxLines: hide ? 2 : null,
                      overflow: TextOverflow.fade,
                      style: ts.body3,
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
      child: BlocBuilder<BookCacheBloc, BookChapterIdState>(
        builder: (context, cState) {
          final bookid = info.id;
          var contained = false;
          int? cid;
          cState.sortChildren.forEach((element) {
            if (element.id == bookid) {
              contained = true;
              cid = element.chapterId;
            }
          });

          return btn1(
            onTap: () {
              if (contained) {
                context
                    .read<BookIndexBloc>()
                    .add(BookIndexShowEvent(id: bookid, cid: cid));
              } else {
                context.read<BookIndexBloc>().add(
                    BookIndexShowEvent(id: info.id, cid: info.firstChapterId));
              }
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
                          info.lastChapter!,
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
    // yield Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
    //   child:
    yield Container(
      color: Color.fromARGB(255, 250, 250, 250),
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Text('${info.author} 还写过'),
    );
    for (var l in info.sameUserBooks!)
      yield BookInfoSameItemWidget(l: l, author: info.author);
    // );
  }

  Widget header(
      String? author,
      String? bookStatus,
      String? name,
      BookVote bookvote,
      String? cName,
      String? desc,
      String? img,
      TextStylesBloc ts) {
    return Container(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: RepaintBoundary(
          child: Container(
              height: 130,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              color: Color.fromARGB(255, 250, 250, 250),
              child: Row(
                children: [
                  Container(height: 130, child: ImageResolve(img: img)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: DefaultTextStyle(
                        style: ts.body2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 5.0),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '作者：$author',
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    Text(
                                      '类型：$cName',
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    Text(
                                      '状态：$bookStatus',
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        '评分：${bookvote.scroe}分',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
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
              )),
        ));
    // );
  }
}

class BookInfoSameItemWidget extends StatelessWidget {
  const BookInfoSameItemWidget({
    Key? key,
    required this.author,
    required this.l,
  }) : super(key: key);

  final SameUserBook l;
  final String? author;
  @override
  Widget build(BuildContext context) {
    final ts = BlocProvider.of<TextStylesBloc>(context);
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return BlocProvider(
              create: (context) => BookInfoBloc(context.read<Repository>()),
              child: Builder(builder: (context) {
                BlocProvider.of<BookInfoBloc>(context)
                    .add(BookInfoEventSentWithId(l.id!));
                return wrapData(BookInfoPage());
              }),
            );
          }));
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
              child: Container(
                height: 108,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${l.name}',
                        style: ts.title3,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '作者：$author',
                      style: ts.body2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '最新: ${l.lastChapter}',
                        softWrap: false,
                        style: ts.body3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
