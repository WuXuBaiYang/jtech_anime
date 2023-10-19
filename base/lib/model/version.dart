import 'package:jtech_anime_base/base.dart';

/*
* app版本信息
* @author wuxubaiyang
* @Time 2023/3/9 17:53
*/
class AppVersion extends BaseModel {
  // 平台信息
  final String platform;

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
  final String sha256checksum;

  // 文件大小
  final int fileLength;

  // 安装路径
  final String installUrl;

  AppVersion.from(obj)
      : platform = obj['platform'] ?? '',
        name = obj['name'] ?? '',
        nameCN = obj['name_cn'] ?? '',
        version = obj['version'] ?? '',
        versionCode = obj['version_code'] ?? 0,
        changelog = obj['changelog'] ?? '',
        sha256checksum = obj['sha256checksum'] ?? '',
        fileLength = obj['file_length'] ?? 0,
        installUrl = obj['install_url'] ?? '';

  // 获取文件大小
  String get fileSize => FileTool.formatSize(fileLength, lowerCase: true);

  // 校验sha256是否一致
  bool checkSha256(String sha256) {
    if (sha256checksum.isEmpty) return true;
    return sha256checksum == sha256;
  }

  // 检查是否存在版本更新
  Future<bool> checkUpdate() async {
    if (versionCode <= 0) return false;
    final buildNumber = await Tool.buildNumber;
    return versionCode > (int.tryParse(buildNumber) ?? 0);
  }
}
