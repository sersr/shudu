part of 'nop_database.dart';

class ZhangduCache extends Table {
  ZhangduCache({
    this.id,
    this.bookId,
    this.name,
    this.pinyin,
    this.picture,
    this.chapterId,
    this.chapterName,
    this.chapterUpdateTime,
    this.page,
    this.sortKey,
    this.isTop,
    this.isNew,
    this.isShow,
  });
  @NopItem(primaryKey: true)
  int? id;
  int? bookId;
  String? name;
  String? pinyin;
  String? picture;
  int? chapterId;
  String? chapterName;
  String? chapterUpdateTime;
  int? page;
  int? sortKey;
  bool? isTop;
  bool? isNew;
  bool? isShow;
  @override
  Map<String, dynamic> toJson() {
    return _ZhangduCache_toJson(this);
  }
}

class ZhangduContent extends Table {
  ZhangduContent({
    this.id,
    this.bookId,
    this.contentId,
    this.name,
    this.sort,
    this.data,
  });

  @NopItem(primaryKey: true)
  int? id;
  int? bookId;
  int? contentId;
  String? name;
  int? sort;
  String? data;

  @override
  Map<String, dynamic> toJson() {
    return _ZhangduContent_toJson(this);
  }
}

class ZhangduIndex extends Table {
  ZhangduIndex({
    this.id,
    this.bookId,
    this.data,
    this.itemCounts,
    this.cacheItemCounts,
  });

  @NopItem(primaryKey: true)
  int? id;
  int? bookId;
  String? data;
  int? itemCounts;
  int? cacheItemCounts;
  @override
  Map<String, dynamic> toJson() => _ZhangduIndex_toJson(this);
}
