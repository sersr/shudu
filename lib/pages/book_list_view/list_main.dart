import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../utils/utils.dart';
import 'list_bandan.dart';
import 'list_category.dart';
import 'list_shudan.dart';

class ListMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: btn1(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(child: Text('书单')),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                      create: (context) => ShudanBloc(context.read<BookRepository>()),
                      child: ListShudanPage(),
                    );
                  }));
                }),
          ),
          Expanded(
            child: btn1(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Center(
                    child: Text('分类'),
                  ),
                ),
                // bgColor: Color.fromRGBO(222, 222, 222, 1),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return ListCatetoryPage();
                  }));
                }),
          ),
          Expanded(
            child: btn1(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Center(child: Text('榜单')),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return ListBangdanPage();
                  }));
                }),
          ),
        ],
      )
    ]);
  }
}
