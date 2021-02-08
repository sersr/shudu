// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookVote _$BookVoteFromJson(Map<String, dynamic> json) {
  return BookVote(
    bookId: json['BookId'] as int?,
    scroe: (json['Score'] as num?)?.toDouble(),
    totalScore: json['TotalScore'] as int?,
    voterCount: json['VoterCount'] as int?,
  );
}

Map<String, dynamic> _$BookVoteToJson(BookVote instance) => <String, dynamic>{
      'BookId': instance.bookId,
      'TotalScore': instance.totalScore,
      'VoterCount': instance.voterCount,
      'Score': instance.scroe,
    };

SameUserBook _$SameUserBookFromJson(Map<String, dynamic> json) {
  return SameUserBook(
    id: json['Id'] as int?,
    img: json['Img'] as String?,
    lastChapter: json['LastChapter'] as String?,
    lastChapterId: json['LastChapterId'] as int?,
    name: json['Name'] as String?,
    score: (json['Score'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$SameUserBookToJson(SameUserBook instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Img': instance.img,
      'LastChapterId': instance.lastChapterId,
      'LastChapter': instance.lastChapter,
      'Score': instance.score,
    };

SameCategoryBook _$SameCategoryBookFromJson(Map<String, dynamic> json) {
  return SameCategoryBook(
    id: json['Id'] as int?,
    img: json['Img'] as String?,
    name: json['Name'] as String?,
    score: (json['Score'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$SameCategoryBookToJson(SameCategoryBook instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Img': instance.img,
      'Score': instance.score,
    };

BookInfo _$BookInfoFromJson(Map<String, dynamic> json) {
  return BookInfo(
    author: json['Author'] as String?,
    bookStatus: json['BookStatus'] as String?,
    bookVote: json['BookVote'] == null
        ? null
        : BookVote.fromJson(json['BookVote'] as Map<String, dynamic>),
    cId: json['CId'] as int?,
    cName: json['CName'] as String?,
    desc: json['Desc'] as String?,
    id: json['Id'] as int?,
    img: json['Img'] as String?,
    lastChapterId: json['LastChapterId'] as int?,
    lastTime: json['LastTime'] as String?,
    name: json['Name'] as String?,
    sameCategoryBooks: (json['SameCategoryBooks'] as List<dynamic>?)
        ?.map((e) => SameCategoryBook.fromJson(e as Map<String, dynamic>))
        .toList(),
    sameUserBooks: (json['SameUserBooks'] as List<dynamic>?)
        ?.map((e) => SameUserBook.fromJson(e as Map<String, dynamic>))
        .toList(),
    firstChapterId: json['FirstChapterId'] as int?,
    lastChapter: json['LastChapter'] as String?,
  );
}

Map<String, dynamic> _$BookInfoToJson(BookInfo instance) => <String, dynamic>{
      'Author': instance.author,
      'BookStatus': instance.bookStatus,
      'BookVote': instance.bookVote?.toJson(),
      'CId': instance.cId,
      'CName': instance.cName,
      'LastTime': instance.lastTime,
      'FirstChapterId': instance.firstChapterId,
      'LastChapter': instance.lastChapter,
      'LastChapterId': instance.lastChapterId,
      'Id': instance.id,
      'Name': instance.name,
      'Img': instance.img,
      'Desc': instance.desc,
      'SameUserBooks': instance.sameUserBooks?.map((e) => e.toJson()).toList(),
      'SameCategoryBooks':
          instance.sameCategoryBooks?.map((e) => e.toJson()).toList(),
    };

BookInfoRoot _$BookInfoRootFromJson(Map<String, dynamic> json) {
  return BookInfoRoot(
    data: json['data'] == null
        ? null
        : BookInfo.fromJson(json['data'] as Map<String, dynamic>),
    info: json['info'] as String?,
    status: json['status'] as int?,
  );
}

Map<String, dynamic> _$BookInfoRootToJson(BookInfoRoot instance) =>
    <String, dynamic>{
      'status': instance.status,
      'info': instance.info,
      'data': instance.data?.toJson(),
    };
