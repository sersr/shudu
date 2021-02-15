import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shudu/pages/embed/images.dart';

import '../../bloc/bloc.dart';
import '../../bloc/book_cache_bloc.dart';
import '../../bloc/book_info_bloc.dart';
import '../../data/book_info.dart';
import '../../utils/utils.dart';
import '../book_content_view/content_main.dart';
import '../embed/indexs.dart';
// import '../embed/indexs.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({Key? key, this.bookid, this.cid, this.page}) : super(key: key);
  static final currentRoute = '/bookinfo';
  final int? bookid;
  final int? cid;
  final int? page;
  @override
  _BookInfoPageState createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  ValueNotifier<bool> showIndexs = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      appBar: AppBar(
        title: Text('Book Info Page'),
      ),
      body: DefaultTextStyle(
        style: TextStyle(fontFamily: 'NotoSansSC', fontSize: 14, color: Colors.grey[800]),
        child: BlocBuilder<BookInfoBloc, BookInfoState>(
          builder: (context, state) {
            final ts = BlocProvider.of<TextStylesBloc>(context);
            if (state is BookInfoStateWithoutData) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BookInfoStateWithData) {
              if (state.data!.data == null) {
                return Center(
                  child: btn1(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    bgColor: Colors.blue,
                    splashColor: Colors.blue[200],
                    radius: 40,
                    child: Text(
                      '重新加载',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      BlocProvider.of<BookInfoBloc>(context).add(BookInfoReloadEvent());
                    },
                  ),
                );
              }
              var children = <Widget>[];
              final info = state.data!.data!;
              children.add(header(
                  info.author, info.bookStatus, info.name, info.bookVote!, info.cName, info.desc, info.img, ts.state));
              children.addAll(desc(info, ts.state));
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return children[index];
                          },
                          itemCount: children.length,
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
                            for (var l in cState.custom) {
                              if (l.id == bookid) {
                                contain = true;
                                cid = l.chapterId;
                                currentPage = l.page;
                                break;
                              }
                            }

                            if (!contain) {
                              for (var l in cState.isTop) {
                                if (l.id == bookid) {
                                  contain = true;
                                  cid = l.chapterId;
                                  currentPage = l.page;
                                  break;
                                }
                              }
                            }
                            final eh = math.max(ui.window.padding.bottom / ui.window.devicePixelRatio / 3, 0.0);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: btn1(
                                    child: Container(
                                      height: 56 + eh,
                                      padding: EdgeInsets.only(bottom: eh),
                                      child: Center(
                                        child: Text('${contain ? '阅读' : '试读'}'),
                                      ),
                                    ),
                                    onTap: () {
                                      final data = state.data!.data;
                                      final _cid = cid ?? data!.firstChapterId!;
                                      final page = currentPage ?? 1;
                                      context.read<PainterBloc>()
                                        ..add(PainterNewBookIdEvent(bookid, _cid, page))
                                        ..canLoad = Completer<void>();
                                      Navigator.of(context).pushNamed(BookContentPage.currentRoute);
                                    },
                                    background: false,
                                  ),
                                ),
                                Expanded(
                                    child: btn1(
                                        background: false,
                                        onTap: () {
                                          if (contain) {
                                            context.read<BookCacheBloc>()
                                              ..add(BookChapterIdDeleteEvent(id: bookid))
                                              ..add(BookChapterIdLoadEvent());
                                            context.read<BookCacheBloc>().add(BookChapterIdLoadEvent());
                                          } else {
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
                                            );
                                            context
                                                .read<BookCacheBloc>()
                                                .add(BookChapterIdAddEvent(bookCache: addCache));
                                          }
                                        },
                                        child: Container(
                                            height: 56 + eh,
                                            padding: EdgeInsets.only(bottom: eh),
                                            child: Center(child: Text('${contain ? '移除' : '添加到'}书架'))))),
                                Expanded(
                                  child: btn1(
                                    child: Container(
                                        height: 56 + eh,
                                        padding: EdgeInsets.only(bottom: eh),
                                        child: Center(child: Text('action'))),
                                    onTap: () {},
                                    background: false,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: AnimatedBuilder(
                      animation: showIndexs,
                      builder: (context, child) {
                        if (showIndexs.value) {
                          return background(
                            child: IndexsWidget(
                              onTap: (context, id, cid) {
                                context.read<PainterBloc>()..add(PainterNewBookIdEvent(id, cid, 1));
                                Navigator.of(context).pushNamed(BookContentPage.currentRoute);
                                showIndexs.value = !showIndexs.value;
                                context.read<BookIndexBloc>().add(BookIndexShowEvent(id: id, cid: cid));
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
        ),
      ),
    );
    return WillPopScope(
        child: child,
        onWillPop: () async {
          if (widget.bookid != null && widget.cid != null && widget.page != null) {
            context.read<PainterBloc>()
              ..canLoad = Completer<void>()
              ..add(PainterNewBookIdEvent(widget.bookid!, widget.cid!, widget.page!));

            // Navigator.of(context).pushNamed(BookContentPage.currentRoute);
          }
          // final bloc = BlocProvider.of<PainterBloc>(context);
          return true;
        });
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
              bottom: 66 + math.max(ui.window.padding.bottom / ui.window.devicePixelRatio / 3, 0.0),
              child: Material(
                borderRadius: BorderRadius.circular(6.0),
                color: Color.fromRGBO(210, 210, 210, 1),
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.grey[800], fontSize: 16, fontFamily: 'NotoSansSC', height: 1.0),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  var hide = true;
  Iterable<Widget> desc(BookInfo info, TextStylesState tsState) sync* {
    yield Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('简介', style: tsState.bold1),
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
                      style: tsState.body1,
                    ),
                    Center(
                        child: Icon(
                      hide ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
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
      child: BlocBuilder<BookCacheBloc, BookChapterIdState>(
        builder: (context, cState) {
          final bookid = info.id;
          var contained = false;
          int? cid;
          cState.custom.forEach((element) {
            if (element.id == bookid) {
              contained = true;
              cid = element.chapterId;
            }
          });
          if (!contained) {
            cState.isTop.forEach((element) {
              if (element.id == bookid) {
                contained = true;
                cid = element.chapterId;
              }
            });
          }
          return btn1(
            onTap: () {
              if (contained) {
                context.read<BookIndexBloc>().add(BookIndexShowEvent(id: bookid, cid: cid));
              } else {
                context.read<BookIndexBloc>().add(BookIndexShowEvent(id: info.id, cid: info.firstChapterId));
              }
              showIndexs.value = !showIndexs.value;
            },
            radius: 0,
            bgColor: Colors.grey[200],
            splashColor: Colors.grey[300],
            padding: const EdgeInsets.all(0.0),
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
                            style: tsState.bold1,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                info.lastTime!,
                                softWrap: false,
                                style: tsState.body3,
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
                          style: tsState.body2,
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
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
    );
    yield Container(
      color: Colors.grey[200],
      margin: const EdgeInsets.only(top: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Text('${info.author} 还写过'),
              ],
            ),
          ),
          for (var l in info.sameUserBooks!) BookInfoSameItemWidget(l: l, author: info.author),
        ],
      ),
    );
  }

  Widget header(String? author, String? bookStatus, String? name, BookVote bookvote, String? cName, String? desc,
      String? img, TextStylesState tsState) {
    return Container(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 16.0),
      child: Container(
        height: 130,
        child: Row(
          children: [
            Container(
              child: ImageResolve(
                img: img,
              ),
              height: 130,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 12.0),
                child: DefaultTextStyle(
                  style: tsState.body1!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                        child: Text(
                          '$name',
                          style: tsState.title,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                padding: const EdgeInsets.only(bottom: 2.0),
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
        ),
      ),
    );
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
      decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 1, color: Colors.grey[300]!))),
      child: btn1(
        radius: 0,
        bgColor: Colors.grey[100],
        splashColor: Colors.grey[300],
        padding: const EdgeInsets.all(0.0),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return BlocProvider(
              create: (context) => BookInfoBloc(context.read<BookRepository>()),
              child: Builder(builder: (context) {
                BlocProvider.of<BookInfoBloc>(context).add(BookInfoEventSentWithId(l.id!));
                return BookInfoPage();
              }),
            );
          }));
        },
        child: Row(children: [
          Container(
            width: 72,
            child: ImageResolve(img: l.img, width: 72),
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
                        style: ts.state.title,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '作者：${author}',
                      style: ts.state.body1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '最新: ${l.lastChapter}',
                        softWrap: false,
                        style: ts.state.body3,
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
