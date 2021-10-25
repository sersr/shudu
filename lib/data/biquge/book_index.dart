import 'package:json_annotation/json_annotation.dart';

part 'book_index.g.dart';

@JsonSerializable(explicitToJson: true)
class NetBookIndex {
  const NetBookIndex({this.id, this.list, this.name});
  final int? id;
  final List<BookIndexDiv>? list;
  final String? name;
  factory NetBookIndex.fromJson(Map<String, dynamic> json) =>
      _$NetBookIndexFromJson(json);
  Map<String, dynamic> toJson() => _$NetBookIndexToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookIndexDiv {
  const BookIndexDiv({this.list, this.name});
  final List<BookIndexChapter>? list;
  final String? name;
  factory BookIndexDiv.fromJson(Map<String, dynamic> json) => _$BookIndexDivFromJson(json);
  Map<String, dynamic> toJson() => _$BookIndexDivToJson(this);
}

@JsonSerializable()
class BookIndexChapter {
  const BookIndexChapter({this.hasContent, this.id, this.name});
  final int? hasContent;
  final int? id;
  final String? name;
  factory BookIndexChapter.fromJson(Map<String, dynamic> json) => _$BookIndexChapterFromJson(json);
  Map<String, dynamic> toJson() => _$BookIndexChapterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookIndexRoot {
  const BookIndexRoot({this.data, this.id, this.info, this.status});
  final int? id;
  final int? status;
  final String? info;
  final NetBookIndex? data;
  factory BookIndexRoot.fromJson(Map<String, dynamic> json) => _$BookIndexRootFromJson(json);
  Map<String, dynamic> toJson() => _$BookIndexRootToJson(this);
}
