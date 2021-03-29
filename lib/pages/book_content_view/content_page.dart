import 'package:flutter/material.dart';
import 'painter_page.dart';

class BookContentPage extends StatelessWidget {
  static String currentRoute = '/content';
  @override
  Widget build(BuildContext context) {
    return Material(
      child: PainterPage(),
      // color: Colors.grey[900],
    );
  }
}
