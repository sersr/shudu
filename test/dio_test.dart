import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/api/api.dart';
import 'package:shudu/event/base/type_adapter.dart';
import 'package:path/path.dart';

void main() async {
  test('dio download', () async {
    final dio = dioCreater();
    final path = 'shifangwusheng.jpg';
    final url = Api.imageUrl(path);
    final data = await dio.get<ResponseBody>(url,
        options: Options(responseType: ResponseType.stream));
    // print(data);
    final f = File(join(Directory.current.path, path));
    f.createSync(recursive: true);
    final o = f.openSync(mode: FileMode.write);
    final img = await data.data?.stream.toList();
    if (img != null) img.forEach(o.writeFromSync);
    await dio.download(url, join(Directory.current.path, 'down.jpg'));
  });
}
