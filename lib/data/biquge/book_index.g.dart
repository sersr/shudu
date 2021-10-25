// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetBookIndex _$NetBookIndexFromJson(Map<String, dynamic> json) => NetBookIndex(
      id: json['id'] as int?,
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => BookIndexDiv.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$NetBookIndexToJson(NetBookIndex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'list': instance.list?.map((e) => e.toJson()).toList(),
      'name': instance.name,
    };

BookIndexDiv _$BookIndexDivFromJson(Map<String, dynamic> json) => BookIndexDiv(
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => BookIndexChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$BookIndexDivToJson(BookIndexDiv instance) =>
    <String, dynamic>{
      'list': instance.list?.map((e) => e.toJson()).toList(),
      'name': instance.name,
    };

BookIndexChapter _$BookIndexChapterFromJson(Map<String, dynamic> json) =>
    BookIndexChapter(
      hasContent: json['hasContent'] as int?,
      id: json['id'] as int?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$BookIndexChapterToJson(BookIndexChapter instance) =>
    <String, dynamic>{
      'hasContent': instance.hasContent,
      'id': instance.id,
      'name': instance.name,
    };

BookIndexRoot _$BookIndexRootFromJson(Map<String, dynamic> json) =>
    BookIndexRoot(
      data: json['data'] == null
          ? null
          : NetBookIndex.fromJson(json['data'] as Map<String, dynamic>),
      id: json['id'] as int?,
      info: json['info'] as String?,
      status: json['status'] as int?,
    );

Map<String, dynamic> _$BookIndexRootToJson(BookIndexRoot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'info': instance.info,
      'data': instance.data?.toJson(),
    };
