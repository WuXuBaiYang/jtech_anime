import 'dart:async';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:dio/dio.dart';
import 'package:jtech_anime/tool/file.dart';

// 下载进度回调
typedef DownloaderProgressCallback = void Function(
    int count, int total, int speed);

/*
* 下载器基类
* @author wuxubaiyang
* @Time 2023/8/1 11:17
*/
abstract class Downloader {
  // 开始下载，成功则返回播放文件的地址
  Future<File?> start(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? receiveProgress,
  });

  // 文件批量下载,传入<文件名,下载地址>（支持断点续传）
  Future<void> downloadBatch(
    Map<String, String> downloadMap, {
    DownloaderProgressCallback? receiveProgress,
    FileDir root = FileDir.applicationDocuments,
    CancelToken? cancelToken,
    String fileDir = '',
  }) async {
    final downloader = FileDownloader();
    final baseDir = {
      FileDir.applicationDocuments: BaseDirectory.applicationDocuments,
      FileDir.applicationSupport: BaseDirectory.applicationSupport,
      FileDir.temporary: BaseDirectory.temporary,
    }[root]!;
    int count = 0, total = downloadMap.length;
    // 封装下载任务
    final downloadTasks = downloadMap.keys
        .map((filename) => DownloadTask(
              url: downloadMap[filename] ?? '',
              filename: '$filename.tmp',
              baseDirectory: baseDir,
              requiresWiFi: false,
              directory: fileDir,
              allowPause: true,
            ))
        .toList();
    // 监听任务销毁状态
    cancelToken?.whenCancel.whenComplete(() {
      for (var e in downloadTasks) {
        downloader.cancelTaskWithId(e.taskId);
      }
    });
    final lastProgressMap = {};
    // 启动任务批量下载
    await downloader.downloadBatch(
      downloadTasks,
      batchProgressCallback: (succeeded, __) => count = succeeded,
      taskProgressCallback: (updates) async {
        // 如果下载完成（progress==1）则对文件重命名
        _updateFileNameWhenComplete(updates).then((result) {
          if (result) downloadTasks.remove(updates.task);
        });
        final size = updates.expectedFileSize;
        if (size <= 0) return;
        final taskId = updates.task.taskId;
        final lastProgress = lastProgressMap[taskId] ?? 0;
        final speed = size * (updates.progress - lastProgress);
        receiveProgress?.call(count, total, speed.toInt());
        lastProgressMap[taskId] = updates.progress;
      },
    );
  }

  // 下载完成后更新文件名
  Future<bool> _updateFileNameWhenComplete(TaskProgressUpdate updates) async {
    if (updates.progress < 1) return false;
    final filePath = await updates.task.filePath();
    await File(filePath).rename(filePath.replaceAll('.tmp', ''));
    return true;
  }

  // 判断是否已取消
  bool isCanceled(CancelToken? cancelToken) {
    if (cancelToken == null) return false;
    return cancelToken.isCancelled;
  }
}
