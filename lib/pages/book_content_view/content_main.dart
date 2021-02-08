import 'package:flutter/material.dart';
import 'context_view.dart';

class BookContentPage extends StatelessWidget {
  static String currentRoute = '/content';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PainterPage(),
      // color: Colors.grey[900],
    );
  }
}
