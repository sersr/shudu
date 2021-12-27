import 'dart:async';

import 'package:flutter/material.dart';
import 'package:useful_tools/useful_tools.dart';

import 'content_base.dart';
import 'content_cache.dart';

mixin ContentTasks on ContentDataBase, ContentLoad {
  // 所有异步任务
  final futures = <int, Future>{};

  // 记录重新下载的id，并延迟删除
  final reloadIds = <int>{};

  Future? awaitKey(int key) {
    return futures.awaitKey(key);
  }

  void loadTasks(int _bookid, int? contentid) {
    if (!inBook) return;

    if (_bookid == bookid &&
        _bookid != -1 &&
        contentid != null &&
        contentid != -1 &&
        !containsKeyText(contentid) &&
        !futures.isLoading(contentid)) {
      futures.addTask(contentid, load(_bookid, contentid),
          callback: applyConentDimension);
    }
  }

  Future<void>? taskRunner() {
    return EventQueue.getQueueRunner(this);
  }

  bool _scheduled = false;

  void scheduleTask() {
    if (_scheduled || !inBook) return;
    Timer(const Duration(milliseconds: 200), () {
      _scheduled = false;
      if (initQueue.actived) return;
      loadResolve();
      _loadAuto();
    });
    _scheduled = true;
  }

  void _loadAuto() {
    getCurrentIds().where((e) => !containsKeyText(e)).forEach(_loadWithId);
  }

  void _loadWithId(int? id) => loadTasks(bookid, id);
  bool canReload(int id) => !reloadIds.contains(id);
  bool _autoAddReloadIds(int contentId) {
    if (reloadIds.contains(contentId)) return true;
    assert(Log.w('nid = ${tData.nid}, hasContent: ${tData.hasContent}'));

    reloadIds.add(contentId);

    Timer(Duration(seconds: tData.hasContent ? 30 : 10),
        () => reloadIds.remove(contentId));
    return false;
  }

  // 处于最后一章节时，查看是否有更新
  Future<void> loadResolve() async {
    final updateCid = tData.cid;
    if (updateCid == null || initQueue.actived || !canReload(updateCid)) return;
    final updateNid = tData.nid == -1;
    final updateContent = !tData.hasContent;
    if (updateNid || updateContent) {
      Log.w('resolve $updateCid', onlyDebug: false);
      bool _getdata() {
        if (containsKeyText(updateCid) && tData.cid == updateCid) {
          if (tData.contentIsNotEmpty &&
              (currentPage == tData.content.length || currentPage == 1)) {
            final tData = getTextData(updateCid)!;
            if ((updateNid && tData.nid != -1) ||
                (updateContent && tData.hasContent)) {
              startFirstEvent(only: false);
              return true;
            }
          }
        }
        return false;
      }

      await releaseUI;
      if (_getdata()) return;

      if (_autoAddReloadIds(updateCid)) return;
      if ((currentPage == tData.content.length || currentPage == 1)) {
        await load(bookid, updateCid, update: true);
        _getdata();
      }
    }
  }

  // 立即
  Future<void> resolveId() async {
    if (tData.contentIsEmpty) return;
    var _data = getTextData(tData.cid);
    if (_data != null && (!_data.hasContent || _data.nid == -1)) {
      await _reloadId();
    }
  }

  Future<void> _reloadId() async {
    await load(bookid, tData.cid!, update: true);
    final _data = getTextData(tData.cid);
    if (_data != null && _data.contentIsNotEmpty) {
      tData = _data;
    }
    if (currentPage > tData.content.length) {
      currentPage = tData.content.length;
    }
    notify();
  }

  final header = ValueNotifier<String>('');
  final footer = ValueNotifier<String>('');
  Future<bool> getContent(int getid) async {
    var _data = getTextData(getid);
    if (_data == null || _data.contentIsEmpty) {
      _loadAuto();

      await futures.awaitKey(getid);

      _data = getTextData(getid);
      if (_data == null || _data.contentIsEmpty) return false;
    }

    tData = _data;
    currentPage = 1;

    if (config.value.axis == Axis.vertical) {
      final footv = '$currentPage/${tData.content.length}页';
      scheduleMicrotask(() {
        if (config.value.axis != Axis.vertical) return;
        footer.value = footv;
        header.value = tData.cname!;
      });
    }

    resetController();
    notify();
    return true;
  }
}

extension<T, E> on Map<T, Future<E>> {
  // 将一个异步任务添加到任务列表中，并在完成之后自动删除
  void addTask(
    T key,
    Future<E> f, {
    void Function()? callback,
    void Function(T)? solve,
    void Function(Future<E>)? solveTask,
  }) {
    assert(Log.i('addTask: $key'));
    assert(!containsKey(key));
    this[key] = f;

    f.whenComplete(() {
      assert(Log.i('task $key: completed'));
      solve?.call(key);
      solveTask?.call(f);
      callback?.call();
      remove(key);
    });
  }

  Future<E>? awaitKey(T? key) => this[key];

  bool isLoading(T? key) => containsKey(key);
}
