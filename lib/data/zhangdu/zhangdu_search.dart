import 'package:json_annotation/json_annotation.dart';

part 'zhangdu_search.g.dart';

@JsonSerializable()
class ZhangduSearch {
  const ZhangduSearch({
    this.code,
    this.data,
    this.msg,
    this.time,
  });
  @JsonKey(name: 'code')
  final int? code;
  @JsonKey(name: 'data')
  final ZhangduSearchData? data;
  @JsonKey(name: 'msg')
  final String? msg;
  @JsonKey(name: 'time')
  final String? time;

  factory ZhangduSearch.fromJson(Map<String,dynamic> json) => _$ZhangduSearchFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduSearchToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ZhangduSearchData {
  const ZhangduSearchData({
    this.list,
    this.extra,
    this.count,
    this.pageIndex,
    this.pageSize,
  });
  @JsonKey(name: 'list')
  final List<ZhangduSearchDataList>? list;
  @JsonKey(name: 'extra')
  final ZhangduSearchDataExtra? extra;
  @JsonKey(name: 'count')
  final int? count;
  @JsonKey(name: 'pageIndex')
  final int? pageIndex;
  @JsonKey(name: 'pageSize')
  final int? pageSize;

  factory ZhangduSearchData.fromJson(Map<String,dynamic> json) => _$ZhangduSearchDataFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduSearchDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ZhangduSearchDataList {
  const ZhangduSearchDataList({
    this.bookId,
    this.name,
    this.aliasName,
    this.protagonist,
    this.categoryId,
    this.categoryName,
    this.author,
    this.aliasAuthor,
    this.bookType,
    this.bookStatus,
    this.chapterNum,
    this.intro,
    this.picture,
    this.status,
    this.wordNum,
    this.score,
    this.chapterName,
    this.chapterUpdateTime,
  });
  @JsonKey(name: 'bookId')
  final int? bookId;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'aliasName')
  final String? aliasName;
  @JsonKey(name: 'protagonist')
  final String? protagonist;
  @JsonKey(name: 'categoryId')
  final int? categoryId;
  @JsonKey(name: 'categoryName')
  final String? categoryName;
  @JsonKey(name: 'author')
  final String? author;
  @JsonKey(name: 'aliasAuthor')
  final String? aliasAuthor;
  @JsonKey(name: 'bookType')
  final int? bookType;
  @JsonKey(name: 'bookStatus')
  final String? bookStatus;
  @JsonKey(name: 'chapterNum')
  final int? chapterNum;
  @JsonKey(name: 'intro')
  final String? intro;
  @JsonKey(name: 'picture')
  final String? picture;
  @JsonKey(name: 'status')
  final int? status;
  @JsonKey(name: 'wordNum')
  final int? wordNum;
  @JsonKey(name: 'score')
  final double? score;
  @JsonKey(name: 'chapterName')
  final String? chapterName;
  @JsonKey(name: 'chapterUpdateTime')
  final String? chapterUpdateTime;

  factory ZhangduSearchDataList.fromJson(Map<String,dynamic> json) => _$ZhangduSearchDataListFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduSearchDataListToJson(this);
}


@JsonSerializable(explicitToJson: true)
class ZhangduSearchDataExtra {
  const ZhangduSearchDataExtra({
    this.weeknew,
  });
  @JsonKey(name: 'weeknew')
  final int? weeknew;

  factory ZhangduSearchDataExtra.fromJson(Map<String,dynamic> json) => _$ZhangduSearchDataExtraFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduSearchDataExtraToJson(this);
}

