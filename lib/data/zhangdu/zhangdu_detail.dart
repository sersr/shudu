import 'package:json_annotation/json_annotation.dart';

part 'zhangdu_detail.g.dart';

@JsonSerializable()
class ZhangduDetail {
  ZhangduDetail({
    this.code,
    this.data,
    this.msg,
    this.time,
  });
  @JsonKey(name: 'code')
  final int? code;
  @JsonKey(name: 'data')
  final ZhangduDetailData? data;
  @JsonKey(name: 'msg')
  final String? msg;
  @JsonKey(name: 'time')
  final int? time;

  factory ZhangduDetail.fromJson(Map<String, dynamic> json) =>
      _$ZhangduDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ZhangduDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ZhangduDetailData {
  const ZhangduDetailData({
    this.id,
    this.name,
    this.pinyin,
    this.aliasName,
    this.protagonist,
    this.category,
    this.categoryId,
    this.categoryName,
    this.author,
    this.aliasAuthor,
    this.bookType,
    this.bookStatus,
    this.chapterNum,
    this.createBy,
    this.intro,
    this.picture,
    this.status,
    this.updateBy,
    this.wordNum,
    this.dataScope,
    this.params,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdTime,
    this.updatedTime,
    this.chapterId,
    this.chapterName,
    this.chapterUpdateTime,
    this.chapterCountErr,
    this.sourceBookId,
    this.ruleId,
    this.ruleName,
    this.sStatus,
    this.heat,
    this.pv,
    this.score,
    this.view,
    this.bookshelf,
    this.yesterday,
    this.lastWeek,
    this.lastMonth,
    this.commentNum,
    this.picturImages,
    this.tags,
  });
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'pinyin')
  final String? pinyin;
  @JsonKey(name: 'aliasName')
  final String? aliasName;
  @JsonKey(name: 'protagonist')
  final String? protagonist;
  @JsonKey(name: 'category')
  final String? category;
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
  @JsonKey(name: 'createBy')
  final String? createBy;
  @JsonKey(name: 'intro')
  final String? intro;
  @JsonKey(name: 'picture')
  final String? picture;
  @JsonKey(name: 'status')
  final int? status;
  @JsonKey(name: 'updateBy')
  final String? updateBy;
  @JsonKey(name: 'wordNum')
  final int? wordNum;
  @JsonKey(name: 'dataScope')
  final String? dataScope;
  @JsonKey(name: 'params')
  final String? params;
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;
  @JsonKey(name: 'deletedAt')
  final String? deletedAt;
  @JsonKey(name: 'createdTime')
  final String? createdTime;
  @JsonKey(name: 'updatedTime')
  final String? updatedTime;
  @JsonKey(name: 'chapterId')
  final int? chapterId;
  @JsonKey(name: 'chapterName')
  final String? chapterName;
  @JsonKey(name: 'chapterUpdateTime')
  final String? chapterUpdateTime;
  @JsonKey(name: 'chapterCountErr')
  final int? chapterCountErr;
  @JsonKey(name: 'sourceBookId')
  final int? sourceBookId;
  @JsonKey(name: 'ruleId')
  final int? ruleId;
  @JsonKey(name: 'ruleName')
  final String? ruleName;
  @JsonKey(name: 'sStatus')
  final int? sStatus;
  @JsonKey(name: 'heat')
  final int? heat;
  @JsonKey(name: 'pv')
  final int? pv;
  @JsonKey(name: 'score')
  final double? score;
  @JsonKey(name: 'view')
  final int? view;
  @JsonKey(name: 'bookshelf')
  final int? bookshelf;
  @JsonKey(name: 'yesterday')
  final int? yesterday;
  @JsonKey(name: 'lastWeek')
  final int? lastWeek;
  @JsonKey(name: 'lastMonth')
  final int? lastMonth;
  @JsonKey(name: 'commentNum')
  final int? commentNum;
  @JsonKey(name: 'pictur_images')
  final String? picturImages;
  @JsonKey(name: 'tags')
  final List<ZhangduDetailDataTags>? tags;

  factory ZhangduDetailData.fromJson(Map<String, dynamic> json) =>
      _$ZhangduDetailDataFromJson(json);
  Map<String, dynamic> toJson() => _$ZhangduDetailDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ZhangduDetailDataTags {
  ZhangduDetailDataTags({
    this.tagId,
    this.tagName,
  });
  @JsonKey(name: 'tagId')
  final int? tagId;
  @JsonKey(name: 'tagName')
  final String? tagName;

  factory ZhangduDetailDataTags.fromJson(Map<String, dynamic> json) =>
      _$ZhangduDetailDataTagsFromJson(json);
  Map<String, dynamic> toJson() => _$ZhangduDetailDataTagsToJson(this);
}
