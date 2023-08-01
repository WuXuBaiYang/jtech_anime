import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/tool/log.dart';
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
    void Function(int count, int total, int speed)? receiveProgress,
    void Function(String savePath)? complete,
    void Function(Exception)? failed,
    void Function()? done,
  }) async {
    try {
      receiveProgress?.call(0, 0, 0);
      // 文件不存在则启用下载
      final filename = basename(url);
      final playFile = File('$savePath/$filename');
      if (!playFile.existsSync()) {
        // 下载文件并存储到本地
        int lastCount = 0;
        final temp = await download(
          url,
          '${playFile.path}.tmp',
          cancelToken: cancelToken,
          onReceiveProgress: (c, t) {
            receiveProgress?.call(c, t, c - lastCount);
            lastCount = c;
          },
        );
        // 如果没有返回下载的文件则认为是异常
        if (temp == null) throw Exception('下载文件返回为空');
        // 如果被取消了则直接返回
        if (cancelToken?.isCancelled ?? false) {
          done?.call();
          return null;
        }
        // 下载完成后去掉.tmp标记
        await temp.rename(playFile.path);
      }
      complete?.call(playFile.path);
      return playFile;
    } catch (e) {
      LogTool.e('视频下载失败', error: e);
      failed?.call(e as Exception);
    }
    done?.call();
    return null;
  }
}
