// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:file/local.dart';
import 'package:process/process.dart';
import 'package:args/args.dart';

void main(args) async {
  final parser = ArgParser();
  parser.addOption('path');
  parser.addFlag('update');
  parser.addOption('base');
  final result = parser.parse(args);
  final name = result['path'];
  final update = result['update'] == true;
  final base = result['base'];

  const fs = LocalFileSystem();
  final projectDir = name == null
      ? fs.currentDirectory
      : fs.currentDirectory.childDirectory(name);

  final _base = base as String? ?? 'https://github.com/sersr/';
  final end = !_base.endsWith('/');
  final githubBase = end ? _base : '$_base/';

  const listPackage = [
    'hot_fix',
    'nop_annotations',
    'nop_db',
    'nop_db_gen',
    'nop_db_sqflite',
    'nop_db_sqlite',
    'sqlite3_windows_dll',
    'useful_tools',
    'utils',
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
  for (var name in listPackage) {
    if (any.length > 3) await any.any;

    final cmd = <String>[];
    cmd.add('git');

    final syncPackage = packages.childDirectory(name);

    if (syncPackage.existsSync()) {
      if (!update) {
        print('skip: $name');
        continue;
      }

      print('update: $name');

      cmd
        ..add('pull')
        ..add('origin')
        ..add('master');
    } else {
      print('sync: $name');
      cmd
        ..add('clone')
        ..add('$githubBase$name');
    }

    final work = run(cmd, packages.path);

    any.add(work);
  }
  await any.wait;
  // test
  // await local.start(['cmd', '/C', 'echo', 'hello'],
  //     workingDirectory: packages.path).then((pro) {
  //   final completer = Completer();
  //   void _onDone() {
  //     if (!completer.isCompleted) {
  //       completer.complete();
  //     }
  //   }

  //   pro.stdout.transform(utf8.decoder).listen((event) {
  //     print('sync: $event');
  //   }, onDone: _onDone, cancelOnError: true, onError: (e, s) => _onDone());
  //   return completer.future;
  // });
}

const local = LocalProcessManager();
Future<void> run(List<Object> cmd, String? workingDirectory) {
  return local.start(cmd, workingDirectory: workingDirectory).then((pro) {
    final completer = Completer<void>();
    void _onDone() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    pro.stdout.transform(utf8.decoder).listen((event) {
      print('sync: $event');
    }, onDone: _onDone, cancelOnError: true, onError: (e, s) => _onDone());

    return completer.future;
  });
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
