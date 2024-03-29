import 'dart:collection';

class Api {
  ///API------------------------------------------------

  // pigqq, pysmei
  // static final _domains = Queue.of(const ['pigqq']);
  static final domains = Queue.of(const ['pysmei']);
  static final domainsSearch = Queue.of(const ['pysmei']);

  // 由于 api 解析几乎（都）相同，
  static void moveNext() {
    domains.addLast(domains.removeFirst());
  }

  static void moveNextSearch() {
    domainsSearch.addLast(domainsSearch.removeFirst());
  }

  static int shortid(int id) => (id / 1000 + 1).toInt();

  static String imageUrl(String img) =>
      'https://imgapixs.pysmei.com/BookFiles/BookImages/$img';

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
    return 'http://scxs.${domains.first}.com/shudan/man/all/$c/$index.html';
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

  // 分类
  static String bookCategory() {
    return 'https://scxs.${domains.first}.com/Categories/BookCategory.html';
  }

  static String categUrl(int categ, String type, int index) {
    return 'https://scxs.${domains.first}.com/Categories/$categ/$type/$index.html';
  }

  ///API------------------------------------------------ end
}

// class ZhangduApi {
//   static const domains = 'rungean.com';
//   static int shortId(int id) {
//     return (id / 2000 + 1).toInt();
//   }

//   static String getBookIndexDetail(int id) {
//     return 'http://statics.rungean.com/static/book/zip/${shortId(id)}/$id.zip';
//   }

//   // search
//   static String hotSearchUrl() {
//     return ' http://statics.rungean.com/static/book/heat/14/heat.json';
//   }

//   static String searchUrl(String query, int pageIndex, int pageSize) {
//     return 'https://api.zhangduxs.com/api/v1/novelsearch?content=$query'
//         '&pageIndex=$pageIndex&pageSize=$pageSize&type=2';
//   }

//   static String sameUsersBooks(String author) {
//     final m = md5.convert(utf8.encode(author));
//     return 'http://statics.rungean.com/static/book/author/$m.json';
//   }
// }

enum ApiType {
  biquge;

  static dynamic fromJson(Object data) {
    if (data is int && data < values.length) {
      return values[data];
    }
    return null;
  }

  int toJson() {
    return index;
  }
}
