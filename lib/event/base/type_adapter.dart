import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../provider/provider.dart';

Dio dioCreater() => Dio(
      BaseOptions(
        connectTimeout: 5000,
        sendTimeout: 5000,
        receiveTimeout: 10000,
        headers: {
          HttpHeaders.connectionHeader: 'Keep-Alive',
          HttpHeaders.userAgentHeader:
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                  ' (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36 Edg/90.0.818.56'
        },
      ),
    );

void hiveInit(String path) {
  Hive
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(AxisAdapter())
    ..registerAdapter(TargetPlatformAdapter())
    ..registerAdapter(ThemeModeAdapter())
    ..registerAdapter(PageBuilderAdapter());

  Hive.init(path);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) {
    final colorValue = reader.readInt();
    return Color(colorValue);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }

  @override
  int get typeId => 0;
}

class AxisAdapter extends TypeAdapter<Axis> {
  @override
  Axis read(BinaryReader reader) {
    final index = reader.readInt();
    return Axis.values[index];
  }

  @override
  void write(BinaryWriter writer, Axis axis) {
    writer.writeInt(axis.index);
  }

  @override
  int get typeId => 1;
}

class TargetPlatformAdapter extends TypeAdapter<TargetPlatform> {
  @override
  TargetPlatform read(BinaryReader reader) {
    final index = reader.readInt();
    return TargetPlatform.values[index];
  }

  @override
  void write(BinaryWriter writer, TargetPlatform obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 2;
}

class PageBuilderAdapter extends TypeAdapter<PageBuilder> {
  @override
  PageBuilder read(BinaryReader reader) {
    final index = reader.readInt();
    return PageBuilder.values[index];
  }

  @override
  void write(BinaryWriter writer, PageBuilder obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 3;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  ThemeMode read(BinaryReader reader) {
    final value = reader.readInt();
    return ThemeMode.values[value];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 4;
}
