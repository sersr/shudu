// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_category_all.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookCategoryAll _$BookCategoryAllFromJson(Map<String, dynamic> json) =>
    BookCategoryAll(
      status: json['status'] as int?,
      info: json['info'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BookCategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookCategoryAllToJson(BookCategoryAll instance) =>
    <String, dynamic>{
      'status': instance.status,
      'info': instance.info,
      'data': instance.data,
    };

BookCategoryData _$BookCategoryDataFromJson(Map<String, dynamic> json) =>
    BookCategoryData(
      count: json['Count'] as int?,
      id: json['Id'] as String?,
      image: json['Image'] as String?,
      name: json['Name'] as String?,
    );

Map<String, dynamic> _$BookCategoryDataToJson(BookCategoryData instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Count': instance.count,
      'Image': instance.image,
    };
