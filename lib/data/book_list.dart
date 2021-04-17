import 'package:json_annotation/json_annotation.dart';

part 'book_list.g.dart';

@JsonSerializable()
class BookList {
  const BookList({
    this.addTime,
    this.bookCount,
    this.collectionCount,
    this.commendImage,
    this.cover,
    this.description,
    this.forMan,
    this.isCheck,
    this.listId,
    this.title,
    this.updateTime,
    this.userName,
    this.commendCount,
  });
  @JsonKey(name: 'AddTime')
  final String? addTime;
  @JsonKey(name: 'BookCount')
  final int? bookCount;
  @JsonKey(name: 'CollectionCount')
  final int? collectionCount;
  @JsonKey(name: 'CommendCount')
  final int? commendCount;
  @JsonKey(name: 'Cover')
  final String? cover;
  @JsonKey(name: 'Description')
  final String? description;
  @JsonKey(name: 'ForMan')
  final bool? forMan;
  @JsonKey(name: 'IsCheck')
  final bool? isCheck;
  @JsonKey(name: 'ListId')
  final int? listId;
  @JsonKey(name: 'Title')
  final String? title;
  @JsonKey(name: 'UpdateTime')
  final String? updateTime;
  @JsonKey(name: 'UserName')
  final String? userName;
  @JsonKey(name: 'CommendImage')
  final String? commendImage;

  factory BookList.fromJson(Map<String, dynamic> json) => _$BookListFromJson(json);
  Map<String, dynamic> toJson() => _$BookListToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookListRoot {
  const BookListRoot({this.data, this.info, this.status});
  final int? status;
  final String? info;
  final List<BookList>? data;
  factory BookListRoot.fromJson(Map<String, dynamic> json) => _$BookListRootFromJson(json);
  Map<String, dynamic> toJson() => _$BookListRootToJson(this);
}
