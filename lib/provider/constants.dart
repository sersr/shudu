import 'package:flutter/foundation.dart';

// 小标题和底部字体大小
const contentFontSize = 13.0;

// 顶部与章节小标题之间的高度
const contentTopPad = 8.0;

// 中间文本与两端之间的间隔高度
const contentPadding = 10.0;

// 底部(显示页数)与下边界的间隔
final contentBotttomPad =
    defaultTargetPlatform == TargetPlatform.iOS ? 12.0 : 8.0;

// 其他所有占用,除了中间文本视图占用
final contentWhiteHeight = contentPadding * 2 +
    contentTopPad +
    contentBotttomPad +
    contentFontSize * 2;

final regexpEmpty = RegExp('[ \u3000]+');
