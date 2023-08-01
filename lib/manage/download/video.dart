import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/tool/log.dart';

/*
* 一般视频下载
* @author wuxubaiyang
* @Time 2023/8/1 11:23
*/
class VideoDownloader extends Downloader {
  // 下载番剧
  @override
  Future<void> start(
    String url,
    String savePath, {
    Duration updateDelay = const Duration(milliseconds: 1000),
    CancelToken? cancelToken,
    void Function(int count, int total, int speed)? receiveProgress,
    void Function(String savePath)? complete,
    void Function(Exception)? failed,
    void Function()? done,
  }) async {
    Timer? timer;
    try {
      int speed = 0, count = 0, total = -1;
      timer = Timer.periodic(updateDelay, (_) {
        if (cancelToken?.isCancelled ?? false) return;
        receiveProgress?.call(count, total, speed);
        speed = 0;
      });
      // 文件不存在则启用下载
      final filename = Uri.parse(url).path.split('/').last;
      final file = File('$savePath/$filename');
      if (!file.existsSync()) {
        // 下载文件并存储到本地
        final temp = await download(
          url,
          '${file.path}.tmp',
          cancelToken: cancelToken,
          onReceiveProgress: (c, t) {
            if (total <= 0) total = t;
            speed += c;
          },
        );
        // 如果被取消了则直接返回
        if (cancelToken?.isCancelled ?? false) return done?.call();
        // 如果没有返回下载的文件则认为是异常
        if (temp == null) return failed?.call(Exception('下载失败'));
        // 下载完成后去掉.tmp标记
        await temp.rename(file.path);
      }
      return complete?.call(file.path);
    } catch (e) {
      LogTool.e('视频下载失败', error: e);
      failed?.call(e as Exception);
    } finally {
      timer?.cancel();
    }
    return done?.call();
  }
}
