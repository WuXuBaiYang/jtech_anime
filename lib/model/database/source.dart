import 'dart:io';
import 'package:isar/isar.dart';

part 'source.g.dart';

@collection
class SourceConfig {
  Id id = Isar.autoIncrement;

  // 资源key（唯一）
  @Index(unique: true, replace: true)
  String key = '';

  // 资源名
  String name = '';

  // 资源站图标
  String logoUrl = '';

  // 配置文件路径
  String filePath = '';

  // 判断是否为默认配置
  @Ignore()
  bool isDefault = false;

  // 配置文件内容
  @Ignore()
  String? _content;

  // 获取配置文件内容
  @Ignore()
  Future<String> get content async =>
      _content ??= await File(filePath).readAsString();

  SourceConfig({
    required this.key,
    this.name = '',
    this.logoUrl = '',
    this.filePath = '',
    this.isDefault = false,
  });

  SourceConfig.fromContent({
    required this.key,
    required String content,
    this.name = '',
    this.logoUrl = '',
    this.filePath = '',
    this.isDefault = false,
  }) : _content = content;
}
