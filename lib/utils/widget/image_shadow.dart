import 'package:flutter/material.dart';

class ImageShadow extends StatelessWidget {
  const ImageShadow({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: const Offset(-4, 2),
              color: Color.fromRGBO(180, 180, 180, 1),
              blurRadius: 2.6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
