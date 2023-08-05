import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jtech_anime/common/common.dart';
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

  // 下载任务流
  final _downloadProgressController =
      StreamController<DownloadTask?>.broadcast();

  // 最大下载数
  final maxDownloadCount = ValueChangeNotifier<int>(3);

  // 进度缓冲队列
  final _progressBuffed = <String, DownloadTaskItem>{};

  // 开始缓冲队列
  final _startingBuffed = <String>[];

  // 停止缓冲队列
  final _stoppingBuffed = <String>[];

  // 下载完成回调
  final List<DownloadCompleteCallback> _downloadCompleteCallbacks = [];

  // 添加下载完成回调
  void addDownloadCompleteListener(DownloadCompleteCallback callback) =>
      _downloadCompleteCallbacks.add(callback);

  // 获取下载进度流
  Stream<DownloadTask?> get downloadProgress =>
      _downloadProgressController.stream;

  // 判断任务是否在队列中（下载/准备）
  bool inQueue(DownloadRecord record) =>
      inDownloadQueue(record) || inPrepareQueue(record);

  // 判断任务是否正在下载队列
  bool inDownloadQueue(DownloadRecord record) =>
      downloadQueue.contains(record.downloadUrl);

  // 判断任务是否正在准备队列
  bool inPrepareQueue(DownloadRecord record) =>
      prepareQueue.contains(record.downloadUrl);

  // 判断任务是否处于等待状态(正在开始和正在结束)
  bool inWaitingBuffed(DownloadRecord record) =>
      inStartingBuffed(record) || inStoppingBuffed(record);

  // 判断任务是否正在开始(从添加任务到第一次更新进度)
  bool inStartingBuffed(DownloadRecord record) =>
      _startingBuffed.contains(record.downloadUrl);

  // 判断任务是否正在停止(从停止任务到任务完全停止)
  bool inStoppingBuffed(DownloadRecord record) =>
      _stoppingBuffed.contains(record.downloadUrl);

  // 开始多条下载任务
  Future<List<bool>> startTasks(List<DownloadRecord> records) async {
    // 判断下载队列的空余位置并将其余任务放到准备队列
    final remaining = maxDownloadCount.value - downloadQueue.length;
    int count = records.length - remaining;
    for (var e in records.reversed) {
      if (count-- <= 0) break;
      prepareQueue.putValue(e.downloadUrl, CancelToken());
      _updateDownloadRecord(e);
    }
    return Future.wait(records.map(startTask));
  }

  // 启动一个下载任务
  Future<bool> startTask(DownloadRecord record) async {
    try {
      // 如果当前任务在下载队列或准备队列则直接返回true
      if (inQueue(record)) return true;
      // 创建缓存目录
      final savePath = record.savePath.isNotEmpty
          ? record.savePath
          : await FileTool.getDirPath(
              '${FileDirPath.videoCachePath}/${Tool.md5(record.url)}',
              root: Common.videoCacheRoot);
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
    try {
      final downloadUrl = record.downloadUrl;
      // 更新下载记录的状态
      await _updateDownloadRecord(record);
      final cancelToken = CancelToken();
      // 如果下载队列达到上限则将任务添加到准备队列
      if (downloadQueue.length >= maxDownloadCount.value) {
        prepareQueue.putValue(downloadUrl, cancelToken);
        return true;
      }
      downloadQueue.putValue(downloadUrl, cancelToken);
      _startingBuffed.add(downloadUrl);
      // 启动监听下载进度
      _startDownloadProgress();
      // 判断任务类型并开始下载
      final downloader = record.isM3U8 ? _m3u8Download : _videoDownload;
      _startDownloadTask(downloader, record, cancelToken: cancelToken);
      return true;
    } catch (e) {
      LogTool.e('任务启动失败', error: e);
    }
    return false;
  }

  // 启动下载任务
  Future<File?> _startDownloadTask(Downloader downloader, DownloadRecord record,
      {CancelToken? cancelToken}) async {
    final downloadUrl = record.downloadUrl;
    try {
      final playFile = await downloader.start(
        downloadUrl,
        record.savePath,
        cancelToken: cancelToken,
        receiveProgress: (count, total, speed) {
          // 如果缓存队列中存在任务则堆叠参数否则创建新任务
          final task = _progressBuffed[downloadUrl] ?? DownloadTaskItem.zero();
          _progressBuffed[downloadUrl] = task.stack(count, total, speed);
        },
      );
      // 如果播放入口文件不为空则标记状态为已完成
      if (playFile != null) {
        await _updateDownloadRecord(
          status: DownloadRecordStatus.complete,
          playFilePath: playFile.path,
          record,
        );
        // 回调下载完成事件
        _doCompleteCallbacks(record);
      }
      return playFile;
    } catch (e) {
      cancelToken?.cancel();
      LogTool.e('任务下载失败', error: e);
      // 更新任务状态为异常
      await _updateDownloadRecord(
        status: DownloadRecordStatus.fail,
        failText: e.toString(),
        record,
      );
    } finally {
      // 从所有队列中移除该任务
      downloadQueue.removeValue(downloadUrl);
      prepareQueue.removeValue(downloadUrl);
      _progressBuffed.remove(downloadUrl);
      _startingBuffed.remove(downloadUrl);
      _stoppingBuffed.remove(downloadUrl);
      _stopDownloadProgress();
      // 判断等待队列中是否存在任务，存在则将首位任务添加到下载队列
      if (prepareQueue.isNotEmpty &&
          downloadQueue.length < maxDownloadCount.value) {
        final nextTask = await db.getDownloadRecord(prepareQueue.keys.first);
        if (nextTask != null && await _resumeTask(nextTask)) {
          prepareQueue.removeValue(nextTask.downloadUrl);
        }
      }
    }
    return null;
  }

  // 暂停多条下载任务
  Future<List<bool>> stopTasks(List<DownloadRecord> records) async =>
      Future.wait<bool>(records.map(stopTask));

  // 暂停一个下载任务
  Future<bool> stopTask(DownloadRecord record) async {
    try {
      final downloadUrl = record.downloadUrl;
      // 如果正在下载的任务则取消下载
      if (inDownloadQueue(record)) {
        downloadQueue.getItem(downloadUrl)?.cancel('stopTask');
        downloadQueue.removeValue(downloadUrl);
        _progressBuffed.remove(downloadUrl);
        _stoppingBuffed.add(downloadUrl);
      }
      // 如果在准备队列则移除队列
      prepareQueue.removeValue(downloadUrl);
      return true;
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
      stopTask(record);
      // 从数据库中移除本条记录并删除本地缓存
      if (!await db.removeDownloadRecord(record.id)) return false;
      // 清空本地缓存目录
      FileTool.clearDir(record.savePath);
      return true;
    } catch (e) {
      LogTool.e('移除下载任务失败', error: e);
    }
    return false;
  }

  // 更新下载记录状态
  Future<void> _updateDownloadRecord(
    DownloadRecord record, {
    DownloadRecordStatus status = DownloadRecordStatus.download,
    String playFilePath = '',
    String? failText,
  }) {
    return db.updateDownload(record
      ..updateTime = DateTime.now()
      ..playFilePath = playFilePath
      ..failText = failText
      ..status = status);
  }

  // 主动推送一次最新的下载进度
  void pushLatestProgress() =>
      _downloadProgressController.add(_updateDownloadProgress(-1));

  // 下载进度流
  StreamSubscription<DownloadTask?>? _downloadProgressPeriodic;

  // 启动下载进度流
  void _startDownloadProgress() {
    if (_downloadProgressPeriodic == null) {
      pushLatestProgress();
      _downloadProgressPeriodic = Stream.periodic(
        const Duration(seconds: 1),
        _updateDownloadProgress,
      ).listen(_downloadProgressController.add);
    }
  }

  // 关闭下载进度流
  void _stopDownloadProgress() {
    // 如果下载队列与准备队列都没有任务了，则可以销毁下载进度流
    if (downloadQueue.isEmpty && prepareQueue.isEmpty) {
      notice.cancel(downloadProgressNoticeId);
      _downloadProgressController.add(null);
      _downloadProgressPeriodic?.cancel();
      _downloadProgressPeriodic = null;
      _progressBuffed.clear();
    }
  }

  // 更新下载任务队列
  DownloadTask? _updateDownloadProgress(int count) {
    // 如果缓冲队列为空则直接返回空任务
    if (_progressBuffed.isEmpty) return DownloadTask();
    final downloadingMap = _progressBuffed.map((k, v) {
      final speed = v.speed;
      v.speed = 0;
      return MapEntry(k, v.copyWith(speed: speed));
    });
    _stoppingBuffed.forEach(downloadingMap.remove);
    if (downloadingMap.isEmpty) return null;
    // 计算总速度并返回
    double totalSpeed = 0, totalRatio = 0;
    for (var downloadUrl in downloadingMap.keys) {
      final item = downloadingMap[downloadUrl];
      _startingBuffed.remove(downloadUrl);
      if (item == null) continue;
      totalSpeed += item.speed;
      if (item.total != 0 && item.count != 0) {
        totalRatio += item.count / item.total;
      }
    }
    // 总进度比值等于(下载任务+下载任务...)/(下载任务数+准备任务数)
    final totalCount = downloadQueue.length + prepareQueue.length;
    if (totalCount <= 0) return null;
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
    return DownloadTask(
      downloadingMap: downloadingMap,
      totalSpeed: totalSpeed.toInt(),
      totalRatio: totalRatio,
      times: count,
    );
  }

  // 完成回调
  void _doCompleteCallbacks(DownloadRecord record) {
    for (var callback in _downloadCompleteCallbacks) {
      try {
        callback.call(record);
      } catch (e) {
        LogTool.i('下载完成回调出现异常；', error: e);
      }
    }
  }
}

// 单例调用
final download = DownloadManage();
