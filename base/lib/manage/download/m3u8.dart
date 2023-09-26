import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:jtech_anime_base/tool/file.dart';
import 'package:path/path.dart';
import 'base.dart';
import 'parser.dart';

/*
* m3u8下载
* @author wuxubaiyang
* @Time 2023/8/1 11:15
*/
class M3U8Downloader extends Downloader {
  // m3u8合并之后的文件名
  static const _m3u8MargeFilename = 'index.mp4';

  // m3u8缓存路径名
  static const _m3u8CachePath = 'cache';

  @override
  Future<File?> start(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? receiveProgress,
  }) async {
    final cachePath = join(savePath, _m3u8CachePath);
    // 解析索引文件并遍历要下载的资源集合
    final result = await M3U8Parser().download(url, savePath: cachePath);
    if (result == null) throw Exception('m3u8文件解析失败，内容为空');
    // 获取要下载的文件总量
    File? playFile = result.indexFile;
    final downloadsMap = result.resources;
    final total = downloadsMap.length;
    final fileList = <File>[];
    downloadsMap.removeWhere((k, _) {
      fileList.add(File(join(cachePath, k)));
      return fileList.last.existsSync();
    });
    const fileDir = FileDir.applicationDocuments;
    final basePath = '${await fileDir.path}${Platform.pathSeparator}';
    int initCount = total - downloadsMap.length;
    await downloadBatch(
      receiveProgress: (count, _, speed) {
        if (isCanceled(cancelToken)) return;
        receiveProgress?.call(min(initCount + count, total), total, speed);
      },
      fileDir: cachePath.replaceAll(basePath, ''),
      cancelToken: cancelToken,
      root: fileDir,
      downloadsMap,
    );
    if (isCanceled(cancelToken) || playFile == null) return null;
    // 检查文件完整性，有缺失则抛出异常
    if (!_checkFileCompleted(fileList)) throw Exception('文件缺失或下载失败');
    return playFile;
  }

  // 检查文件完整性（是否都存在）
  bool _checkFileCompleted(List<File> fileList) {
    for (final file in fileList) {
      if (!file.existsSync()) return false;
    }
    return true;
  }
}
