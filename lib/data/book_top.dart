import 'package:json_annotation/json_annotation.dart';

part 'book_top.g.dart';

@JsonSerializable()
class BookTopList {
  BookTopList({this.author, this.desc, this.id, this.img, this.name, this.score, this.cname});
  @JsonKey(name: 'Id')
  final int? id;
  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'Author')
  final String? author;
  @JsonKey(name: 'Img')
  final String? img;
  @JsonKey(name: 'Desc')
  final String? desc;
  @JsonKey(name: 'CName')
  final String? cname;
  @JsonKey(name: 'Score')
  final double? score;

  factory BookTopList.fromJson(Map<String, dynamic> json) => _$BookTopListFromJson(json);
  Map<String, dynamic> toJson() => _$BookTopListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookTopData {
  BookTopData({this.bookList, this.hasNext, this.page});
  @JsonKey(name: 'BookList')
  final List<BookTopList>? bookList;
  @JsonKey(name: 'Page')
  final int? page;
  @JsonKey(name: 'HasNext')
  final bool? hasNext;

  factory BookTopData.fromJson(Map<String, dynamic> json) => _$BookTopDataFromJson(json);
  Map<String, dynamic> toJson() => _$BookTopDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookTopWrap {
  BookTopWrap({this.data, this.info, this.status});
  final int? status;
  final String? info;
  final BookTopData? data;
  factory BookTopWrap.fromJson(Map<String, dynamic> json) => _$BookTopWrapFromJson(json);
  Map<String, dynamic> toJson() => _$BookTopWrapToJson(this);
}
