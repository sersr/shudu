import 'package:json_annotation/json_annotation.dart';

part 'zhangdu_ranking.g.dart';

@JsonSerializable()
class ZhangduRanking {
  ZhangduRanking({
    this.code,
    this.data,
    this.msg,
    this.time,
  });
  @JsonKey(name: 'code')
  final int? code;
  @JsonKey(name: 'data')
  final List<ZhangduRankingData>? data;
  @JsonKey(name: 'msg')
  final String? msg;
  @JsonKey(name: 'time')
  final int? time;

  factory ZhangduRanking.fromJson(Map<String,dynamic> json) => _$ZhangduRankingFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduRankingToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ZhangduRankingData {
  ZhangduRankingData({
    this.id,
    this.name,
    this.picture,
    this.score,
    this.intro,
    this.bookType,
    this.wordNum,
    this.author,
    this.aliasAuthor,
    this.protagonist,
    this.categoryId,
    this.categoryName,
    this.zipurl,
  });
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'picture')
  final String? picture;
  @JsonKey(name: 'score')
  final double? score;
  @JsonKey(name: 'intro')
  final String? intro;
  @JsonKey(name: 'bookType')
  final int? bookType;
  @JsonKey(name: 'wordNum')
  final int? wordNum;
  @JsonKey(name: 'author')
  final String? author;
  @JsonKey(name: 'aliasAuthor')
  final String? aliasAuthor;
  @JsonKey(name: 'protagonist')
  final String? protagonist;
  @JsonKey(name: 'categoryId')
  final int? categoryId;
  @JsonKey(name: 'categoryName')
  final String? categoryName;
  @JsonKey(name: 'zipurl')
  final String? zipurl;

  factory ZhangduRankingData.fromJson(Map<String,dynamic> json) => _$ZhangduRankingDataFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduRankingDataToJson(this);
}

