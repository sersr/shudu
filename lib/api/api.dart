import 'dart:collection';

class Api {
  ///API------------------------------------------------

  // pigqq, pysmei
  // static final _domains = Queue.of(const ['pigqq']);
  static final domains = Queue.of(const ['pigqq', 'pysmei']);
  static final domainsSearch = Queue.of(const ['pigqq', 'leeyegy']);

  // 由于 api 解析几乎（都）相同，
  static void moveNext() {
    domains.addLast(domains.removeFirst());
  }

  static void moveNextSearch() {
    domainsSearch.addLast(domainsSearch.removeFirst());
  }

  static int shortid(int id) => (id / 1000 + 1).toInt();

  static String imageUrl(String img) =>
      'https://imgapixs.${domains.first}.com/BookFiles/BookImages/$img';

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
    moveNextSearch();
    return 'https://souxs.pigqq.com/search.aspx?key=$key&page=1&siteid=app2';
  }

  // 榜单
  static String topUrl(String catg, String date, int index) {
    return 'https://scxs.${domains.first}.com/top/man/top/$catg/$date/$index.html';
  }

  /// -- 未实现
  // 分类
  static String bookCategory() {
    return 'https://scxs.${domains.first}.com/Categories/BookCategory.html';
  }

  static String categUrl(int categ, String type, int index) {
    return 'https://scxs.${domains.first}.com/Categories/$categ/$type/$index.html';
  }

  ///API------------------------------------------------ end

}
