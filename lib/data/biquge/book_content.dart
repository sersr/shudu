import 'package:json_annotation/json_annotation.dart';
part 'book_content.g.dart';

@JsonSerializable()
class BookContent {
  const BookContent({this.cid, this.cname, this.content, this.hasContent, this.id, this.name, this.nid, this.pid});
  final int? cid;
  final String? cname;
  final String? content;
  final int? hasContent;
  final int? id;
  final String? name;
  final int? nid;
  final int? pid;
  factory BookContent.fromJson(Map<String, dynamic> json) => _$BookContentFromJson(json);
  Map<String, dynamic> toJson() => _$BookContentToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }

  BookContent copyWith(
      {int? cid, String? cname, String? content, hasContent, int? id, String? name, int? nid, int? pid}) {
    return BookContent(
      cid: cid ?? this.cid,
      cname: cname ?? this.cname,
      content: content ?? this.content,
      hasContent: hasContent ?? this.hasContent,
      id: id ?? this.id,
      name: name ?? this.name,
      nid: nid ?? this.nid,
      pid: pid ?? this.pid,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class BookContentRoot {
  const BookContentRoot({this.data, this.info, this.status});
  final BookContent? data;
  final String? info;
  final int? status;
  factory BookContentRoot.fromJson(Map<String, dynamic> json) => _$BookContentRootFromJson(json);
  Map<String, dynamic> toJson() => _$BookContentRootToJson(this);
}
