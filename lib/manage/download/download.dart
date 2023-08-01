import 'dart:async';
import 'package:dio/dio.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/manage/download/m3u8.dart';
import 'package:jtech_anime/manage/download/video.dart';
import 'package:jtech_anime/manage/notification.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/download.dart';
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
  final downloadQueue = MapValueChangeNotifier<String, CancelToken>.empty();

  // 等待队列
  final prepareQueue = MapValueChangeNotifier<String, CancelToken>.empty();

  // 番剧缓存目录
  final videoCachePath = ValueChangeNotifier<String>('video_cache');

  // 最大下载数
  final maxDownloadCount = ValueChangeNotifier<int>(3);

  // 缓冲队列
  final _bufferQueue = <String, DownloadTaskItem>{};

  // 下载任务流
  final _downloadProgress = StreamController<DownloadTask?>.broadcast();

  // 获取下载任务流
  Stream<DownloadTask?> get downloadProgress => _downloadProgress.stream;

  // 下载完成回调
  final List<DownloadCompleteCallback> _downloadCompleteCallbacks = [];

  // 添加下载完成回调
  void addDownloadCompleteListener(DownloadCompleteCallback callback) =>
      _downloadCompleteCallbacks.add(callback);

  // 判断任务是否在队列中（下载/准备）
  bool isInQueue(DownloadRecord record) =>
      downloadQueue.contains(record.downloadUrl) ||
      prepareQueue.contains(record.downloadUrl);

  // 切换一个任务的状态（如果在下载中或准备队列则暂停，否则开始）
  Future<bool> toggleTask(DownloadRecord record) =>
      isInQueue(record) ? stopTask(record) : startTask(record);

  // 开始多条下载任务
  Future<void> startTasks(List<DownloadRecord> records) =>
      Future.forEach(records, startTask);

  // 启动一个下载任务
  Future<bool> startTask(DownloadRecord record) async {
    try {
      // 如果当前任务在下载队列或准备队列则直接返回true
      if (isInQueue(record)) return true;
      // 创建缓存目录
      final savePath = record.savePath.isNotEmpty
          ? record.savePath
          : await FileTool.getDirPath(
              '${videoCachePath.value}/${Tool.md5(record.url)}',
              root: FileDir.applicationDocuments);
      if (savePath == null || savePath.isEmpty) return false;
      // 创建一个任务task并决定添加到准备还是下载队列
      return _resumeTask(record..savePath = savePath);
    } catch (e) {
      LogTool.e('开始下载任务失败', error: e);
    }
    return false;
  }

  // 恢复启动一个下载任务
  Future<bool> _resumeTask(DownloadRecord record) async {
    final downloadUrl = record.downloadUrl;
    // 更新下载记录的状态
    await db.updateDownload(record
      ..status = DownloadRecordStatus.download
      ..updateTime = DateTime.now());
    final cancelToken = CancelToken();
    // 如果下载队列达到上限则将任务添加到准备队列
    if (downloadQueue.length >= maxDownloadCount.value) {
      prepareQueue.putValue(downloadUrl, cancelToken);
      return true;
    }
    downloadQueue.putValue(downloadUrl, cancelToken);
    // 启动监听下载进度
    _startDownloadProgress();
    // 判断任务类型并开始下载
    (record.isM3U8 ? _m3u8Download : _videoDownload)
        .start(
      downloadUrl,
      record.savePath,
      cancelToken: cancelToken,
      done: () => _doneTask(record),
      failed: (e) => _taskOnError(record, e),
      complete: (_) => _updateTaskComplete(record),
      receiveProgress: (count, total, speed) =>
          _updateTaskProgress(record, count, total, speed),
    )
        .then((playFile) {
      // 更新下载记录的播放文件地址
      if (playFile != null) {
        db.updateDownload(record
          ..playFilePath = playFile.path
          ..updateTime = DateTime.now());
      }
    });
    return true;
  }

  // 更新下载进度
  void _updateTaskProgress(
      DownloadRecord record, int count, int total, int speed) {
    // 如果缓存队列中存在任务则堆叠参数否则创建新任务
    final downloadUrl = record.downloadUrl;
    final task = _bufferQueue[downloadUrl];
    _bufferQueue[downloadUrl] = task != null
        ? task.stack(count, total, speed)
        : DownloadTaskItem(count, total, speed);
  }

  // 更新下载任务为完成状态
  void _updateTaskComplete(DownloadRecord record) async {
    // 完成下载任务
    _doneTask(record);
    // 更新下载任务为已完成
    db.updateDownload(record
      ..status = DownloadRecordStatus.complete
      ..updateTime = DateTime.now());
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
    final downloadUrl = record.downloadUrl;
    // 从下载队列与准备队列中移除下载任务
    downloadQueue.removeValue(downloadUrl);
    prepareQueue.removeValue(downloadUrl);
    // 判断等待队列中是否存在任务，存在则将首位任务添加到下载队列
    if (prepareQueue.isEmpty) {
      notice.cancel(downloadProgressNoticeId);
    } else {
      db.getDownloadRecord(prepareQueue.keys.first).then((item) {
        if (item != null) _resumeTask(item);
      });
    }
    // 停止监听下载进度
    _stopDownloadProgress();
  }

  // 暂停多条下载任务
  Future<List<bool>> stopTasks(List<DownloadRecord> records) async =>
      Future.wait<bool>(records.map(stopTask));

  // 暂停一个下载任务
  Future<bool> stopTask(DownloadRecord record) async {
    try {
      final downloadUrl = record.downloadUrl;
      // 如果正在下载的任务则取消下载
      final cancelToken = downloadQueue.getItem(downloadUrl);
      cancelToken?.cancel('stopTask');
      downloadQueue.removeValue(downloadUrl);
      // 如果是在准备中的队列则移除准备队列
      prepareQueue.removeValue(downloadUrl);
    } catch (e) {
      LogTool.e('停止下载任务失败', error: e);
    }
    return false;
  }

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

  // 下载进度流
  StreamSubscription<DownloadTask>? _downloadProgressStream;

  // 启动下载进度流
  void _startDownloadProgress() {
    if (_downloadProgressStream == null) {
      _downloadProgress.add(_updateDownloadProgress(0));
      _downloadProgressStream =
          Stream.periodic(const Duration(seconds: 1), _updateDownloadProgress)
              .listen(_downloadProgress.add);
    }
  }

  // 关闭下载进度流
  void _stopDownloadProgress() {
    // 如果下载队列与准备队列都没有任务了，则可以销毁下载进度流
    if (downloadQueue.isEmpty && prepareQueue.isEmpty) {
      _downloadProgressStream?.cancel();
      _downloadProgressStream = null;
      _downloadProgress.add(null);
    }
  }

  // 更新下载任务队列
  DownloadTask _updateDownloadProgress(int count) {
    // 如果缓冲队列为空则直接返回空任务
    if (_bufferQueue.isEmpty) return DownloadTask();
    // 计算总速度并返回
    double totalSpeed = 0, totalRatio = 0;
    for (var item in _bufferQueue.values) {
      totalSpeed += item.speed;
      if (item.total != 0 && item.count != 0) {
        totalRatio += item.count / item.total;
      }
    }
    // 总进度比值等于(下载任务+下载任务...)/(下载任务数+准备任务数)
    final totalCount = downloadQueue.length + prepareQueue.length;
    totalRatio = totalRatio / totalCount;
    final progress = totalRatio * 100;
    // 推送消息
    final content = '(${progress.toStringAsFixed(1)}%)  正在下载 $totalCount 条视频';
    notice.showProgress(
      id: downloadProgressNoticeId,
      progress: progress.toInt(),
      indeterminate: false,
      maxProgress: 100,
      title: content,
    );
    // 清空缓冲队列并返回
    final downloadTask = DownloadTask(
      downloadingMap: Map.from(_bufferQueue),
      totalSpeed: totalSpeed.toInt(),
      totalRatio: totalRatio,
      times: count,
    );
    _bufferQueue.clear();
    return downloadTask;
  }
}

// 单例调用
final download = DownloadManage();
