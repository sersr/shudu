import 'package:flutter/material.dart';
import 'context_view.dart';

class BookContentPage extends StatelessWidget {
  static String currentRoute = '/content';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removePadding(
        context: context,
        child: PainterPage(),
        removeTop: true,
        removeBottom: true,
      ),
      // color: Colors.grey[900],
    );
  }
}
