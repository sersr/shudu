// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhangdu_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhangduSearch _$ZhangduSearchFromJson(Map<String, dynamic> json) =>
    ZhangduSearch(
      code: json['code'] as int?,
      data: json['data'] == null
          ? null
          : ZhangduSearchData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$ZhangduSearchToJson(ZhangduSearch instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
      'time': instance.time,
    };

ZhangduSearchData _$ZhangduSearchDataFromJson(Map<String, dynamic> json) =>
    ZhangduSearchData(
      list: (json['list'] as List<dynamic>?)
          ?.map(
              (e) => ZhangduSearchDataList.fromJson(e as Map<String, dynamic>))
          .toList(),
      extra: json['extra'] == null
          ? null
          : ZhangduSearchDataExtra.fromJson(
              json['extra'] as Map<String, dynamic>),
      count: json['count'] as int?,
      pageIndex: json['pageIndex'] as int?,
      pageSize: json['pageSize'] as int?,
    );

Map<String, dynamic> _$ZhangduSearchDataToJson(ZhangduSearchData instance) =>
    <String, dynamic>{
      'list': instance.list?.map((e) => e.toJson()).toList(),
      'extra': instance.extra?.toJson(),
      'count': instance.count,
      'pageIndex': instance.pageIndex,
      'pageSize': instance.pageSize,
    };

ZhangduSearchDataList _$ZhangduSearchDataListFromJson(
        Map<String, dynamic> json) =>
    ZhangduSearchDataList(
      bookId: json['bookId'] as int?,
      name: json['name'] as String?,
      aliasName: json['aliasName'] as String?,
      protagonist: json['protagonist'] as String?,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      author: json['author'] as String?,
      aliasAuthor: json['aliasAuthor'] as String?,
      bookType: json['bookType'] as int?,
      bookStatus: json['bookStatus'] as String?,
      chapterNum: json['chapterNum'] as int?,
      intro: json['intro'] as String?,
      picture: json['picture'] as String?,
      status: json['status'] as int?,
      wordNum: json['wordNum'] as int?,
      score: (json['score'] as num?)?.toDouble(),
      chapterName: json['chapterName'] as String?,
      chapterUpdateTime: json['chapterUpdateTime'] as String?,
    );

Map<String, dynamic> _$ZhangduSearchDataListToJson(
        ZhangduSearchDataList instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'name': instance.name,
      'aliasName': instance.aliasName,
      'protagonist': instance.protagonist,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'author': instance.author,
      'aliasAuthor': instance.aliasAuthor,
      'bookType': instance.bookType,
      'bookStatus': instance.bookStatus,
      'chapterNum': instance.chapterNum,
      'intro': instance.intro,
      'picture': instance.picture,
      'status': instance.status,
      'wordNum': instance.wordNum,
      'score': instance.score,
      'chapterName': instance.chapterName,
      'chapterUpdateTime': instance.chapterUpdateTime,
    };

ZhangduSearchDataExtra _$ZhangduSearchDataExtraFromJson(
        Map<String, dynamic> json) =>
    ZhangduSearchDataExtra(
      weeknew: json['weeknew'] as int?,
    );

Map<String, dynamic> _$ZhangduSearchDataExtraToJson(
        ZhangduSearchDataExtra instance) =>
    <String, dynamic>{
      'weeknew': instance.weeknew,
    };
