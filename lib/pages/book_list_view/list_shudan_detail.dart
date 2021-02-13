import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shudu/pages/embed/images.dart';

import '../../bloc/bloc.dart';
import '../../data/book_list_detail.dart';
import '../../utils/utils.dart';
import '../book_info_view/book_info_page.dart';

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
          if (state.data != null) {
            List<Widget> _getChildren() {
              return [
                // header
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        child: ImageResolve(
                          img: state.data!.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                                child: Text('${state.data!.title}', maxLines: 2, style: ts.state.title),
                              ),
                              Expanded(
                                child: Text('共${widget.total}本书', style: ts.state.body1),
                              ),
                              Expanded(
                                child: Text('${state.data!.updateTime}', style: ts.state.body3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // intro
                IntroWidget(description: state.data!.description),
                // body
                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  child: Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                    child: Row(
                      children: [
                        Text('书单列表', style: ts.state.title),
                      ],
                    ),
                  ),
                ),
                for (var l in state.data!.bookList!) ShudanListDetailItemWidget(l: l)
              ];
            }

            final children = _getChildren();
            return ListView.builder(
              itemBuilder: (context, index) {
                return children[index];
              },
              itemCount: children.length,
            );
          } else {
            return Center(child: CupertinoActivityIndicator());
          }
        },
      ),
    );
  }
}

class IntroWidget extends StatefulWidget {
  const IntroWidget({Key? key, this.description}) : super(key: key);
  final String? description;

  @override
  _IntroWidgetState createState() => _IntroWidgetState();
}

class _IntroWidgetState extends State<IntroWidget> {
  var hide = true;
  @override
  Widget build(BuildContext context) {
    final ts = BlocProvider.of<TextStylesBloc>(context);
    return Container(
      padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('简介', style: ts.state.title),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: StatefulBuilder(builder: (context, setstate) {
              return InkWell(
                onTap: () {
                  setstate(() {
                    hide = !hide;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '${widget.description}',
                      ),
                      maxLines: hide ? 2 : null,
                      overflow: TextOverflow.fade,
                      style: ts.state.body1,
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
      decoration: BoxDecoration(
          border: BorderDirectional(
              bottom: BorderSide(
                  width: 1 / MediaQuery.of(context).devicePixelRatio, color: Color.fromRGBO(210, 210, 210, 1)))),
      child: btn1(
        radius: 0,
        bgColor: Colors.grey[100],
        splashColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return BlocProvider(
              create: (context) => BookInfoBloc(context.read<BookRepository>()),
              child: Builder(builder: (context) {
                BlocProvider.of<BookInfoBloc>(context).add(BookInfoEventSentWithId(l.bookId!));
                return BookInfoPage();
              }),
            );
          }));
        },
        child: Row(children: [
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ImageResolve(img: l.bookIamge, width: 72),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l.bookName}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${l.score}分',
                              style: TextStyle(fontSize: 14, color: Colors.yellow[700]),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      '${l.categoryName} | ${l.author}',
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13, color: Colors.grey[900]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${l.description}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
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

class ShudanListDetailState {
  ShudanListDetailState([this.data]);
  final BookListDetailData? data;
}

class ShudanListDetailBloc extends Bloc<ShudanListDetailEvent, ShudanListDetailState> {
  ShudanListDetailBloc(this.repository) : super(ShudanListDetailState());

  final BookRepository repository;
  @override
  Stream<ShudanListDetailState> mapEventToState(ShudanListDetailEvent event) async* {
    if (event is ShudanListDetailLoadEvent) {
      final data = await repository.loadShudanDetail(event.index);
      if (data.listId != null) {
        await Future.delayed(Duration(milliseconds: 300));
        yield ShudanListDetailState(data);
      }
    }
  }
}
