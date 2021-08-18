// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookList _$BookListFromJson(Map<String, dynamic> json) => BookList(
      addTime: json['AddTime'] as String?,
      bookCount: json['BookCount'] as int?,
      collectionCount: json['CollectionCount'] as int?,
      commendImage: json['CommendImage'] as String?,
      cover: json['Cover'] as String?,
      description: json['Description'] as String?,
      forMan: json['ForMan'] as bool?,
      isCheck: json['IsCheck'] as bool?,
      listId: json['ListId'] as int?,
      title: json['Title'] as String?,
      updateTime: json['UpdateTime'] as String?,
      userName: json['UserName'] as String?,
      commendCount: json['CommendCount'] as int?,
    );

Map<String, dynamic> _$BookListToJson(BookList instance) => <String, dynamic>{
      'AddTime': instance.addTime,
      'BookCount': instance.bookCount,
      'CollectionCount': instance.collectionCount,
      'CommendCount': instance.commendCount,
      'Cover': instance.cover,
      'Description': instance.description,
      'ForMan': instance.forMan,
      'IsCheck': instance.isCheck,
      'ListId': instance.listId,
      'Title': instance.title,
      'UpdateTime': instance.updateTime,
      'UserName': instance.userName,
      'CommendImage': instance.commendImage,
    };

BookListRoot _$BookListRootFromJson(Map<String, dynamic> json) => BookListRoot(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BookList.fromJson(e as Map<String, dynamic>))
          .toList(),
      info: json['info'] as String?,
      status: json['status'] as int?,
    );

Map<String, dynamic> _$BookListRootToJson(BookListRoot instance) =>
    <String, dynamic>{
      'status': instance.status,
      'info': instance.info,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };
