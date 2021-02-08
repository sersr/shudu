import 'package:flutter/material.dart';
import 'dart:io';

class BookListItem extends StatelessWidget {
  const BookListItem({Key? key, this.img, this.name, this.cname, this.author, this.desc, this.score}) : super(key: key);
  final File? img;
  final String? name;
  final String? cname;
  final String? author;
  final String? desc;
  final String? score;
  static final ltsty = TextStyle(fontSize: 11, color: Colors.grey[600]);
  static final mdsty = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static final lgsty = TextStyle(fontWeight: FontWeight.w600);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0),
      child: Row(
        children: [
          Container(
            width: 62,
            margin: EdgeInsets.only(bottom: 5.0),
            child: Stack(
              children: [
                Image.file(
                  img!,
                  fit: BoxFit.fill,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name!,
                            style: lgsty,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${score}分',
                          style: lgsty,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$cname | $author',
                          style: mdsty,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      desc!,
                      style: ltsty,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
