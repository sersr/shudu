// import 'dart:developer';

// import 'package:characters/characters.dart';
// import 'dart:math' as math;

// final a1 = 0xFF01;
// final a2 = 0xFF0F;
// final b1 = 0xFF1A;
// final b2 = 0xFF20;
// final c1 = 0xFF3B;
// final c2 = 0xFF40;
// final d1 = 0xFF5B;
// final d2 = 0xFF65;
// final e1 = 0x3000;
// final e2 = 0x303F;
// final f1 = 0x0021;
// final f2 = 0x002F;
// final g1 = 0x005B;
// final g2 = 0x0060;
// final h1 = 0x007B;
// final h2 = 0x007E;
// final li = [
//   8211,
//   8212,
//   8216,
//   8217,
//   8220,
//   8221,
//   8230,
//   12289,
//   12290,
//   12296,
//   12297,
//   12298,
//   12299,
//   12300,
//   12301,
//   12302,
//   12303,
//   12304,
//   12305,
//   12308,
//   12309,
//   65281,
//   65288,
//   65289,
//   65292,
//   65294,
//   65306,
//   65307,
//   65311
// ];

// bool breakPoint(int index) =>
//     (index >= a1 && index <= a2) ||
//     (index >= b1 && index <= b2) ||
//     (index >= c1 && index <= c2) ||
//     (index >= d1 && index <= d2) ||
//     (index >= e1 && index <= e2) ||
//     li.contains(index);

// final i1 = 0x0020;
// final i2 = 0x002F;
// final i3 = 0x003A;
// final i4 = 0x007A;
// final j1 = 0xFF61;
// final j2 = 0xFFDC;
// final k1 = 0xFFE8;
// final k2 = 0xFFED;

// double halfPoint(int index) {
//   if (index > i2 && index < i3) {
//     return 0.49;
//   } else if ((index >= i1 && index <= i4) ||
//       (index >= j1 && index <= j2) ||
//       (index >= k1 && index <= k2)) {
//     return 1;
//   }
//   return 0.0;
// }

// 其他方法都达不到理想要求
//
// 分段返回
List<String> divText(String text, String cname) {
  final _pages = <String>[];
  if (text.isEmpty) return _pages;
  return text.split('\n')..removeWhere((element) => element.isEmpty);

  // for (var p = 0; p < lm.length; p++) {
  //   if (lm[p].isNotEmpty) {
  //     final pc = lm[p].characters;
  //     final _characters = pc.length;
  //     var lastCursor = 0;
  //     var cursor = 0;
  //     while (true) {
  //       var lastEnd = cursor;
  //       // lastEnd - lastCursor >= words &&
  //       if (cursor < _characters) {
  //         // next
  //         while (true) {
  //           final _end = pc.elementAt(lastEnd.clamp(math.min(lastEnd, _characters - 1), _characters - 1));
  //           final point = _end.codeUnits;
  //           print('aaaaa Point $lastEnd, $_characters  $_end  ${breakPoint(point.first)}   $point');
  //           if (lastCursor >= lastEnd - 1) break;
  //           if (!breakPoint(point.first)) break;
  //           lastEnd--;
  //         }
  //       }
  //       if (lastCursor < lastEnd) {
  //         final l = pc.getRange(lastCursor, lastEnd.clamp(math.min(lastEnd, _characters), _characters));
  //         // print(l);
  //         _pages.add(l.toString());
  //       }

  //       if (lastEnd >= _characters) {
  //         break;
  //       }

  //       var end = lastEnd + words;
  //       end = end.clamp(math.min(end, _characters), _characters);
  //       // var end = lastEnd + words;
  //       var add = 0.0;
  //       // var isEnd = false;
  //       // while (add < words * 2) {
  //       //   if (point >= _characters - 1) {
  //       //     isEnd = true;
  //       //     break;
  //       //   }
  //       //   add += getWidth(pc.elementAt(point).codeUnits.first);
  //       //   point++;
  //       // }
  //       for (var i = cursor; i <= end - 1; i++) {
  //         // print('add ${pc.elementAt(i)},${pc.elementAt(i).codeUnits.first}');
  //         add += halfPoint(pc.elementAt(i).codeUnits.first);
  //       }

  //       lastCursor = lastEnd;
  //       cursor = end + add ~/ 2;
  //       print('${pc.getRange(lastEnd, cursor.clamp(0, _characters))} add $add');

  //       // print('add $add');
  //       // if (isEnd) {
  //       //   cursor = _characters;
  //       //   print('${pc.getRange(lastEnd, _characters)}, isEnd: $isEnd');
  //       // } else {
  //       //   print('${pc.getRange(lastEnd, (lastEnd + add.toInt() ~/ 2).clamp(0, _characters - 1))}');
  //       //   cursor = lastEnd + add.toInt() ~/ 2;
  //       // }
  //     }
  //   }
  // }
  // return _pages;
}

// var widths = {
//   126: 1,
//   159: 0,
//   687: 1,
//   710: 0,
//   711: 1,
//   727: 0,
//   733: 1,
//   879: 0,
//   1154: 1,
//   1161: 0,
//   4347: 1,
//   4447: 2,
//   7467: 1,
//   7521: 0,
//   8369: 1,
//   8426: 0,
//   9000: 1,
//   9002: 2,
//   11021: 1,
//   12350: 2,
//   12351: 1,
//   12438: 2,
//   12442: 0,
//   19893: 2,
//   19967: 1,
//   55203: 2,
//   63743: 1,
//   64106: 2,
//   65039: 1,
//   65059: 0,
//   65131: 2,
//   65279: 1,
//   65376: 2,
//   65500: 1,
//   65510: 2,
//   120831: 1,
//   262141: 2,
//   1114109: 1,
// };

// int getWidth(int index) {
//   if (index == 0xe || index == 0xF) {
//     return 0;
//   }
//   for (final i in widths.keys) {
//     if (index <= i) return widths[i]!;
//   }
//   return 1;
// }
