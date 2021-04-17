import 'dart:collection';

class Api {
  ///API------------------------------------------------

  // pigqq, pysmei
  static var domains = Queue.of(const ['pigqq', 'pysmei']);

  // 由于 api 解析几乎（都）相同，
  static void moveNext() {
    domains.addLast(domains.removeFirst());
  }

  static int shortid(int id) => (id / 1000 + 1).toInt();

  static String imageUrl(String img) => 'https://imgapixs.${domains.first}.com/BookFiles/BookImages/$img';

  static String contentUrl(int id, int? cid) {
    final sd = shortid(id);
    return 'https://contentxs.${domains.first}.com/BookFiles/Html/$sd/$id/$cid.html';
  }

  static String indexUrl(int id) {
    final sid = shortid(id);
    return 'https://infosxs.${domains.first}.com/BookFiles/Html/$sid/$id/index.html';
  }

  static String infoUrl(int id) {
    final sid = shortid(id);
    return 'https://infosxs.${domains.first}.com/BookFiles/Html/$sid/$id/info.html';
  }

  static String shudanUrl(String c, int index) {
    return 'https://scxs.${domains.first}.com/shudan/man/all/$c/$index.html';
  }

  static String shudanDetailUrl(int? index) {
    assert(index != null);
    return 'https://scxs.${domains.first}.com/shudan/detail/$index.html';
  }

  static String searchUrl(String key) {
    return 'https://souxs.${domains.first}.com/search.aspx?key=$key&page=1&siteid=app2';
  }

  ///API------------------------------------------------

}
