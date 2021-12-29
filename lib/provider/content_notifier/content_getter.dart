import 'dart:async';

import 'package:flutter/Material.dart';

import '../text_data.dart';
import 'content_base.dart';
import 'content_task.dart';

mixin ContentGetter on ContentDataBase, ContentTasks {


  void getContentDimension() {
    scheduleTask();
    applyContentDimension(force: false);
  }

  // 首先确定当前章节首页位置
  // 再根据当前页面实际位置判断位于哪一个章节，和此章节的哪一页
  ContentMetrics? getContentMes(int page, {bool changeState = false}) {
    if (changeState && page == innerIndex) return null;
    var currentContentFirstIndex = innerIndex - currentPage + 1;
    var text = tData;
    ContentMetrics? child;

    while (text.contentIsNotEmpty) {
      // 当前章节页
      final contentIndex = page - currentContentFirstIndex;

      final length = text.content.length;

      if (contentIndex >= 0 && contentIndex <= length - 1) {
        final _currentPage = contentIndex + 1;

        // 滑动过半才会进行判定 [currentPage]
        if (changeState) {
          assert(controller == null || controller!.page.round() == page);

          setInnerIndex(page);
          currentPage = _currentPage;
          tData = text;
          dump();
          scheduleTask();
          if (config.value.axis == Axis.vertical) {
            final footv = '$currentPage/${text.content.length}页';
            scheduleMicrotask(() {
              if (config.value.axis != Axis.vertical) return;
              footer.value = footv;
              header.value = text.cname!;
            });
          }
          return null;
        } else {
          child = text.content[_currentPage - 1];
        }
        break;
      } else if (contentIndex < 0) {
        if (containsKeyText(text.pid)) {
          text = getTextData(text.pid!)!;
          currentContentFirstIndex -= text.content.length;
        } else {
          break;
        }
      } else if (contentIndex >= length) {
        if (containsKeyText(text.nid)) {
          currentContentFirstIndex += length;
          text = getTextData(text.nid!)!;
        } else {
          break;
        }
      }
    }

    return child;
  }
}
