
import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/bloc/book_repository.dart';

void main() async {
  // Init ffi loader if needed.
  // test('simple sqflite example', () async {
  //   final repository = BookRepositoryTest();
  //   await repository.init();
  //   expect(await repository.db.getVersion(), 1);
  //   repository.dispose();
  // });

  // testWidgets('get Index From Net', (tester) async {});
  test('test content', () async {});

  // var id = 445578;
  // var cid = 2575051;
  // var page = 0;
  final repository = BookRepositoryWinImpl();
  await repository.initState();
  // blocTest<PainterBloc, PainterState>(
  //   'painter',
  //   // build: () => PainterBloc(repository: repository),
  //   act: (bloc) async {
  //     bloc
  //       ..add(
  //         PainterNotifyIdEvent(id, cid,page),
  //       );
  //   },
  // );
}
