import 'package:json_annotation/json_annotation.dart';

part 'search_data.g.dart';

@JsonSerializable()
class SearchData {
  const SearchData(
      {this.author,
      this.bookStatus,
      this.cName,
      this.desc,
      this.id,
      this.img,
      this.lastChapter,
      this.lastChpaterId,
      this.name,
      this.updateTime});
  @JsonKey(name: 'Author')
  final String? author;
  @JsonKey(name: 'BookStatus')
  final String? bookStatus;
  @JsonKey(name: 'CName')
  final String? cName;
  @JsonKey(name: 'Id')
  final String? id;
  @JsonKey(name: 'Desc')
  final String? desc;
  @JsonKey(name: 'Img')
  final String? img;
  @JsonKey(name: 'LastChapter')
  final String? lastChapter;
  @JsonKey(name: 'LastChapterId')
  final String? lastChpaterId;
  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'UpdateTime')
  final DateTime? updateTime;

  factory SearchData.fromJson(Map<String, dynamic> json) => _$SearchDataFromJson(json);
  Map<String, dynamic> toJson() => _$SearchDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SearchList {
  const SearchList({this.data, this.info, this.status});
  final List<SearchData>? data;
  final int? status;
  final String? info;
  factory SearchList.fromJson(Map<String, dynamic> json) => _$SearchListFromJson(json);
  Map<String, dynamic> toJson() => _$SearchListToJson(this);
}
