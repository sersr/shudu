import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ListCatetoryPage extends StatefulWidget {
  @override
  _ListCatetoryPageState createState() => _ListCatetoryPageState();
}

class _ListCatetoryPageState extends State<ListCatetoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('分类')),
        body: Center(
          child: Container(
            // color: Colors.blue,
            child: CarouselSlider.builder(
              // items: [Text('hell0'), Text('finfw')],
              itemBuilder: (context, ida, index) {
                print(index);
                return Container(
                  color: Colors.cyan,
                  child: Center(child: Text('hfllf $ida,$index')),
                );
              },
              itemCount: 10,
              options: CarouselOptions(),
            ),
          ),
        ));
  }
}
