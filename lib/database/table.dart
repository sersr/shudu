
class BookCache {
  BookCache({
    this.chapterId,
    this.img,
    this.lastChapter,
    this.name,
    this.updateTime,
    this.id,
    this.isTop,
    this.sortKey,
    this.isNew,
    this.page,
    this.isShow,
  });
  final String? name;
  final String? img;
  final String? updateTime;
  final String? lastChapter;
  final int? chapterId;
  final int? id;
  final int? sortKey;
  final int? isTop;
  final int? page;
  final int? isNew;
  final int? isShow;

  factory BookCache.fromMap(Map<String, dynamic> map) {
    return BookCache(
      img: map['img'] as String?,
      updateTime: map['updateTime'] as String?,
      lastChapter: map['lastChapter'] as String?,
      chapterId: map['chapterId'] as int?,
      id: map['bookId'] as int?,
      name: map['name'] as String?,
      sortKey: map['sortKey'] as int?,
      isTop: map['isTop'] as int?,
      page: map['cPage'] as int?,
      isNew: map['isNew'] as int?,
      isShow: map['isShow'] as int? ?? 0,
    );
  }
}
