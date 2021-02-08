// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchData _$SearchDataFromJson(Map<String, dynamic> json) {
  return SearchData(
    author: json['Author'] as String?,
    bookStatus: json['BookStatus'] as String?,
    cName: json['CName'] as String?,
    desc: json['Desc'] as String?,
    id: json['Id'] as String?,
    img: json['Img'] as String?,
    lastChapter: json['LastChapter'] as String?,
    lastChpaterId: json['LastChapterId'] as String?,
    name: json['Name'] as String?,
    updateTime: json['UpdateTime'] == null
        ? null
        : DateTime.parse(json['UpdateTime'] as String),
  );
}

Map<String, dynamic> _$SearchDataToJson(SearchData instance) =>
    <String, dynamic>{
      'Author': instance.author,
      'BookStatus': instance.bookStatus,
      'CName': instance.cName,
      'Id': instance.id,
      'Desc': instance.desc,
      'Img': instance.img,
      'LastChapter': instance.lastChapter,
      'LastChapterId': instance.lastChpaterId,
      'Name': instance.name,
      'UpdateTime': instance.updateTime?.toIso8601String(),
    };

SearchList _$SearchListFromJson(Map<String, dynamic> json) {
  return SearchList(
    data: (json['data'] as List<dynamic>?)
        ?.map((e) => SearchData.fromJson(e as Map<String, dynamic>))
        .toList(),
    info: json['info'] as String?,
    status: json['status'] as int?,
  );
}

Map<String, dynamic> _$SearchListToJson(SearchList instance) =>
    <String, dynamic>{
      'data': instance.data?.map((e) => e.toJson()).toList(),
      'status': instance.status,
      'info': instance.info,
    };
