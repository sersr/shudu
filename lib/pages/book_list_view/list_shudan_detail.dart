import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../data/book_list_detail.dart';
import '../../event/event.dart';
import '../../utils/utils.dart';
import '../book_info_view/book_info_page.dart';
import '../embed/images.dart';

class ShudanDetailPage extends StatefulWidget {
  const ShudanDetailPage({Key? key, this.total}) : super(key: key);
  final int? total;

  @override
  _ShudanDetailPageState createState() => _ShudanDetailPageState();
}

class _ShudanDetailPageState extends State<ShudanDetailPage> {
  @override
  Widget build(BuildContext context) {
    final ts = BlocProvider.of<TextStylesBloc>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('书单详情'),
      ),
      body: BlocBuilder<ShudanListDetailBloc, ShudanListDetailState>(
        builder: (context, state) {
          if (state is ShudanListDetailFailed) {
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
                  BlocProvider.of<ShudanListDetailBloc>(context)
                      .add(ShudanListDetailReLoadEvent());
                },
              ),
            );
          }
          if (state.data?.listId != null) {
            List<Widget> _getChildren() {
              return [
                // header
                Container(
                  height: 120,
                  color: Color.fromARGB(255, 250, 250, 250),
                  padding: const EdgeInsets.only(
                      top: 12.0, bottom: 12.0, left: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        // width: 112,
                        height: 120,
                        child: ImageResolve(
                          img: state.data!.cover
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Text('${state.data!.title}',
                                    maxLines: 2, style: ts.title2),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child:
                                    Text('共${widget.total}本书', style: ts.body2),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Text('${state.data!.updateTime}',
                                    style: ts.body3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // intro
                buildIntro(ts, state.data!.description),
                // IntroWidget(description: state.data!.description),
                // body
                SizedBox(height: 10),

                Container(
                  color: Color.fromARGB(255, 250, 250, 250),
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 10.0),
                  child: Row(
                    children: [
                      Text('书单列表', style: ts.title2),
                    ],
                  ),
                ),
                for (var l in state.data!.bookList!)
                  ShudanListDetailItemWidget(l: l)
              ];
            }

            final children = _getChildren();
            return Container(
              color: Color.fromARGB(255, 242, 242, 242),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12.0),
                itemBuilder: (context, index) {
                  return children[index];
                },
                itemCount: children.length,
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  var hide = ValueNotifier(true);

  Widget buildIntro(TextStylesBloc ts, String? description) {
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
                        Text.rich(
                          TextSpan(
                            text: '$description',
                          ),
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
    final ts = BlocProvider.of<TextStylesBloc>(context);
    return Container(
      height: 108,
      decoration: BoxDecoration(
          border: BorderDirectional(
              bottom: BorderSide(
                  width: 1 / MediaQuery.of(context).devicePixelRatio,
                  color: Color.fromRGBO(210, 210, 210, 1)))),
      child: btn1(
        radius: 0,
        bgColor: Color.fromARGB(255, 250, 250, 250),
        splashColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        onTap: () {
          BookInfoPage.push(context, l.bookId!);
        },
        child: Row(children: [
          Container(
            width: 72,
            height: 108,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ImageResolve(img: l.bookIamge),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l.bookName}',
                          style: ts.title3,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${l.score}分',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.yellow[700]),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      '${l.categoryName} | ${l.author}',
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                      style:
                          ts.body1.copyWith(color: TextStylesBloc.blackColor6),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      '${l.description}',
                      style: ts.body3,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(bottom: .0),
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child:
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

abstract class ShudanListDetailEvent extends Equatable {
  const ShudanListDetailEvent();
  @override
  List<Object> get props => [];
}

class ShudanListDetailLoadEvent extends ShudanListDetailEvent {
  ShudanListDetailLoadEvent(this.index);
  final int? index;
}

class ShudanListDetailReLoadEvent extends ShudanListDetailEvent {}

class ShudanListDetailState {
  ShudanListDetailState([this.data]);
  final BookListDetailData? data;
}

class ShudanListDetailFailed extends ShudanListDetailState {}

class ShudanListDetailBloc
    extends Bloc<ShudanListDetailEvent, ShudanListDetailState> {
  ShudanListDetailBloc(this.repository) : super(ShudanListDetailState());

  final Repository repository;
  int? lastIndex;
  @override
  Stream<ShudanListDetailState> mapEventToState(
      ShudanListDetailEvent event) async* {
    if (event is ShudanListDetailLoadEvent) {
      lastIndex = event.index;
      yield* load(lastIndex);
    } else if (event is ShudanListDetailReLoadEvent) {
      yield* load(lastIndex);
    }
  }

  Stream<ShudanListDetailState> load(int? index) async* {
    if (index == null) return;
    final data =
        await repository.bookEvent.customEvent.getShudanDetail(index) ??
            const BookListDetailData();
    if (data.listId != null) {
      await Future.delayed(Duration(milliseconds: 300));
      yield ShudanListDetailState(data);
    } else {
      yield ShudanListDetailFailed();
    }
  }
}
