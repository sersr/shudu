import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import 'painter_page.dart';

class BookContentPage extends StatelessWidget {
  // static String route = '/content';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PainterPage(),
      // color: Colors.grey[900],
    );
  }

  static Future push(BuildContext context, int newBookid, int cid, int page) async {
    context.read<PainterBloc>().newBookOrCid(newBookid, cid, page);
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BookContentPage();
    }));
  }
}
