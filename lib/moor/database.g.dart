// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class BookInfo extends DataClass implements Insertable<BookInfo> {
  final int id;
  final String name;
  final int bookId;
  final int chapterId;
  final String img;
  final String updateTime;
  final String lastChapter;
  final int sortKey;
  final int page;
  final bool isTop;
  final bool isNew;
  final bool isShow;
  BookInfo(
      {required this.id,
      required this.name,
      required this.bookId,
      required this.chapterId,
      required this.img,
      required this.updateTime,
      required this.lastChapter,
      required this.sortKey,
      required this.page,
      required this.isTop,
      required this.isNew,
      required this.isShow});
  factory BookInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return BookInfo(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}body'])!,
      bookId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}book_id'])!,
      chapterId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}chapter_id'])!,
      img: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}img'])!,
      updateTime: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}update_time'])!,
      lastChapter: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_chapter'])!,
      sortKey: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sort_key'])!,
      page: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}page'])!,
      isTop: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_top'])!,
      isNew: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_new'])!,
      isShow: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_show'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(name);
    map['book_id'] = Variable<int>(bookId);
    map['chapter_id'] = Variable<int>(chapterId);
    map['img'] = Variable<String>(img);
    map['update_time'] = Variable<String>(updateTime);
    map['last_chapter'] = Variable<String>(lastChapter);
    map['sort_key'] = Variable<int>(sortKey);
    map['page'] = Variable<int>(page);
    map['is_top'] = Variable<bool>(isTop);
    map['is_new'] = Variable<bool>(isNew);
    map['is_show'] = Variable<bool>(isShow);
    return map;
  }

  BookInfosCompanion toCompanion(bool nullToAbsent) {
    return BookInfosCompanion(
      id: Value(id),
      name: Value(name),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      img: Value(img),
      updateTime: Value(updateTime),
      lastChapter: Value(lastChapter),
      sortKey: Value(sortKey),
      page: Value(page),
      isTop: Value(isTop),
      isNew: Value(isNew),
      isShow: Value(isShow),
    );
  }

  factory BookInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return BookInfo(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      img: serializer.fromJson<String>(json['img']),
      updateTime: serializer.fromJson<String>(json['updateTime']),
      lastChapter: serializer.fromJson<String>(json['lastChapter']),
      sortKey: serializer.fromJson<int>(json['sortKey']),
      page: serializer.fromJson<int>(json['page']),
      isTop: serializer.fromJson<bool>(json['isTop']),
      isNew: serializer.fromJson<bool>(json['isNew']),
      isShow: serializer.fromJson<bool>(json['isShow']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'bookId': serializer.toJson<int>(bookId),
      'chapterId': serializer.toJson<int>(chapterId),
      'img': serializer.toJson<String>(img),
      'updateTime': serializer.toJson<String>(updateTime),
      'lastChapter': serializer.toJson<String>(lastChapter),
      'sortKey': serializer.toJson<int>(sortKey),
      'page': serializer.toJson<int>(page),
      'isTop': serializer.toJson<bool>(isTop),
      'isNew': serializer.toJson<bool>(isNew),
      'isShow': serializer.toJson<bool>(isShow),
    };
  }

  BookInfo copyWith(
          {int? id,
          String? name,
          int? bookId,
          int? chapterId,
          String? img,
          String? updateTime,
          String? lastChapter,
          int? sortKey,
          int? page,
          bool? isTop,
          bool? isNew,
          bool? isShow}) =>
      BookInfo(
        id: id ?? this.id,
        name: name ?? this.name,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        img: img ?? this.img,
        updateTime: updateTime ?? this.updateTime,
        lastChapter: lastChapter ?? this.lastChapter,
        sortKey: sortKey ?? this.sortKey,
        page: page ?? this.page,
        isTop: isTop ?? this.isTop,
        isNew: isNew ?? this.isNew,
        isShow: isShow ?? this.isShow,
      );
  @override
  String toString() {
    return (StringBuffer('BookInfo(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('img: $img, ')
          ..write('updateTime: $updateTime, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('sortKey: $sortKey, ')
          ..write('page: $page, ')
          ..write('isTop: $isTop, ')
          ..write('isNew: $isNew, ')
          ..write('isShow: $isShow')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          name.hashCode,
          $mrjc(
              bookId.hashCode,
              $mrjc(
                  chapterId.hashCode,
                  $mrjc(
                      img.hashCode,
                      $mrjc(
                          updateTime.hashCode,
                          $mrjc(
                              lastChapter.hashCode,
                              $mrjc(
                                  sortKey.hashCode,
                                  $mrjc(
                                      page.hashCode,
                                      $mrjc(
                                          isTop.hashCode,
                                          $mrjc(isNew.hashCode,
                                              isShow.hashCode))))))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookInfo &&
          other.id == this.id &&
          other.name == this.name &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.img == this.img &&
          other.updateTime == this.updateTime &&
          other.lastChapter == this.lastChapter &&
          other.sortKey == this.sortKey &&
          other.page == this.page &&
          other.isTop == this.isTop &&
          other.isNew == this.isNew &&
          other.isShow == this.isShow);
}

class BookInfosCompanion extends UpdateCompanion<BookInfo> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> bookId;
  final Value<int> chapterId;
  final Value<String> img;
  final Value<String> updateTime;
  final Value<String> lastChapter;
  final Value<int> sortKey;
  final Value<int> page;
  final Value<bool> isTop;
  final Value<bool> isNew;
  final Value<bool> isShow;
  const BookInfosCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.img = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.page = const Value.absent(),
    this.isTop = const Value.absent(),
    this.isNew = const Value.absent(),
    this.isShow = const Value.absent(),
  });
  BookInfosCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int bookId,
    required int chapterId,
    required String img,
    required String updateTime,
    required String lastChapter,
    required int sortKey,
    required int page,
    required bool isTop,
    required bool isNew,
    required bool isShow,
  })   : name = Value(name),
        bookId = Value(bookId),
        chapterId = Value(chapterId),
        img = Value(img),
        updateTime = Value(updateTime),
        lastChapter = Value(lastChapter),
        sortKey = Value(sortKey),
        page = Value(page),
        isTop = Value(isTop),
        isNew = Value(isNew),
        isShow = Value(isShow);
  static Insertable<BookInfo> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? bookId,
    Expression<int>? chapterId,
    Expression<String>? img,
    Expression<String>? updateTime,
    Expression<String>? lastChapter,
    Expression<int>? sortKey,
    Expression<int>? page,
    Expression<bool>? isTop,
    Expression<bool>? isNew,
    Expression<bool>? isShow,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'body': name,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (img != null) 'img': img,
      if (updateTime != null) 'update_time': updateTime,
      if (lastChapter != null) 'last_chapter': lastChapter,
      if (sortKey != null) 'sort_key': sortKey,
      if (page != null) 'page': page,
      if (isTop != null) 'is_top': isTop,
      if (isNew != null) 'is_new': isNew,
      if (isShow != null) 'is_show': isShow,
    });
  }

  BookInfosCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? bookId,
      Value<int>? chapterId,
      Value<String>? img,
      Value<String>? updateTime,
      Value<String>? lastChapter,
      Value<int>? sortKey,
      Value<int>? page,
      Value<bool>? isTop,
      Value<bool>? isNew,
      Value<bool>? isShow}) {
    return BookInfosCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      img: img ?? this.img,
      updateTime: updateTime ?? this.updateTime,
      lastChapter: lastChapter ?? this.lastChapter,
      sortKey: sortKey ?? this.sortKey,
      page: page ?? this.page,
      isTop: isTop ?? this.isTop,
      isNew: isNew ?? this.isNew,
      isShow: isShow ?? this.isShow,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['body'] = Variable<String>(name.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (img.present) {
      map['img'] = Variable<String>(img.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<String>(updateTime.value);
    }
    if (lastChapter.present) {
      map['last_chapter'] = Variable<String>(lastChapter.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<int>(sortKey.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (isTop.present) {
      map['is_top'] = Variable<bool>(isTop.value);
    }
    if (isNew.present) {
      map['is_new'] = Variable<bool>(isNew.value);
    }
    if (isShow.present) {
      map['is_show'] = Variable<bool>(isShow.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookInfosCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('img: $img, ')
          ..write('updateTime: $updateTime, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('sortKey: $sortKey, ')
          ..write('page: $page, ')
          ..write('isTop: $isTop, ')
          ..write('isNew: $isNew, ')
          ..write('isShow: $isShow')
          ..write(')'))
        .toString();
  }
}

class $BookInfosTable extends BookInfos
    with TableInfo<$BookInfosTable, BookInfo> {
  final GeneratedDatabase _db;
  final String? _alias;
  $BookInfosTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedIntColumn id = _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedTextColumn name = _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn(
      'body',
      $tableName,
      false,
    );
  }

  final VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedIntColumn bookId = _constructBookId();
  GeneratedIntColumn _constructBookId() {
    return GeneratedIntColumn(
      'book_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _chapterIdMeta = const VerificationMeta('chapterId');
  @override
  late final GeneratedIntColumn chapterId = _constructChapterId();
  GeneratedIntColumn _constructChapterId() {
    return GeneratedIntColumn(
      'chapter_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _imgMeta = const VerificationMeta('img');
  @override
  late final GeneratedTextColumn img = _constructImg();
  GeneratedTextColumn _constructImg() {
    return GeneratedTextColumn(
      'img',
      $tableName,
      false,
    );
  }

  final VerificationMeta _updateTimeMeta = const VerificationMeta('updateTime');
  @override
  late final GeneratedTextColumn updateTime = _constructUpdateTime();
  GeneratedTextColumn _constructUpdateTime() {
    return GeneratedTextColumn(
      'update_time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lastChapterMeta =
      const VerificationMeta('lastChapter');
  @override
  late final GeneratedTextColumn lastChapter = _constructLastChapter();
  GeneratedTextColumn _constructLastChapter() {
    return GeneratedTextColumn(
      'last_chapter',
      $tableName,
      false,
    );
  }

  final VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedIntColumn sortKey = _constructSortKey();
  GeneratedIntColumn _constructSortKey() {
    return GeneratedIntColumn(
      'sort_key',
      $tableName,
      false,
    );
  }

  final VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedIntColumn page = _constructPage();
  GeneratedIntColumn _constructPage() {
    return GeneratedIntColumn(
      'page',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isTopMeta = const VerificationMeta('isTop');
  @override
  late final GeneratedBoolColumn isTop = _constructIsTop();
  GeneratedBoolColumn _constructIsTop() {
    return GeneratedBoolColumn(
      'is_top',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isNewMeta = const VerificationMeta('isNew');
  @override
  late final GeneratedBoolColumn isNew = _constructIsNew();
  GeneratedBoolColumn _constructIsNew() {
    return GeneratedBoolColumn(
      'is_new',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isShowMeta = const VerificationMeta('isShow');
  @override
  late final GeneratedBoolColumn isShow = _constructIsShow();
  GeneratedBoolColumn _constructIsShow() {
    return GeneratedBoolColumn(
      'is_show',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        bookId,
        chapterId,
        img,
        updateTime,
        lastChapter,
        sortKey,
        page,
        isTop,
        isNew,
        isShow
      ];
  @override
  $BookInfosTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'book_infos';
  @override
  final String actualTableName = 'book_infos';
  @override
  VerificationContext validateIntegrity(Insertable<BookInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['body']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('img')) {
      context.handle(
          _imgMeta, img.isAcceptableOrUnknown(data['img']!, _imgMeta));
    } else if (isInserting) {
      context.missing(_imgMeta);
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    } else if (isInserting) {
      context.missing(_updateTimeMeta);
    }
    if (data.containsKey('last_chapter')) {
      context.handle(
          _lastChapterMeta,
          lastChapter.isAcceptableOrUnknown(
              data['last_chapter']!, _lastChapterMeta));
    } else if (isInserting) {
      context.missing(_lastChapterMeta);
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta,
          sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
          _pageMeta, page.isAcceptableOrUnknown(data['page']!, _pageMeta));
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('is_top')) {
      context.handle(
          _isTopMeta, isTop.isAcceptableOrUnknown(data['is_top']!, _isTopMeta));
    } else if (isInserting) {
      context.missing(_isTopMeta);
    }
    if (data.containsKey('is_new')) {
      context.handle(
          _isNewMeta, isNew.isAcceptableOrUnknown(data['is_new']!, _isNewMeta));
    } else if (isInserting) {
      context.missing(_isNewMeta);
    }
    if (data.containsKey('is_show')) {
      context.handle(_isShowMeta,
          isShow.isAcceptableOrUnknown(data['is_show']!, _isShowMeta));
    } else if (isInserting) {
      context.missing(_isShowMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return BookInfo.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $BookInfosTable createAlias(String alias) {
    return $BookInfosTable(_db, alias);
  }
}

class BookContent extends DataClass implements Insertable<BookContent> {
  final int id;
  final int bookId;
  final String cname;
  final int cid;
  final int nid;
  final int pid;
  final String content;
  final bool hasContent;
  BookContent(
      {required this.id,
      required this.bookId,
      required this.cname,
      required this.cid,
      required this.nid,
      required this.pid,
      required this.content,
      required this.hasContent});
  factory BookContent.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return BookContent(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      bookId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}book_id'])!,
      cname: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}cname'])!,
      cid: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}cid'])!,
      nid: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}nid'])!,
      pid: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pid'])!,
      content: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}content'])!,
      hasContent: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}has_content'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['cname'] = Variable<String>(cname);
    map['cid'] = Variable<int>(cid);
    map['nid'] = Variable<int>(nid);
    map['pid'] = Variable<int>(pid);
    map['content'] = Variable<String>(content);
    map['has_content'] = Variable<bool>(hasContent);
    return map;
  }

  BookContentsCompanion toCompanion(bool nullToAbsent) {
    return BookContentsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      cname: Value(cname),
      cid: Value(cid),
      nid: Value(nid),
      pid: Value(pid),
      content: Value(content),
      hasContent: Value(hasContent),
    );
  }

  factory BookContent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return BookContent(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      cname: serializer.fromJson<String>(json['cname']),
      cid: serializer.fromJson<int>(json['cid']),
      nid: serializer.fromJson<int>(json['nid']),
      pid: serializer.fromJson<int>(json['pid']),
      content: serializer.fromJson<String>(json['content']),
      hasContent: serializer.fromJson<bool>(json['hasContent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'cname': serializer.toJson<String>(cname),
      'cid': serializer.toJson<int>(cid),
      'nid': serializer.toJson<int>(nid),
      'pid': serializer.toJson<int>(pid),
      'content': serializer.toJson<String>(content),
      'hasContent': serializer.toJson<bool>(hasContent),
    };
  }

  BookContent copyWith(
          {int? id,
          int? bookId,
          String? cname,
          int? cid,
          int? nid,
          int? pid,
          String? content,
          bool? hasContent}) =>
      BookContent(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        cname: cname ?? this.cname,
        cid: cid ?? this.cid,
        nid: nid ?? this.nid,
        pid: pid ?? this.pid,
        content: content ?? this.content,
        hasContent: hasContent ?? this.hasContent,
      );
  @override
  String toString() {
    return (StringBuffer('BookContent(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('cname: $cname, ')
          ..write('cid: $cid, ')
          ..write('nid: $nid, ')
          ..write('pid: $pid, ')
          ..write('content: $content, ')
          ..write('hasContent: $hasContent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          bookId.hashCode,
          $mrjc(
              cname.hashCode,
              $mrjc(
                  cid.hashCode,
                  $mrjc(
                      nid.hashCode,
                      $mrjc(pid.hashCode,
                          $mrjc(content.hashCode, hasContent.hashCode))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookContent &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.cname == this.cname &&
          other.cid == this.cid &&
          other.nid == this.nid &&
          other.pid == this.pid &&
          other.content == this.content &&
          other.hasContent == this.hasContent);
}

class BookContentsCompanion extends UpdateCompanion<BookContent> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> cname;
  final Value<int> cid;
  final Value<int> nid;
  final Value<int> pid;
  final Value<String> content;
  final Value<bool> hasContent;
  const BookContentsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.cname = const Value.absent(),
    this.cid = const Value.absent(),
    this.nid = const Value.absent(),
    this.pid = const Value.absent(),
    this.content = const Value.absent(),
    this.hasContent = const Value.absent(),
  });
  BookContentsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String cname,
    required int cid,
    required int nid,
    required int pid,
    required String content,
    required bool hasContent,
  })   : bookId = Value(bookId),
        cname = Value(cname),
        cid = Value(cid),
        nid = Value(nid),
        pid = Value(pid),
        content = Value(content),
        hasContent = Value(hasContent);
  static Insertable<BookContent> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? cname,
    Expression<int>? cid,
    Expression<int>? nid,
    Expression<int>? pid,
    Expression<String>? content,
    Expression<bool>? hasContent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (cname != null) 'cname': cname,
      if (cid != null) 'cid': cid,
      if (nid != null) 'nid': nid,
      if (pid != null) 'pid': pid,
      if (content != null) 'content': content,
      if (hasContent != null) 'has_content': hasContent,
    });
  }

  BookContentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<String>? cname,
      Value<int>? cid,
      Value<int>? nid,
      Value<int>? pid,
      Value<String>? content,
      Value<bool>? hasContent}) {
    return BookContentsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      cname: cname ?? this.cname,
      cid: cid ?? this.cid,
      nid: nid ?? this.nid,
      pid: pid ?? this.pid,
      content: content ?? this.content,
      hasContent: hasContent ?? this.hasContent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (cname.present) {
      map['cname'] = Variable<String>(cname.value);
    }
    if (cid.present) {
      map['cid'] = Variable<int>(cid.value);
    }
    if (nid.present) {
      map['nid'] = Variable<int>(nid.value);
    }
    if (pid.present) {
      map['pid'] = Variable<int>(pid.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (hasContent.present) {
      map['has_content'] = Variable<bool>(hasContent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookContentsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('cname: $cname, ')
          ..write('cid: $cid, ')
          ..write('nid: $nid, ')
          ..write('pid: $pid, ')
          ..write('content: $content, ')
          ..write('hasContent: $hasContent')
          ..write(')'))
        .toString();
  }
}

class $BookContentsTable extends BookContents
    with TableInfo<$BookContentsTable, BookContent> {
  final GeneratedDatabase _db;
  final String? _alias;
  $BookContentsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedIntColumn id = _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedIntColumn bookId = _constructBookId();
  GeneratedIntColumn _constructBookId() {
    return GeneratedIntColumn(
      'book_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _cnameMeta = const VerificationMeta('cname');
  @override
  late final GeneratedTextColumn cname = _constructCname();
  GeneratedTextColumn _constructCname() {
    return GeneratedTextColumn(
      'cname',
      $tableName,
      false,
    );
  }

  final VerificationMeta _cidMeta = const VerificationMeta('cid');
  @override
  late final GeneratedIntColumn cid = _constructCid();
  GeneratedIntColumn _constructCid() {
    return GeneratedIntColumn(
      'cid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _nidMeta = const VerificationMeta('nid');
  @override
  late final GeneratedIntColumn nid = _constructNid();
  GeneratedIntColumn _constructNid() {
    return GeneratedIntColumn(
      'nid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _pidMeta = const VerificationMeta('pid');
  @override
  late final GeneratedIntColumn pid = _constructPid();
  GeneratedIntColumn _constructPid() {
    return GeneratedIntColumn(
      'pid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedTextColumn content = _constructContent();
  GeneratedTextColumn _constructContent() {
    return GeneratedTextColumn(
      'content',
      $tableName,
      false,
    );
  }

  final VerificationMeta _hasContentMeta = const VerificationMeta('hasContent');
  @override
  late final GeneratedBoolColumn hasContent = _constructHasContent();
  GeneratedBoolColumn _constructHasContent() {
    return GeneratedBoolColumn(
      'has_content',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, cname, cid, nid, pid, content, hasContent];
  @override
  $BookContentsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'book_contents';
  @override
  final String actualTableName = 'book_contents';
  @override
  VerificationContext validateIntegrity(Insertable<BookContent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('cname')) {
      context.handle(
          _cnameMeta, cname.isAcceptableOrUnknown(data['cname']!, _cnameMeta));
    } else if (isInserting) {
      context.missing(_cnameMeta);
    }
    if (data.containsKey('cid')) {
      context.handle(
          _cidMeta, cid.isAcceptableOrUnknown(data['cid']!, _cidMeta));
    } else if (isInserting) {
      context.missing(_cidMeta);
    }
    if (data.containsKey('nid')) {
      context.handle(
          _nidMeta, nid.isAcceptableOrUnknown(data['nid']!, _nidMeta));
    } else if (isInserting) {
      context.missing(_nidMeta);
    }
    if (data.containsKey('pid')) {
      context.handle(
          _pidMeta, pid.isAcceptableOrUnknown(data['pid']!, _pidMeta));
    } else if (isInserting) {
      context.missing(_pidMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('has_content')) {
      context.handle(
          _hasContentMeta,
          hasContent.isAcceptableOrUnknown(
              data['has_content']!, _hasContentMeta));
    } else if (isInserting) {
      context.missing(_hasContentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return BookContent.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $BookContentsTable createAlias(String alias) {
    return $BookContentsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $BookInfosTable bookInfos = $BookInfosTable(this);
  late final $BookContentsTable bookContents = $BookContentsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [bookInfos, bookContents];
}
