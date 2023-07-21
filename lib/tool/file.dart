import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'log.dart';

/*
* 文件操作工具方法
* @author wuxubaiyang
* @Time 2022/3/17 16:11
*/
class FileTool {
  // 清除目录文件
  static Future<bool> clearDir([String path = '']) async {
    try {
      final dir = Directory(path);
      if (dir.existsSync()) await dir.delete(recursive: true);
      return true;
    } catch (e) {
      LogTool.e('dir_cache_clear_error：', error: e);
    }
    return false;
  }

  // 解析目录大小
  static Future<String> formatDirSize({
    String path = '',
    bool lowerCase = false,
    int fixed = 1,
  }) async {
    final result = await getDirSize(path);
    return formatSize(result, lowerCase: lowerCase, fixed: fixed);
  }

  // 迭代计算一个目录的大小
  static Future<int> getDirSize(String path, [int size = 0]) async {
    final items = Directory(path).listSync(recursive: true, followLinks: true);
    for (final item in items) {
      if (item is File) {
        size += await item.length();
      } else if (item is Directory) {
        size = await getDirSize(item.absolute.path, size);
      }
    }
    return size;
  }

  // 文件大小对照表
  static final Map<int, String> _fileSizeMap = {
    1024 * 1024 * 1024 * 1024: 'TB',
    1024 * 1024 * 1024: 'GB',
    1024 * 1024: 'MB',
    1024: 'KB',
    0: 'B',
  };

  // 文件大小格式转换
  static String formatSize(
    int size, {
    bool lowerCase = false,
    int fixed = 1,
  }) {
    for (final item in _fileSizeMap.keys) {
      if (size >= item) {
        final result = (size / item).toStringAsFixed(fixed);
        var unit = _fileSizeMap[item];
        if (lowerCase) unit = unit!.toLowerCase();
        return '$result$unit';
      }
    }
    return '';
  }

  // 获取本地文件目录(传入相对路径，拼接目标路径)
  static Future<String?> getDirPath(
    String path, {
    FileDir root = FileDir.temporary,
  }) async {
    final rootPath = await root.path;
    if (null == rootPath) return null;
    final dir = Directory(join(rootPath, path));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }
}

/*
* 目录枚举
* @author wuxubaiyang
* @Time 2022/9/9 17:41
*/
enum FileDir {
  temporary,
  applicationDocuments,
  applicationSupport,
}

/*
* 目录枚举扩展
* @author wuxubaiyang
* @Time 2022/9/9 17:43
*/
extension FileDirExtension on FileDir {
  // 获取目录
  Future<Directory?> get dir {
    switch (this) {
      case FileDir.temporary:
        return getTemporaryDirectory();
      case FileDir.applicationDocuments:
        return getApplicationDocumentsDirectory();
      case FileDir.applicationSupport:
        return getApplicationSupportDirectory();
    }
  }

  // 获取路径
  Future<String?> get path async => (await dir)?.path;
}

/*
* 扩展文件方法
* @author wuxubaiyang
* @Time 2022/3/17 16:23
*/
extension FileExtension on File {
  // 获取文件名
  String? get name {
    final index = path.lastIndexOf(r'/');
    if (index >= 0 && index < path.length) {
      return path.substring(index + 1);
    }
    return null;
  }

  // 获取文件后缀
  String? get suffixes {
    final index = path.lastIndexOf(r'.');
    final sepIndex = path.lastIndexOf(r'/');
    if (index >= 0 && index <= path.length && index > sepIndex) {
      return path.substring(index);
    }
    return null;
  }
}
