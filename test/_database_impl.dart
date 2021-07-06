import 'package:nop_db/nop_db.dart';
import 'package:shudu/event/mixin/database_mixin.dart';

class Database with DatabaseMixin {
  @override
  String get appPath => ':memory:';
  @override
  String get name => '';
  Watcher get watcher => db.watcher;
}
