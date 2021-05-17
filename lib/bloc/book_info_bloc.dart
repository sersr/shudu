import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../compatible/repository.dart';

import '../data/book_info.dart';

abstract class BookInfoEvent extends Equatable {
  BookInfoEvent();

  @override
  List<Object> get props => [];
}

class BookInfoReloadEvent extends BookInfoEvent {}

class BookInfoEventSentWithId extends BookInfoEvent {
  BookInfoEventSentWithId(this.id);
  final int id;
  @override
  List<Object> get props => [id];
}

abstract class BookInfoState extends Equatable {
  BookInfoState();
  @override
  List<Object?> get props => [];
}

class BookInfoStateWithoutData extends BookInfoState {}

class BookInfoStateWithData extends BookInfoState {
  BookInfoStateWithData(this.data);

  final BookInfoRoot? data;
  // BookInfoStateWithData copyWith(BookInfoRoot data) {
  //   return BookInfoStateWithData(data);
  // }

  @override
  List<Object?> get props => [data];
}

class BookInfoBloc extends Bloc<BookInfoEvent, BookInfoState> {
  BookInfoBloc(this.repository) : super(BookInfoStateWithoutData());
  final Repository repository;
  int lastId = -1;
  @override
  Stream<BookInfoState> mapEventToState(BookInfoEvent event) async* {
    if (event is BookInfoEventSentWithId) {
      lastId = event.id;
      yield BookInfoStateWithoutData();
      var data = await repository.bookEvent.loadInfo(event.id);
      print('data: $data');
      await Future.delayed(Duration(milliseconds: 300));
      if (data.data != null) {
        final lastTime = data.data!.lastTime;
        final newCname = data.data!.lastChapter;
        if (newCname != null && lastTime != null) {
          await repository.bookEvent.updateCname(event.id, newCname, lastTime);
        }
      }
      yield BookInfoStateWithData(data);
    } else if (event is BookInfoReloadEvent) {
      yield BookInfoStateWithoutData();
      await Future.delayed(Duration(milliseconds: 300));
      var data = await repository.bookEvent.loadInfo(lastId);
      if (data.data != null) {
        final lastTime = data.data!.lastTime;
        final newCname = data.data!.lastChapter;
        if (newCname != null && lastTime != null) {
          await repository.bookEvent.updateCname(lastId, newCname, lastTime);
        }
      }
      yield BookInfoStateWithData(data);
    }
  }
}
