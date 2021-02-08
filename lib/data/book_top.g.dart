// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_top.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookTopList _$BookTopListFromJson(Map<String, dynamic> json) {
  return BookTopList(
    author: json['Author'] as String?,
    desc: json['Desc'] as String?,
    id: json['Id'] as int?,
    img: json['Img'] as String?,
    name: json['Name'] as String?,
    score: (json['Score'] as num?)?.toDouble(),
    cname: json['CName'] as String?,
  );
}

Map<String, dynamic> _$BookTopListToJson(BookTopList instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Author': instance.author,
      'Img': instance.img,
      'Desc': instance.desc,
      'CName': instance.cname,
      'Score': instance.score,
    };

BookTopData _$BookTopDataFromJson(Map<String, dynamic> json) {
  return BookTopData(
    bookList: (json['BookList'] as List<dynamic>?)
        ?.map((e) => BookTopList.fromJson(e as Map<String, dynamic>))
        .toList(),
    hasNext: json['HasNext'] as bool?,
    page: json['Page'] as int?,
  );
}

Map<String, dynamic> _$BookTopDataToJson(BookTopData instance) =>
    <String, dynamic>{
      'BookList': instance.bookList?.map((e) => e.toJson()).toList(),
      'Page': instance.page,
      'HasNext': instance.hasNext,
    };

BookTopWrap _$BookTopWrapFromJson(Map<String, dynamic> json) {
  return BookTopWrap(
    data: json['data'] == null
        ? null
        : BookTopData.fromJson(json['data'] as Map<String, dynamic>),
    info: json['info'] as String?,
    status: json['status'] as int?,
  );
}

Map<String, dynamic> _$BookTopWrapToJson(BookTopWrap instance) =>
    <String, dynamic>{
      'status': instance.status,
      'info': instance.info,
      'data': instance.data?.toJson(),
    };
