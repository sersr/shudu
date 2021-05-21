import 'package:flutter/material.dart';
import '../../event/event.dart';
import 'package:provider/provider.dart';

class CacheManager extends StatefulWidget {
  @override
  _CacheManagerState createState() => _CacheManagerState();
}

class _CacheManagerState extends State<CacheManager> {
  final _cacheNotifier = _CacheNotifier();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    _cacheNotifier.repository = repository;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _cacheNotifier,
        builder: (context, child) {
          return ListView.builder(itemBuilder: (context, index) {
            return Container();
          });
        });
  }
}

class _CacheNotifier extends ChangeNotifier {
  _CacheNotifier();

  final _data = <int>{};

  List<int> get data => List.of(_data);

  Repository? _repository;

  Repository? get repository => _repository;

  set repository(Repository? v) {
    if (_repository != v) {
      _repository = v;
    }
  }

  void startLoad() async {
    if (repository == null) return;
    final _l = await repository!.databaseEvent.getAllBookId();
    if (_l.isNotEmpty) {
      _data.clear();
      _data.addAll(_l);
      notifyListeners();
    }
  }
}

class _CacheBookItemNotifier extends ChangeNotifier {
  _CacheBookItemNotifier(this.repository, this.id);
  final id;
  final Repository repository;
  String? name;
  int? itemCounts;
  int? cacheItemCounts;

  bool get isEmpty =>
      name == null || itemCounts == null || cacheItemCounts == null;

  void startLoad() {
    repository.databaseEvent.getIndexsDb(id);
  }
}
