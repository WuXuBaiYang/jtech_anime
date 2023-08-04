import 'dart:async';
import 'dart:io';
import 'dart:math';
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

  // 文件批量下载,传入<文件名,下载地址>{}
  Future<void> downloadBatch(
    Map<String, String> downloadMap, {
    DownloaderProgressCallback? receiveProgress,
    FileDir root = FileDir.applicationDocuments,
    CancelToken? cancelToken,
    String fileDir = '',
  }) async {
    final downloader = FileDownloader();
    int count = 0, total = downloadMap.length;
    // 封装下载任务
    final downloadTasks = downloadMap.keys
        .map((filename) => DownloadTask(
              baseDirectory: BaseDirectory.values[root.index],
              url: downloadMap[filename] ?? '',
              filename: '$filename.tmp',
              requiresWiFi: false,
              directory: fileDir,
              allowPause: true,
            ))
        .toList();
    // 监听任务销毁状态
    final taskIds = <String>[];
    cancelToken?.whenCancel.whenComplete(() {
      downloader.cancelTasksWithIds(taskIds);
    });
    // 启动任务批量下载
    final ratio = 0.8, length = downloadTasks.length;
    const singleBatchSize = 30, lastProgressMap = {};
    final groups = (length / singleBatchSize).ceil();
    for (int i = 0; i < groups; i++) {
      final completer = Completer();
      // 分批获取下载任务队列
      final startIndex = i * singleBatchSize;
      final endIndex = min(startIndex + singleBatchSize, length);
      // 启动下载任务
      downloader.downloadBatch(
        downloadTasks.sublist(startIndex, endIndex)
          ..forEach((e) => taskIds.add(e.taskId)),
        batchProgressCallback: (int succeeded, int failed) {
          // 当前批任务完成超过80%的时候，则结束等待，直接开启下一个批任务
          final count = succeeded + failed;
          if (count < singleBatchSize * ratio) return;
          if (completer.isCompleted) return;
          completer.complete();
        },
        taskStatusCallback: (update) async {
          // 移除结束的任务id
          if (update.status.isNotFinalState) return;
          taskIds.remove(update.task.taskId);
          // 如果是已完成则重命名文件
          if (update.status != TaskStatus.complete) return;
          final filePath = await update.task.filePath();
          await File(filePath).rename(filePath.replaceAll('.tmp', ''));
          // 已完成状态则数量+1
          count += 1;
        },
        taskProgressCallback: (updates) {
          // 更新任务进度
          if (updates.expectedFileSize <= 0) return;
          final taskId = updates.task.taskId;
          final lastProgress = lastProgressMap[taskId] ?? 0;
          final speed =
              updates.expectedFileSize * (updates.progress - lastProgress);
          receiveProgress?.call(count, total, speed.toInt());
          lastProgressMap[taskId] = updates.progress;
        },
      ).then((_) {
        if (completer.isCompleted) return;
        completer.complete();
      });
      await completer.future;
      // 判断是否已取消，已取消的话则终止循环
      if (isCanceled(cancelToken)) break;
    }
  }

  // 判断是否已取消
  bool isCanceled(CancelToken? cancelToken) {
    if (cancelToken == null) return false;
    return cancelToken.isCancelled;
  }
}
