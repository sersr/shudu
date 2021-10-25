// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('download', () async {
    final dio = Dio();
    final result = await dio.get<List<int>>(
        'http://statics.rungean.com/static/book/zip/22/42763.zip',
        options: Options(responseType: ResponseType.bytes));
    final data = result.data;
    if (data != null) {
      final z = ZipDecoder().decodeBytes(data);
      for (var file in z) {
        final fileName = file.name;
        print(fileName);
        if (file.isFile) {
          final bytes = file.content as List<int>;
          final data = jsonDecode(utf8.decode(bytes));
          print(data);
        }
      }
    }
  });
}
