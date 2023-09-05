import 'package:jtech_anime/common/model.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/tool.dart';

/*
* app版本信息
* @author wuxubaiyang
* @Time 2023/3/9 17:53
*/
class AppVersion extends BaseModel {
  // 名称
  final String name;

  // 中文名
  final String nameCN;

  // 版本号
  final String version;

  // 版本号数字
  final int versionCode;

  // 简介
  final String changelog;

  // 文件校验
  final String? sha256checksum;

  // 文件大小
  final int fileLength;

  // 安装地址
  final String installUrl;

  AppVersion.from(obj)
      : name = obj['name'] ?? '',
        nameCN = obj['nameCn'] ?? '',
        version = obj['version'] ?? '',
        versionCode = obj['versionCode'] ?? 0,
        changelog = obj['changelog'] ?? '',
        sha256checksum = obj['sha256checksum'],
        fileLength = obj['fileLength'] ?? 0,
        installUrl = obj['installUrl'] ?? '';

  // 获取文件大小
  String get fileSize => FileTool.formatSize(fileLength, lowerCase: true);

  // 检查是否存在版本更新
  Future<bool> checkUpdate() async {
    if (versionCode <= 0) return false;
    final buildNumber = await Tool.buildNumber;
    return versionCode > (int.tryParse(buildNumber) ?? 0);
  }
}
