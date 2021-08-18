// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookContent _$BookContentFromJson(Map<String, dynamic> json) => BookContent(
      cid: json['cid'] as int?,
      cname: json['cname'] as String?,
      content: json['content'] as String?,
      hasContent: json['hasContent'] as int?,
      id: json['id'] as int?,
      name: json['name'] as String?,
      nid: json['nid'] as int?,
      pid: json['pid'] as int?,
    );

Map<String, dynamic> _$BookContentToJson(BookContent instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'cname': instance.cname,
      'content': instance.content,
      'hasContent': instance.hasContent,
      'id': instance.id,
      'name': instance.name,
      'nid': instance.nid,
      'pid': instance.pid,
    };

BookContentRoot _$BookContentRootFromJson(Map<String, dynamic> json) =>
    BookContentRoot(
      data: json['data'] == null
          ? null
          : BookContent.fromJson(json['data'] as Map<String, dynamic>),
      info: json['info'] as String?,
      status: json['status'] as int?,
    );

Map<String, dynamic> _$BookContentRootToJson(BookContentRoot instance) =>
    <String, dynamic>{
      'data': instance.data?.toJson(),
      'info': instance.info,
      'status': instance.status,
    };
