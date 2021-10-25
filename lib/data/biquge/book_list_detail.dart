import 'package:json_annotation/json_annotation.dart';

part 'book_list_detail.g.dart';

@JsonSerializable()
class BookListDetail {
  const BookListDetail(
      {this.author,
      this.bookIamge,
      this.bookId,
      this.bookName,
      this.categoryName,
      this.description,
      this.id,
      this.score});
  @JsonKey(name: 'Author')
  final String? author;
  @JsonKey(name: 'Id')
  final int? id;
  @JsonKey(name: 'BookId')
  final int? bookId;
  @JsonKey(name: 'BookName')
  final String? bookName;
  @JsonKey(name: 'BookImage')
  final String? bookIamge;

  @JsonKey(name: 'CategoryName')
  final String? categoryName;
  @JsonKey(name: 'Score')
  final double? score;
  @JsonKey(name: 'Description')
  final String? description;

  factory BookListDetail.fromJson(Map<String, dynamic> json) => _$BookListDetailFromJson(json);
  Map<String, dynamic> toJson() => _$BookListDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookListDetailData {
  const BookListDetailData(
      {this.addTime,
      this.bookList,
      this.cover,
      this.description,
      this.forMan,
      this.isCheck,
      this.isRecycle,
      this.listId,
      this.title,
      this.updateTime,
      this.userName});
  @JsonKey(name: 'ListId')
  final int? listId;
  @JsonKey(name: 'UserName')
  final String? userName;
  @JsonKey(name: 'Cover')
  final String? cover;
  @JsonKey(name: 'IsCheck')
  final bool? isCheck;
  @JsonKey(name: 'IsRecycle')
  final bool? isRecycle;
  @JsonKey(name: 'Title')
  final String? title;
  @JsonKey(name: 'ForMan')
  final bool? forMan;
  @JsonKey(name: 'Description')
  final String? description;
  @JsonKey(name: 'AddTime')
  final String? addTime;
  @JsonKey(name: 'UpdateTime')
  final String? updateTime;
  @JsonKey(name: 'BookList')
  final List<BookListDetail>? bookList;

  factory BookListDetailData.fromJson(Map<String, dynamic> json) => _$BookListDetailDataFromJson(json);
  Map<String, dynamic> toJson() => _$BookListDetailDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookListDetailRoot {
  const BookListDetailRoot({this.data, this.info, this.status});
  final BookListDetailData? data;
  final int? status;
  final String? info;
  factory BookListDetailRoot.fromJson(Map<String, dynamic> json) => _$BookListDetailRootFromJson(json);
  Map<String, dynamic> toJson() => _$BookListDetailRootToJson(this);
}
