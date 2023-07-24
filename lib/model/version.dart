import 'package:jtech_anime/common/model.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/tool.dart';

/*
* app版本信息
* @author wuxubaiyang
* @Time 2023/3/9 17:53
*/
class AppVersion extends BaseModel {
  // id
  final String id;

  // 创建时间
  final DateTime createdAt;

  // 名称
  final String name;

  // 中文名
  final String nameCN;

  // 版本号
  final String version;

  // 版本号数字
  final int versionCode;

  // 简介
  final String intro;

  // apk文件id
  final String fileId;

  // 文件校验
  final String sha256checksum;

  // 文件大小
  final int fileLength;

  AppVersion.from(obj)
      : id = obj['id'] ?? '',
        createdAt = DateTime.tryParse(obj['created_at']) ?? DateTime(0),
        name = obj['name'] ?? '',
        nameCN = obj['name_cn'] ?? '',
        version = obj['version'] ?? '',
        versionCode = obj['version_code'] ?? 0,
        intro = obj['intro'] ?? '',
        fileId = obj['file_id'] ?? '',
        sha256checksum = obj['sha256checksum'] ?? '',
        fileLength = obj['file_length'] ?? 0;

  // 获取文件大小
  String get fileSize => FileTool.formatSize(fileLength, lowerCase: true);

  // 检查是否存在版本更新
  Future<bool> checkUpdate() async {
    final buildNumber = await Tool.buildNumber;
    return versionCode > (int.tryParse(buildNumber) ?? 0);
  }
}
