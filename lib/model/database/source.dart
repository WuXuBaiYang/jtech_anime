import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/tool.dart';

part 'source.g.dart';

@collection
class AnimeSource {
  Id id = Isar.autoIncrement;

  // 资源key（唯一）
  @Index(unique: true, replace: true)
  String key = '';

  // 资源名
  String name = '';

  // 资源站图标
  String logoUrl = '';

  // 资源站地址
  String homepage = '';

  // 资源解析版本号
  String version = '';

  // 最后更新时间
  DateTime lastEditDate = DateTime(1);

  // 配置文件路径
  String fileUri = '';

  // 色值
  String color = '';

  // 获取色值
  Color getColor() => Tool.parseColor(color, Colors.white);

  static AnimeSource from(obj) {
    return AnimeSource()
      ..key = obj['key'] ?? ''
      ..name = obj['name'] ?? ''
      ..logoUrl = obj['logoUrl'] ?? ''
      ..homepage = obj['homepage'] ?? ''
      ..version = obj['version'] ?? ''
      ..color = obj['color'] ?? '0xffffff'
      ..lastEditDate =
          DateTime.tryParse(obj['lastEditDate'] ?? '') ?? DateTime(1)
      ..fileUri = obj['fileUri'] ?? '';
  }
}
