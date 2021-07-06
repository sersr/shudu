import 'package:json_annotation/json_annotation.dart';

part 'book_category_all.g.dart';

@JsonSerializable()
class BookCategoryAll {
  const BookCategoryAll({this.status, this.info, this.data});
  @JsonKey(name: 'status')
  final int? status;
  @JsonKey(name: 'info')
  final String? info;
  @JsonKey(name: 'data')
  final List<BookCategoryData>? data;

  factory BookCategoryAll.fromJson(Map<String, dynamic> json) =>
      _$BookCategoryAllFromJson(json);
  Map<String, dynamic> toJson() => _$BookCategoryAllToJson(this);
}

@JsonSerializable()
class BookCategoryData {
  const BookCategoryData({this.count, this.id, this.image, this.name});
  @JsonKey(name: 'Id')
  final String? id;
  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'Count')
  final int? count;
  @JsonKey(name: 'Image')
  final String? image;

  factory BookCategoryData.fromJson(Map<String, dynamic> json) =>
      _$BookCategoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$BookCategoryDataToJson(this);
}
