import 'package:json_annotation/json_annotation.dart';

part 'book_info.g.dart';

@JsonSerializable()
class BookVote {
  const BookVote({this.bookId, this.scroe, this.totalScore, this.voterCount});
  @JsonKey(name: 'BookId')
  final int? bookId;
  @JsonKey(name: 'TotalScore')
  final int? totalScore;
  @JsonKey(name: 'VoterCount')
  final int? voterCount;
  @JsonKey(name: 'Score')
  final double? scroe;

  factory BookVote.fromJson(Map<String, dynamic> json) => _$BookVoteFromJson(json);
  Map<String, dynamic> toJson() => _$BookVoteToJson(this);
}

@JsonSerializable()
class SameUserBook {
  const SameUserBook({this.id, this.img, this.lastChapter, this.lastChapterId, this.name, this.score});
  @JsonKey(name: 'Id')
  final int? id;
  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'Img')
  final String? img;
  @JsonKey(name: 'LastChapterId')
  final int? lastChapterId;
  @JsonKey(name: 'LastChapter')
  final String? lastChapter;
  @JsonKey(name: 'Score')
  final double? score;

  factory SameUserBook.fromJson(Map<String, dynamic> json) => _$SameUserBookFromJson(json);
  Map<String, dynamic> toJson() => _$SameUserBookToJson(this);
}

@JsonSerializable()
class SameCategoryBook {
  const SameCategoryBook({this.id, this.img, this.name, this.score});
  @JsonKey(name: 'Id')
  final int? id;
  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'Img')
  final String? img;
  @JsonKey(name: 'Score')
  final double? score;

  factory SameCategoryBook.fromJson(Map<String, dynamic> json) => _$SameCategoryBookFromJson(json);
  Map<String, dynamic> toJson() => _$SameCategoryBookToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookInfo {
  const BookInfo(
      {this.author,
      this.bookStatus,
      this.bookVote,
      this.cId,
      this.cName,
      this.desc,
      this.id,
      this.img,
      this.lastChapterId,
      this.lastTime,
      this.name,
      this.sameCategoryBooks,
      this.sameUserBooks,
      this.firstChapterId,
      this.lastChapter});
  @JsonKey(name: 'Author')
  final String? author;
  @JsonKey(name: 'BookStatus')
  final String? bookStatus;
  @JsonKey(name: 'BookVote')
  final BookVote? bookVote;
  @JsonKey(name: 'CId')
  final int? cId;
  @JsonKey(name: 'CName')
  final String? cName;
  @JsonKey(name: 'LastTime')
  final String? lastTime;
  @JsonKey(name: 'FirstChapterId')
  final int? firstChapterId;
  @JsonKey(name: 'LastChapter')
  final String? lastChapter;
  @JsonKey(name: 'LastChapterId')
  final int? lastChapterId;

  @JsonKey(name: 'Id')
  final int? id;
  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'Img')
  final String? img;
  @JsonKey(name: 'Desc')
  final String? desc;
  @JsonKey(name: 'SameUserBooks')
  final List<SameUserBook>? sameUserBooks;
  @JsonKey(name: 'SameCategoryBooks')
  final List<SameCategoryBook>? sameCategoryBooks;

  factory BookInfo.fromJson(Map<String, dynamic> json) => _$BookInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BookInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BookInfoRoot {
  const BookInfoRoot({this.data, this.info, this.status});
  final int? status;
  final String? info;
  final BookInfo? data;
  factory BookInfoRoot.fromJson(Map<String, dynamic> json) => _$BookInfoRootFromJson(json);
  Map<String, dynamic> toJson() => _$BookInfoRootToJson(this);
}
