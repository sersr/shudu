// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:file/local.dart';
import 'package:process/process.dart';
import 'package:args/args.dart';

void main(args) async {
  final parser = ArgParser();
  parser.addOption('path');
  final result = parser.parse(args);
  final name = result['path'];
  var fs = const LocalFileSystem();
  final projectDir = name == null
      ? fs.currentDirectory
      : fs.currentDirectory.childDirectory(name);

  const local = LocalProcessManager();
  const git = 'git';
  const clone = 'clone';

  const listUrl = [
    'https://github.com/sersr/hot_fix',
    'https://github.com/sersr/nop_annotations',
    'https://github.com/sersr/nop_db',
    'https://github.com/sersr/nop_db_gen',
    'https://github.com/sersr/nop_db_sqflite',
    'https://github.com/sersr/nop_db_sqlite',
    'https://github.com/sersr/sqlite3_windows_dll',
    'https://github.com/sersr/useful_tools',
  ];

  if (!projectDir.existsSync()) {
    print('${projectDir.path} 不存在');
    return;
  }

  final packages = projectDir.parent.childDirectory('packages');
  final any = FutureAny();
  print('package path: ${packages.path}');

  if (!packages.existsSync()) {
    packages.createSync(recursive: true);
  }
  for (var url in listUrl) {
    if (any.length > 3) await any.any;

    any.add(local
        .start([git, clone, url], workingDirectory: packages.path).then((pro) {
      pro.stdout.transform(utf8.decoder).listen((event) {
        print(event);
      });
    }));
  }
}

/// copy from `pakcage:useful_tools`
class FutureAny {
  final _tasks = <Future>[];

  int get length => _tasks.length;

  bool get isEmpty => _tasks.isEmpty;
  bool get isNotEmpty => _tasks.isNotEmpty;

  Completer<void>? _completer;
  Completer<void>? _completerWaitAll;

  Future<void>? get any {
    _set();
    return _completer?.future;
  }

  Future<void>? get wait {
    _setWaitAll();
    return _completerWaitAll?.future;
  }

  void _set() {
    assert(_completer == null || !_completer!.isCompleted);

    if (_completer == null || _completer!.isCompleted) {
      if (isNotEmpty) _completer = Completer<void>();
    }
  }

  void _setWaitAll() {
    assert(_completerWaitAll == null || !_completerWaitAll!.isCompleted);

    if (_completerWaitAll == null || _completerWaitAll!.isCompleted) {
      if (isNotEmpty) _completerWaitAll = Completer<void>();
    }
  }

  void _completed() {
    /// any
    if (_completer != null) {
      assert(!_completer!.isCompleted);
      _completer!.complete();
      _completer = null;
    }

    /// waitAll
    if (isEmpty && _completerWaitAll != null) {
      assert(!_completerWaitAll!.isCompleted);
      _completerWaitAll!.complete();
      _completerWaitAll = null;
    }
  }

  void add(Future task) {
    _tasks.add(task
      ..whenComplete(() {
        _tasks.remove(task);
        _completed();
      }));
  }

  void addAll(Iterable<Future> tasks) {
    for (final _task in tasks) {
      add(_task);
    }
  }
}
