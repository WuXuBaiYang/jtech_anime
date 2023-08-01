import 'dart:async';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/manage/download/m3u8.dart';
import 'package:jtech_anime/manage/download/video.dart';
import 'package:jtech_anime/manage/notification.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/tool.dart';

// 下载完成回调
typedef DownloadCompleteCallback = void Function(DownloadRecord record);

/*
* 下载管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DownloadManage extends BaseManage {
  // 下载进度通知id
  static const downloadProgressNoticeId = 9527;

  static final DownloadManage _instance = DownloadManage._internal();

  factory DownloadManage() => _instance;

  // 下载器
  final Downloader _m3u8Download, _videoDownload;

  DownloadManage._internal()
      : _m3u8Download = M3U8Downloader(),
        _videoDownload = VideoDownloader();

  // 下载队列
  final downloadQueue = MapValueChangeNotifier<String, DownloadRecord>.empty();

  // 番剧缓存目录
  final videoCachePath = ValueChangeNotifier<String>('video_cache');

  // 最大下载数
  final maxDownloadCount = ValueChangeNotifier<int>(3);

  // 总速度
  final totalSpeed = ValueChangeNotifier<int>(0);

  // 总进度
  final totalProgress = ValueChangeNotifier<double>(0);

  // 下载完成回调
  final List<DownloadCompleteCallback> _downloadCompleteCallbacks = [];

  // 获取下载中队列
  List<DownloadRecord> get downloadingList =>
      downloadQueue.values.where((e) => e.task?.downloading ?? false).toList();

  // 获取准备中队列
  List<DownloadRecord> get prepareList => downloadQueue.values
      .where((e) => !(e.task?.downloading ?? true))
      .toList();

  // 添加下载完成回调
  void addDownloadCompleteListener(DownloadCompleteCallback callback) =>
      _downloadCompleteCallbacks.add(callback);

  // 开始多条下载任务
  Future<void> startTasks(List<DownloadRecord> records) =>
      Future.forEach(records, startTask);

  // 启动一个下载任务
  Future<bool> startTask(DownloadRecord record) async {
    try {
      // 如果当前任务在下载队列则直接返回true
      final url = record.downloadUrl;
      if (downloadQueue.contains(url)) return true;
      // 创建缓存目录
      final savePath = record.savePath.isNotEmpty
          ? record.savePath
          : await FileTool.getDirPath(
              '${videoCachePath.value}/${Tool.md5(record.url)}',
              root: FileDir.applicationDocuments);
      if (savePath == null || savePath.isEmpty) return false;
      // 创建一个任务task并决定添加到准备还是下载队列
      return _resumeTask(record.createTask(savePath));
    } catch (e) {
      LogTool.e('开始下载任务失败', error: e);
    }
    return false;
  }

  // 恢复启动一个下载任务
  Future<bool> _resumeTask(DownloadRecord record) async {
    if (record.task == null) return false;
    final downloadUrl = record.downloadUrl;
    // 更新下载记录的状态
    await db.updateDownload(record
      ..status = DownloadRecordStatus.download
      ..updateTime = DateTime.now());
    // 如果下载队列达到上限则将任务添加到准备队列
    if (downloadingList.length >= maxDownloadCount.value) {
      downloadQueue.putValue(downloadUrl, record..updateTaskStatus(false));
      return true;
    }
    downloadQueue.putValue(downloadUrl, record..updateTaskStatus(true));
    // 判断任务类型并开始下载
    (record.isM3U8 ? _m3u8Download : _videoDownload).start(
      downloadUrl,
      record.savePath,
      done: () => _doneTask(record),
      cancelToken: record.task?.cancelKey,
      failed: (e) => _taskOnError(record, e),
      complete: (savePath) => _updateTaskComplete(record, savePath),
      receiveProgress: (count, total, savePath) =>
          _updateTaskProgress(record, count, total, savePath),
    );
    return true;
  }

  // 更新计数器（当达到最大计数的时候才执行更新）
  int _updateCount = 0;

  // 更新下载进度
  void _updateTaskProgress(
      DownloadRecord record, int count, int total, int speed) {
    int maxCount = maxDownloadCount.value;
    final queueCount = downloadQueue.length;
    maxCount = queueCount > maxCount ? maxCount : queueCount;
    final notify = ++_updateCount >= maxCount;
    if (notify) {
      _updateTaskTotalProgress();
      _updateCount = 0;
    }
    downloadQueue.putValue(
      notify: notify,
      record.downloadUrl,
      record.updateTask(count, total, speed),
    );
  }

  // 更新总体下载进度
  void _updateTaskTotalProgress() {
    // 计算总体进度与总体速度
    double speed = 0, ratio = 0, total = 0;
    String? firstAnimeName;
    for (var e in downloadQueue.values) {
      final task = e.task;
      if (task == null) continue;
      firstAnimeName ??= '${e.title} ${e.name}';
      ratio += task.progress;
      speed += task.speed;
      total += task.total;
    }
    if (total != 0 && ratio != 0) ratio /= total;
    totalSpeed.setValue(speed.toInt());
    totalProgress.setValue(ratio);
    final length = downloadQueue.length;
    final progress = (ratio * 100).toStringAsFixed(1);
    final content =
        '($progress%)  正在下载 $firstAnimeName ${length > 1 ? '等 $length 部视频' : ''}';
    notice.showProgress(
      progress: (100 * ratio).toInt(),
      id: downloadProgressNoticeId,
      indeterminate: false,
      maxProgress: 100,
      title: content,
    );
  }

  // 更新下载任务为完成状态
  void _updateTaskComplete(DownloadRecord record, String savePath) async {
    // 完成下载任务
    _doneTask(record);
    // 更新下载任务为已完成
    db.updateDownload(record
      ..status = DownloadRecordStatus.complete
      ..updateTime = DateTime.now()
      ..savePath = savePath);
    // 回调下载完成事件
    for (var callback in _downloadCompleteCallbacks) {
      callback.call(record);
    }
  }

  // 下载任务异常处理
  void _taskOnError(DownloadRecord record, Exception e) async {
    // 完成下载任务
    _doneTask(record);
    // 更新状态到数据库
    db.updateDownload(record
      ..status = DownloadRecordStatus.fail
      ..updateTime = DateTime.now()
      ..failText = e.toString());
  }

  // 结束下载任务(下载完成/下载停止/下载异常)
  void _doneTask(DownloadRecord record) {
    // 从下载队列中移除下载任务
    downloadQueue.removeValue(record.downloadUrl);
    // 判断等待队列中是否存在任务，存在则将首位任务添加到下载队列
    final list = prepareList;
    if (list.isEmpty) {
      notice.cancel(downloadProgressNoticeId);
      totalProgress.setValue(0);
      totalSpeed.setValue(0);
    } else {
      _resumeTask(list.first);
    }
  }

  // 暂停全部下载任务
  Future<List<bool>> stopAllTasks() => stopTasks(downloadQueue.values.toList());

  // 暂停多条下载任务
  Future<List<bool>> stopTasks(List<DownloadRecord> records) async =>
      Future.wait<bool>(records.map(stopTask));

  // 暂停一个下载任务
  Future<bool> stopTask(DownloadRecord record) async {
    try {
      final downloadUrl = record.downloadUrl;
      if (downloadQueue.contains(downloadUrl)) {
        // 如果正在下载的任务则取消下载
        final item = downloadQueue.getItem(downloadUrl);
        item?.task?.cancelKey.cancel('stopTask');
        downloadQueue.removeValue(downloadUrl);
      }
    } catch (e) {
      LogTool.e('停止下载任务失败', error: e);
    }
    return false;
  }

  // 删除全部下载任务
  Future<List<bool>> removeAllTasks() =>
      removeTasks(downloadQueue.values.toList());

  // 删除多条下载任务
  Future<List<bool>> removeTasks(List<DownloadRecord> records) =>
      Future.wait<bool>(records.map(removeTask));

  // 删除一个下载任务
  Future<bool> removeTask(DownloadRecord record) async {
    try {
      // 停止下载任务
      await stopTask(record);
      // 从数据库中移除本条记录并删除本地缓存
      final result = await db.removeDownloadRecord(record.id);
      if (result) return FileTool.clearDir(record.savePath);
    } catch (e) {
      LogTool.e('移除下载任务失败', error: e);
    }
    return false;
  }
}

// 单例调用
final download = DownloadManage();
