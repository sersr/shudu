import 'package:json_annotation/json_annotation.dart';

part 'zhangdu_chapter.g.dart';

@JsonSerializable()
class ZhangduChapter {
  const ZhangduChapter({
    this.code,
    this.data,
    this.msg,
    this.time,
    this.domain,
    this.bookId,
  });
  @JsonKey(name: 'code')
  final int? code;
  @JsonKey(name: 'data')
  final List<ZhangduChapterData>? data;
  @JsonKey(name: 'msg')
  final String? msg;
  @JsonKey(name: 'time')
  final int? time;
  @JsonKey(name: 'domain')
  final String? domain;
  @JsonKey(name: 'book_id')
  final int? bookId;

  factory ZhangduChapter.fromJson(Map<String,dynamic> json) => _$ZhangduChapterFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduChapterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ZhangduChapterData {
  const ZhangduChapterData({
    this.id,
    this.bookId,
    this.name,
    this.status,
    this.sort,
    this.contentUrl,
  });
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'bookId')
  final int? bookId;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'status')
  final int? status;
  @JsonKey(name: 'sort')
  final int? sort;
  @JsonKey(name: 'content_url')
  final String? contentUrl;

  factory ZhangduChapterData.fromJson(Map<String,dynamic> json) => _$ZhangduChapterDataFromJson(json);
  Map<String,dynamic> toJson() => _$ZhangduChapterDataToJson(this);
}

