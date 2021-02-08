// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_list_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookListDetail _$BookListDetailFromJson(Map<String, dynamic> json) {
  return BookListDetail(
    author: json['Author'] as String?,
    bookIamge: json['BookImage'] as String?,
    bookId: json['BookId'] as int?,
    bookName: json['BookName'] as String?,
    categoryName: json['CategoryName'] as String?,
    description: json['Description'] as String?,
    id: json['Id'] as int?,
    score: (json['Score'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$BookListDetailToJson(BookListDetail instance) =>
    <String, dynamic>{
      'Author': instance.author,
      'Id': instance.id,
      'BookId': instance.bookId,
      'BookName': instance.bookName,
      'BookImage': instance.bookIamge,
      'CategoryName': instance.categoryName,
      'Score': instance.score,
      'Description': instance.description,
    };

BookListDetailData _$BookListDetailDataFromJson(Map<String, dynamic> json) {
  return BookListDetailData(
    addTime: json['AddTime'] as String?,
    bookList: (json['BookList'] as List<dynamic>?)
        ?.map((e) => BookListDetail.fromJson(e as Map<String, dynamic>))
        .toList(),
    cover: json['Cover'] as String?,
    description: json['Description'] as String?,
    forMan: json['ForMan'] as bool?,
    isCheck: json['IsCheck'] as bool?,
    isRecycle: json['IsRecycle'] as bool?,
    listId: json['ListId'] as int?,
    title: json['Title'] as String?,
    updateTime: json['UpdateTime'] as String?,
    userName: json['UserName'] as String?,
  );
}

Map<String, dynamic> _$BookListDetailDataToJson(BookListDetailData instance) =>
    <String, dynamic>{
      'ListId': instance.listId,
      'UserName': instance.userName,
      'Cover': instance.cover,
      'IsCheck': instance.isCheck,
      'IsRecycle': instance.isRecycle,
      'Title': instance.title,
      'ForMan': instance.forMan,
      'Description': instance.description,
      'AddTime': instance.addTime,
      'UpdateTime': instance.updateTime,
      'BookList': instance.bookList?.map((e) => e.toJson()).toList(),
    };

BookListDetailRoot _$BookListDetailRootFromJson(Map<String, dynamic> json) {
  return BookListDetailRoot(
    data: json['data'] == null
        ? null
        : BookListDetailData.fromJson(json['data'] as Map<String, dynamic>),
    info: json['info'] as String?,
    status: json['status'] as int?,
  );
}

Map<String, dynamic> _$BookListDetailRootToJson(BookListDetailRoot instance) =>
    <String, dynamic>{
      'data': instance.data?.toJson(),
      'status': instance.status,
      'info': instance.info,
    };
