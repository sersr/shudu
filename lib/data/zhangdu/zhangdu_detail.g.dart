// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhangdu_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhangduDetail _$ZhangduDetailFromJson(Map<String, dynamic> json) =>
    ZhangduDetail(
      code: json['code'] as int?,
      data: json['data'] == null
          ? null
          : ZhangduDetailData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
      time: json['time'] as int?,
    );

Map<String, dynamic> _$ZhangduDetailToJson(ZhangduDetail instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
      'time': instance.time,
    };

ZhangduDetailData _$ZhangduDetailDataFromJson(Map<String, dynamic> json) =>
    ZhangduDetailData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      pinyin: json['pinyin'] as String?,
      aliasName: json['aliasName'] as String?,
      protagonist: json['protagonist'] as String?,
      category: json['category'] as String?,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      author: json['author'] as String?,
      aliasAuthor: json['aliasAuthor'] as String?,
      bookType: json['bookType'] as int?,
      bookStatus: json['bookStatus'] as String?,
      chapterNum: json['chapterNum'] as int?,
      createBy: json['createBy'] as String?,
      intro: json['intro'] as String?,
      picture: json['picture'] as String?,
      status: json['status'] as int?,
      updateBy: json['updateBy'] as String?,
      wordNum: json['wordNum'] as int?,
      dataScope: json['dataScope'] as String?,
      params: json['params'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
      createdTime: json['createdTime'] as String?,
      updatedTime: json['updatedTime'] as String?,
      chapterId: json['chapterId'] as int?,
      chapterName: json['chapterName'] as String?,
      chapterUpdateTime: json['chapterUpdateTime'] as String?,
      chapterCountErr: json['chapterCountErr'] as int?,
      sourceBookId: json['sourceBookId'] as int?,
      ruleId: json['ruleId'] as int?,
      ruleName: json['ruleName'] as String?,
      sStatus: json['sStatus'] as int?,
      heat: json['heat'] as int?,
      pv: json['pv'] as int?,
      score: (json['score'] as num?)?.toDouble(),
      view: json['view'] as int?,
      bookshelf: json['bookshelf'] as int?,
      yesterday: json['yesterday'] as int?,
      lastWeek: json['lastWeek'] as int?,
      lastMonth: json['lastMonth'] as int?,
      commentNum: json['commentNum'] as int?,
      picturImages: json['pictur_images'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map(
              (e) => ZhangduDetailDataTags.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ZhangduDetailDataToJson(ZhangduDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pinyin': instance.pinyin,
      'aliasName': instance.aliasName,
      'protagonist': instance.protagonist,
      'category': instance.category,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'author': instance.author,
      'aliasAuthor': instance.aliasAuthor,
      'bookType': instance.bookType,
      'bookStatus': instance.bookStatus,
      'chapterNum': instance.chapterNum,
      'createBy': instance.createBy,
      'intro': instance.intro,
      'picture': instance.picture,
      'status': instance.status,
      'updateBy': instance.updateBy,
      'wordNum': instance.wordNum,
      'dataScope': instance.dataScope,
      'params': instance.params,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
      'createdTime': instance.createdTime,
      'updatedTime': instance.updatedTime,
      'chapterId': instance.chapterId,
      'chapterName': instance.chapterName,
      'chapterUpdateTime': instance.chapterUpdateTime,
      'chapterCountErr': instance.chapterCountErr,
      'sourceBookId': instance.sourceBookId,
      'ruleId': instance.ruleId,
      'ruleName': instance.ruleName,
      'sStatus': instance.sStatus,
      'heat': instance.heat,
      'pv': instance.pv,
      'score': instance.score,
      'view': instance.view,
      'bookshelf': instance.bookshelf,
      'yesterday': instance.yesterday,
      'lastWeek': instance.lastWeek,
      'lastMonth': instance.lastMonth,
      'commentNum': instance.commentNum,
      'pictur_images': instance.picturImages,
      'tags': instance.tags?.map((e) => e.toJson()).toList(),
    };

ZhangduDetailDataTags _$ZhangduDetailDataTagsFromJson(
        Map<String, dynamic> json) =>
    ZhangduDetailDataTags(
      tagId: json['tagId'] as int?,
      tagName: json['tagName'] as String?,
    );

Map<String, dynamic> _$ZhangduDetailDataTagsToJson(
        ZhangduDetailDataTags instance) =>
    <String, dynamic>{
      'tagId': instance.tagId,
      'tagName': instance.tagName,
    };
