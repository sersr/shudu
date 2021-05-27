import 'book_event.dart';
import 'book_event_messager.dart';
import 'repository.dart';

/// 中间层
///
/// 由 main Isolate 传输到另一个 Isolate
class BookEventMain extends BookEvent
    with
        BookEventDatabaseMessager,
        ComplexMessager,
        SaveImageMessager,
        BookEventMessager {
  BookEventMain(this.repository);
  @override
  final Repository repository;
}
