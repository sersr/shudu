class Api {
  ///API------------------------------------------------
  static String domain = 'pigqq';

  static int shortid(int id) => (id / 1000 + 1).toInt();

  static String imageUrl(String img) => 'https://imgapixs.$domain.com/BookFiles/BookImages/$img';

  static String contentUrl(int id, int? cid) {
    final sd = shortid(id);
    return 'https://contentxs.$domain.com/BookFiles/Html/$sd/$id/$cid.html';
  }

  static String indexUrl(int id) {
    final sid = shortid(id);
    return 'https://infosxs.$domain.com/BookFiles/Html/$sid/$id/index.html';
  }

  static String infoUrl(int id) {
    final sid = shortid(id);
    return 'https://infosxs.$domain.com/BookFiles/Html/$sid/$id/info.html';
  }

  static String shudanUrl(String c, int index) {
    return 'https://scxs.$domain.com/shudan/man/all/$c/$index.html';
  }

  static String shudanDetailUrl(int? index) {
    assert(index != null);
    return 'https://scxs.$domain.com/shudan/detail/$index.html';
  }

  static String searchUrl(String key) {
    return 'https://souxs.$domain.com/search.aspx?key=$key&page=1&siteid=app2';
  }

  ///API------------------------------------------------

}
