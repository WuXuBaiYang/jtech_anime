import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:jtech_anime/tool/tool.dart';

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

  // 文件下载
  Future<File?> download(
    String downloadUrl, {
    DownloaderProgressCallback? receiveProgress,
    FileDir root = FileDir.applicationDocuments,
    CancelToken? cancelToken,
    String fileDir = '',
    String? filename,
    int retries = 3,
  }) async {
    final downloader = FileDownloader();
    // 生成下载任务
    final taskId = Tool.md5(downloadUrl);
    final downloadTask = DownloadTask(
      baseDirectory: BaseDirectory.values[root.index],
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      directory: fileDir,
      filename: filename,
      url: downloadUrl,
      allowPause: true,
      retries: retries,
      taskId: taskId,
    );
    final completer = Completer<File?>();
    final fileSize = await _getNetFileSize(downloadUrl);
    final downloadFile = File(await downloadTask.filePath());
    // 监听任务销毁状态
    cancelToken?.whenCancel.whenComplete(() {
      downloader.pause(downloadTask);
      completer.complete(null);
    });
    // 启动下载
    double lastProgress = 0;
    downloader.download(
      downloadTask,
      onProgress: (progress) {
        final count = fileSize * progress;
        final downloadSpeed = fileSize * (progress - lastProgress);
        lastProgress = progress;
        receiveProgress?.call(
            min(count.toInt(), fileSize), fileSize, downloadSpeed.toInt());
      },
      onStatus: (status) {
        switch (status) {
          case TaskStatus.complete:
            return completer.complete(downloadFile);
          case TaskStatus.notFound:
          case TaskStatus.failed:
          case TaskStatus.canceled:
          case TaskStatus.paused:
            return completer.complete(null);
          case TaskStatus.enqueued:
          case TaskStatus.running:
          case TaskStatus.waitingToRetry:
        }
      },
    );
    return completer.future;
  }

  // 文件批量下载,传入<文件名,下载地址>{}
  Future<void> downloadBatch(
    Map<String, String> downloadMap, {
    DownloaderProgressCallback? receiveProgress,
    FileDir root = FileDir.applicationDocuments,
    CancelToken? cancelToken,
    int singleBatchSize = 30,
    String fileDir = '',
    int retries = 3,
  }) async {
    final downloader = FileDownloader();
    int count = 0, total = downloadMap.length;
    // 封装下载任务
    final downloadTasks = _genDownloadBatchTasks(
      baseDirectory: BaseDirectory.values[root.index],
      retries: retries,
      fileDir: fileDir,
      downloadMap,
    );
    // 监听任务销毁状态
    final taskIds = <String>[];
    cancelToken?.whenCancel.whenComplete(() {
      downloader.cancelTasksWithIds(taskIds);
    });
    // 启动任务批量下载
    final length = downloadTasks.length;
    final groups = (length / singleBatchSize).ceil();
    final batchFutures = <Future>[];
    for (int i = 0; i < groups; i++) {
      final completer = Completer();
      // 分批获取下载任务队列
      final startIndex = i * singleBatchSize;
      final endIndex = min(startIndex + singleBatchSize, length);
      final batchTasks = downloadTasks.sublist(startIndex, endIndex)
        ..forEach((e) => taskIds.add(e.taskId));
      // 启动下载任务
      batchFutures.add(
        _doDownloadBatch(downloader, batchTasks,
            singleBatchSize: singleBatchSize, statusCallback: (status, task) {
          // 如果返回状态，已结束则移除任务，如果任务已结束则计数+1
          if (status.isNotFinalState) return;
          taskIds.remove(task.taskId);
          if (status != TaskStatus.complete) return;
          count += 1;
        }, speedCallback: (speed) {
          receiveProgress?.call(count, total, speed);
        }, whenCompleted: () {
          if (completer.isCompleted) return;
          completer.complete();
        }),
      );
      await completer.future;
      // 判断是否已取消，已取消的话则终止循环
      if (isCanceled(cancelToken)) return;
    }
    await Future.wait(batchFutures);
  }

  // 执行批量下载
  Future<Batch> _doDownloadBatch(
    FileDownloader downloader,
    List<DownloadTask> downloadTasks, {
    void Function(TaskStatus status, Task task)? statusCallback,
    void Function(int speed)? speedCallback,
    VoidCallback? whenCompleted,
    int singleBatchSize = 0,
    double ratio = 0.5,
  }) async {
    final lastProgressMap = {};
    final waitFileRename = <Future>[];
    final batchResult = await downloader.downloadBatch(
      downloadTasks,
      batchProgressCallback: (int succeeded, int failed) {
        // 当前批次任务完成到 {ratio} 比例的时候则完成
        final count = succeeded + failed;
        if (count < singleBatchSize * ratio) return;
        whenCompleted?.call();
      },
      taskStatusCallback: (update) {
        statusCallback?.call(update.status, update.task);
        // 如果是已完成则重命名文件
        if (update.status != TaskStatus.complete) return;
        waitFileRename.add(Future(() async {
          final filePath = await update.task.filePath();
          await File(filePath).rename(filePath.replaceAll('.tmp', ''));
        }));
      },
      taskProgressCallback: (update) {
        // 更新任务进度
        if (update.expectedFileSize <= 0) return;
        final taskId = update.task.taskId;
        final lastProgress = lastProgressMap[taskId] ?? 0;
        final downloadSpeed =
            update.expectedFileSize * (update.progress - lastProgress);
        lastProgressMap[taskId] = update.progress;
        speedCallback?.call(downloadSpeed.toInt());
      },
    );
    await Future.wait(waitFileRename);
    whenCompleted?.call();
    return batchResult;
  }

  // 生成下载任务
  List<DownloadTask> _genDownloadBatchTasks(
    Map<String, String> downloadMap, {
    BaseDirectory baseDirectory = BaseDirectory.applicationDocuments,
    bool requiresWiFi = false,
    String tmpSuffix = '.tmp',
    bool allowPause = true,
    String fileDir = '',
    int retries = 0,
  }) =>
      downloadMap.keys.map((filename) {
        return DownloadTask(
          url: downloadMap[filename] ?? '',
          filename: '$filename$tmpSuffix',
          baseDirectory: baseDirectory,
          requiresWiFi: requiresWiFi,
          allowPause: allowPause,
          directory: fileDir,
          retries: retries,
        );
      }).toList();

  // 获取网络附件大小
  Future<int> _getNetFileSize(String url) async {
    final resp = await Dio().head(url);
    if (resp.statusCode != 200) return 0;
    final contentLength = resp.headers.value(Headers.contentLengthHeader);
    return int.tryParse(contentLength ?? '') ?? 0;
  }

  // 判断是否已取消
  bool isCanceled(CancelToken? cancelToken) {
    if (cancelToken == null) return false;
    return cancelToken.isCancelled;
  }
}
