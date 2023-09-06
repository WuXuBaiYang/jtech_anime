import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:path/path.dart';

/*
* 一般视频下载
* @author wuxubaiyang
* @Time 2023/8/1 11:23
*/
class VideoDownloader extends Downloader {
  // 下载番剧
  @override
  Future<File?> start(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? receiveProgress,
  }) async {
    // 文件不存在则启用下载
    final filename =
        basename(url.split('?').firstOrNull ?? 'default/${Tool.md5(url)}.mp4');
    final downloadFile = File('$savePath/$filename');
    if (!downloadFile.existsSync()) {
      // 下载文件并存储到本地
      final tempFile = await download(
        url,
        '${downloadFile.path}.tmp',
        receiveProgress: receiveProgress,
        cancelToken: cancelToken,
      );
      // 如果被取消了则直接返回
      if (isCanceled(cancelToken)) return null;
      // 如果没有返回下载的文件则认为是异常
      if (tempFile == null) throw Exception('下载文件返回为空');
      // 下载完成后去掉.tmp标记
      await tempFile.rename(downloadFile.path);
    }
    return downloadFile;
  }
}
