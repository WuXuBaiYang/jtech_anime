import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
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

  // 支持的方法列表
  List<String> functions = [];

  // 是否为nsfw内容
  bool nsfw = false;

  // 是否需要代理
  bool proxy = false;

  // 获取色值
  Color getColor() => Tool.parseColor(color, const Color(0xFFFFEEF4));
}
