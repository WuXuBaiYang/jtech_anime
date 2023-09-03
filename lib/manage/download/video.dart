import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jtech_anime/manage/download/base.dart';

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
    // // 文件不存在则启用下载
    // final filename = basename(url);
    // final playFile = File('$savePath/$filename');
    // if (!playFile.existsSync()) {
    //   // 下载文件并存储到本地
    //   final temp = await download(
    //     url,
    //     '${playFile.path}.tmp',
    //     cancelToken: cancelToken,
    //     receiveProgress: receiveProgress,
    //   );
    //   // 如果被取消了则直接返回
    //   if (isCanceled(cancelToken)) return null;
    //   // 如果没有返回下载的文件则认为是异常
    //   if (temp == null) throw Exception('下载文件返回为空');
    //   // 下载完成后去掉.tmp标记
    //   await temp.rename(playFile.path);
    // }
    // return playFile;
  }
}
