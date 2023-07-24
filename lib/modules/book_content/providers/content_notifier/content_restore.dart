import 'dart:async';

import 'package:nop/event_queue.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../import.dart';
import 'content_base.dart';
import 'content_config.dart';
import 'content_status.dart';

/// 保存当前状态一个副本,可以根据这个副本恢复状态
mixin ContentRestore on ContentDataBase, ContentStatus, Configs {
  SaveStateData saveStateOnOut() {
    dump();
    out();
    setOrientation(true);
    uiOverlay(hide: false);
    return SaveStateData(bookId, tData.cid!, currentPage, tData.api);
  }

  SaveStateData get saveData =>
      SaveStateData(bookId, tData.cid!, currentPage, tData.api);

  @override
  FutureOr<void> onOut() async {
    await EventQueue.getQueueRunner(restoreState);
    return super.onOut();
  }

  void restoreState([FutureOr<SaveStateData> Function()? callback]) {
    if (callback != null) {
      EventQueue.run(restoreState, () async {
        final data = await callback();
        setInBook();
        // resetController();
        if (shouldUpdate(data.saveBookId, data.saveCid, api)) {
          newBookOrCid(data.saveBookId, data.saveCid, data.savePage,
              api: data.saveApi);
        } else {
          resetController();
          notifyListeners();
        }
        final isPortrait = config.value.orientation!;

        uiOverlay(hide: !uiOverlayShow || !isPortrait);
        setOrientation(isPortrait);
        uiStyle(dark: true);
      });
    }
  }
}

class SaveStateData {
  SaveStateData(this.saveBookId, this.saveCid, this.savePage, this.saveApi);
  final int saveBookId;
  final int saveCid;
  final int savePage;
  final ApiType saveApi;
  SaveStateData copyWith({int? bookId, int? cid, int? page, ApiType? api}) {
    return SaveStateData(
        bookId ?? saveBookId, cid ?? saveCid, page ?? savePage, api ?? saveApi);
  }

  static dynamic fromJson(Object? data) {
    if (data is! Map) return data;
    final saveBookId = data['saveBookId'];
    final saveCid = data['saveCid'];
    final savePage = data['savePage'];
    return SaveStateData(saveBookId, saveCid, savePage, ApiType.biquge);
  }

  Map<String, dynamic> toJson() {
    return {
      'saveBookId': saveBookId,
      'saveCid': saveCid,
      'savePage': savePage,
    };
  }
}
