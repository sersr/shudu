import 'package:flutter/foundation.dart';

const contentFooterSize = 13.0;
const contentTopPad = 8.0;
const contentPadding = 10.0;
final contentBotttomPad =
    defaultTargetPlatform == TargetPlatform.iOS ? 8.0 : 12.0;

final contentWhiteHeight = contentPadding * 2 +
    contentTopPad +
    contentBotttomPad +
    contentFooterSize * 2;

final regexpEmpty = RegExp('[ \u3000]+');
