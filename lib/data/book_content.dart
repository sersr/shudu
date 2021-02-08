import 'package:json_annotation/json_annotation.dart';

part 'book_content.g.dart';

@JsonSerializable()
class BookContent {
  BookContent({this.cid, this.cname, this.content, this.hasContent, this.id, this.name, this.nid, this.pid});
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
}

@JsonSerializable(explicitToJson: true)
class BookContentRoot {
  BookContentRoot({this.data, this.info, this.status});
  final BookContent? data;
  final String? info;
  final int? status;
  factory BookContentRoot.fromJson(Map<String, dynamic> json) => _$BookContentRootFromJson(json);
  Map<String, dynamic> toJson() => _$BookContentRootToJson(this);
}
