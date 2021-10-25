// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhangdu_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhangduChapter _$ZhangduChapterFromJson(Map<String, dynamic> json) =>
    ZhangduChapter(
      code: json['code'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ZhangduChapterData.fromJson(e as Map<String, dynamic>))
          .toList(),
      msg: json['msg'] as String?,
      time: json['time'] as int?,
      domain: json['domain'] as String?,
      bookId: json['book_id'] as int?,
    );

Map<String, dynamic> _$ZhangduChapterToJson(ZhangduChapter instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
      'time': instance.time,
      'domain': instance.domain,
      'book_id': instance.bookId,
    };

ZhangduChapterData _$ZhangduChapterDataFromJson(Map<String, dynamic> json) =>
    ZhangduChapterData(
      id: json['id'] as int?,
      bookId: json['bookId'] as int?,
      name: json['name'] as String?,
      status: json['status'] as int?,
      sort: json['sort'] as int?,
      contentUrl: json['content_url'] as String?,
    );

Map<String, dynamic> _$ZhangduChapterDataToJson(ZhangduChapterData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'name': instance.name,
      'status': instance.status,
      'sort': instance.sort,
      'content_url': instance.contentUrl,
    };
