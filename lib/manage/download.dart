import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/download.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/tool.dart';

/*
* 下载管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DownloadManage extends BaseManage {
  // m3u8密钥文件名
  static const _m3u8KeyFilename = 'key.key';

  // m3u8索引文件名
  static const _m3u8IndexFilename = 'index.m3u8';

  // 下载队列最大任务数
  static const _maxDownloadCount = 3;

  // 番剧缓存目录
  static const _videoCachePath = 'video_cache';

  static final DownloadManage _instance = DownloadManage._internal();

  factory DownloadManage() => _instance;

  DownloadManage._internal();

  // 下载队列
  final downloadQueue = MapValueChangeNotifier<String, DownloadTask>.empty();

  // 准备队列
  final prepareQueue = MapValueChangeNotifier<String, DownloadTask>.empty();

  // 启动一个下载任务
  Future<bool> startTask(DownloadRecord record) async {
    try {
      // 判断当前任务是否在下载队列，如果是则直接返回
      final url = record.downloadUrl;
      if (downloadQueue.contains(url)) return true;
      // 如果当前任务在等待队列则判断是否可以添加该任务到下载队列
      if (prepareQueue.contains(url)) {
        final task = prepareQueue.getItem(url);
        if (task == null) return false;
        return _resumeTask(task);
      }
      // 创建缓存目录
      final savePath = await FileTool.getDirPath(
        '$_videoCachePath/${Tool.md5(record.url)}',
        root: FileDir.applicationDocuments,
      );
      if (savePath == null) return false;
      // 创建一个任务task并决定添加到准备还是下载队列
      final task = DownloadTask(
        isM3U8: _isM3U8File(url),
        cancelKey: CancelToken(),
        savePath: savePath,
        url: url,
      );
      //  如果下载队列没有满则直接进入下载
      if (downloadQueue.length < _maxDownloadCount) {
        downloadQueue.putValue(url, task);
        return _resumeTask(task);
      }
      // 否则装到准备队列
      prepareQueue.putValue(url, task);
      return true;
    } catch (e) {
      LogTool.e('开始下载任务失败', error: e);
    }
    return false;
  }

  // 恢复启动一个下载任务
  Future<bool> _resumeTask(DownloadTask task) async {
    // 如果下载队列满了则直接返回
    if (downloadQueue.length >= _maxDownloadCount) return false;
    // 更新下载记录的存储路径
    final record = await db.getDownloadRecord(task.url);
    if (record != null) {
      await db.updateDownload(record..savePath = task.savePath);
    }
    // 移除准备队列的任务并添加到下载队列，修改状态为下载中
    task = task.copyWith(downloading: true);
    downloadQueue.putValue(task.url, task);
    prepareQueue.removeValue(task.url);
    // 判断任务类型并开始下载
    (task.isM3U8 ? _downloadM3U8 : _downloadVideo)(
      task.url,
      task.savePath,
      cancelToken: task.cancelKey,
      done: () => _doneTask(task),
      failed: (e) => _taskOnError(task, e),
      complete: (s) => _updateTaskComplete(task, s),
      receiveProgress: (c, t, s) => _updateTaskProgress(task, c, t, s),
    );
    return true;
  }

  // 更新下载进度
  void _updateTaskProgress(DownloadTask task, int count, int total, int speed) {
    task = task.copyWith(
      speed: FileTool.formatSize(speed, lowerCase: true),
      progress: count,
      total: total,
    );
    downloadQueue.putValue(task.url, task);
  }

  // 更新下载任务为完成状态
  void _updateTaskComplete(DownloadTask task, String savePath) async {
    // 完成下载任务
    _doneTask(task);
    // 更新下载任务为已完成
    final record = await db.getDownloadRecord(task.url);
    if (record == null) return;
    db.updateDownload(record
      ..status = DownloadRecordStatus.complete
      ..updateTime = DateTime.now()
      ..savePath = savePath);
  }

  // 下载任务异常处理
  void _taskOnError(DownloadTask task, Exception e) async {
    // 完成下载任务
    _doneTask(task);
    // 更新状态到数据库
    final record = await db.getDownloadRecord(task.url);
    if (record == null) return;
    db.updateDownload(record
      ..status = DownloadRecordStatus.fail
      ..updateTime = DateTime.now()
      ..failText = '下载失败');
  }

  // 结束下载任务(下载完成/下载停止/下载异常)
  void _doneTask(DownloadTask task) {
    // 从下载队列中移除下载任务
    downloadQueue.removeValue(task.url);
    // 判断等待队列中是否存在任务，存在则将首位任务添加到下载队列
    if (prepareQueue.isEmpty) return;
    _resumeTask(prepareQueue.values.first);
  }

  // 暂停一个下载任务
  Future<bool> stopTask(DownloadRecord record) async {
    try {
      final url = record.downloadUrl;
      if (downloadQueue.contains(url)) {
        // 如果正在下载的任务则取消下载
        final item = downloadQueue.getItem(url);
        item?.cancelKey?.cancel('stopTask');
        downloadQueue.removeValue(url);
      }
      if (prepareQueue.contains(url)) {
        prepareQueue.removeValue(url);
      }
    } catch (e) {
      LogTool.e('停止下载任务失败', error: e);
    }
    return false;
  }

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

  // 根据m3u8下载番剧
  Future<void> _downloadM3U8(
    String url,
    String savePath, {
    Duration updateDelay = const Duration(milliseconds: 500),
    CancelToken? cancelToken,
    void Function(int count, int total, int speed)? receiveProgress,
    void Function(String savePath)? complete,
    void Function(Exception)? failed,
    void Function()? done,
  }) async {
    Timer? timer;
    try {
      // 根据存储路径创建缓存目录
      final dir = File(savePath);
      if (!await dir.exists()) {
        await dir.create();
      }
      // 解析索引文件并遍历要下载的资源集合
      final baseUri = Uri.parse(url);
      final downloads = await _parseM3U8File(baseUri);
      if (downloads.isNotEmpty) {
        int speed = 0, count = 0;
        final total = downloads.length;
        timer = Timer.periodic(updateDelay, (_) {
          receiveProgress?.call(count, total, speed);
          speed = 0;
        });
        // 如果是索引文件则直接存储到本地
        final firstUrl = downloads.values.firstOrNull ?? '';
        final canPause = await _supportPause(firstUrl);
        for (final filename in downloads.keys) {
          final content = downloads[filename] ?? '';
          final file = File('${dir.path}/$filename');
          if (filename != _m3u8IndexFilename) {
            // 文件不存在则启用下载
            if (!await file.exists()) {
              // 下载文件并存储到本地
              final temp = await _download(
                content,
                '${file.path}.tmp',
                onReceiveProgress: (c, _) => speed += c,
                cancelToken: cancelToken,
                canPause: canPause,
              );
              // 如果被取消了则直接返回
              if (cancelToken?.isCancelled ?? false) return done?.call();
              // 如果没有返回下载的文件则认为是异常
              if (temp == null) return failed?.call(Exception('下载失败'));
              // 下载完成后去掉.tmp标记
              await temp.rename(file.path);
            }
          } else {
            // 如果是索引文件则写入本地
            final raf = await file.open(mode: FileMode.write);
            await raf.writeString(content);
            await raf.close();
          }
          count++;
        }
        return complete?.call(savePath);
      }
    } catch (e) {
      LogTool.e('m3u8视频下载失败', error: e);
      failed?.call(e as Exception);
    } finally {
      timer?.cancel();
    }
    return done?.call();
  }

  // 下载番剧
  Future<void> _downloadVideo(
    String url,
    String savePath, {
    Duration updateDelay = const Duration(milliseconds: 500),
    CancelToken? cancelToken,
    void Function(int count, int total, int speed)? receiveProgress,
    void Function(String savePath)? complete,
    void Function(Exception)? failed,
    void Function()? done,
  }) async {
    Timer? timer;
    try {
      // 根据存储路径创建缓存目录
      final dir = File(savePath);
      if (!await dir.exists()) {
        await dir.create();
      }
      int speed = 0, count = 0, total = -1;
      timer = Timer.periodic(updateDelay, (_) {
        receiveProgress?.call(count, total, speed);
        speed = 0;
      });
      // 如果是索引文件则直接存储到本地
      final canPause = await _supportPause(url);
      // 文件不存在则启用下载
      final filename = Uri.parse(url).path.split('/').last;
      final file = File('${dir.path}/$filename');
      if (!await file.exists()) {
        // 下载文件并存储到本地
        final temp = await _download(
          url,
          '${file.path}.tmp',
          cancelToken: cancelToken,
          onReceiveProgress: (c, t) {
            if (total <= 0) total = t;
            speed += c;
          },
          canPause: canPause,
        );
        // 如果被取消了则直接返回
        if (cancelToken?.isCancelled ?? false) return done?.call();
        // 如果没有返回下载的文件则认为是异常
        if (temp == null) return failed?.call(Exception('下载失败'));
        // 下载完成后去掉.tmp标记
        await temp.rename(file.path);
      }
      return complete?.call(savePath);
    } catch (e) {
      LogTool.e('视频下载失败', error: e);
      failed?.call(e as Exception);
    } finally {
      timer?.cancel();
    }
    return done?.call();
  }

  // 文件下载（支持断点续传）
  Future<File?> _download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    void Function()? done,
    bool canPause = true,
  }) async {
    final c = Completer<File?>();
    // 检查本地是否存在已存在文件并获取起始位置
    int downloadStart = 0;
    File saveFile = File(savePath);
    if (canPause && await saveFile.exists()) {
      downloadStart = saveFile.lengthSync();
    }
    // 开始下载
    final options = Options(
      responseType: ResponseType.stream,
      headers: _getRange(downloadStart),
      followRedirects: false,
    );
    final resp = await Dio().get<ResponseBody>(url, options: options);
    int received = downloadStart;
    int total = await _getContentLength(resp);
    // 监听下载流并执行写入、完成、异常等回调
    final raf = saveFile.openSync(
      mode: canPause ? FileMode.append : FileMode.write,
    );
    final subscription = resp.data!.stream.listen((data) {
      received += data.length;
      raf.writeFromSync(data);
      onReceiveProgress?.call(received, total);
    }, onDone: () async {
      c.complete(saveFile);
      await raf.close();
      done?.call();
    }, onError: (e) async {
      c.completeError(e);
      await raf.close();
    }, cancelOnError: true);
    // 如果执行的cancel事件则终止文件流
    cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await raf.close();
      c.complete();
    });
    return c.future;
  }

  // 获取下载文件大小
  Future<int> _getContentLength(Response response) async {
    try {
      final contentLength =
          response.headers.value(HttpHeaders.contentLengthHeader);
      if (contentLength == null) return 0;
      return int.tryParse(contentLength) ?? 0;
    } catch (e) {
      LogTool.e('获取远程文件大小失败', error: e);
    }
    return 0;
  }

  // 解析m3u8文件并获取全部的下载记录
  Future<Map<String, String>> _parseM3U8File(Uri uri) async {
    try {
      final resp = await Dio().getUri(uri);
      if (resp.statusCode == 200) {
        final content = resp.data;
        final parser = HlsPlaylistParser.create();
        final playlist = await parser.parseString(uri, content);
        if (playlist is HlsMasterPlaylist) {
          final uri = _parseM3U8MasterFile(playlist);
          if (uri != null) return _parseM3U8File(uri);
        } else if (playlist is HlsMediaPlaylist) {
          final result = _parseM3U8MediaFile(playlist, content);
          if (result != null) return result;
        }
      }
    } catch (e) {
      LogTool.e('m3u8文件解析失败', error: e);
    }
    return {};
  }

  // 根据url判断是否为m3u8文件
  bool _isM3U8File(String url) => Uri.parse(url).path.endsWith('.m3u8');

  // 解析m3u8主文件
  Uri? _parseM3U8MasterFile(HlsMasterPlaylist playlist) {
    // 如果多级结构则获取第一条资源再解析
    final urls = playlist.mediaPlaylistUrls;
    if (urls.isEmpty) return null;
    final uri = playlist.mediaPlaylistUrls.first;
    if (uri == null) return null;
    return uri;
  }

  // 解析m3u8媒体文件
  Map<String, String>? _parseM3U8MediaFile(
      HlsMediaPlaylist playlist, String content) {
    if (playlist.segments.isEmpty) return null;
    final baseUri = Uri.parse(playlist.baseUri ?? '');
    // 获取密钥下载地址（如果存在）
    String? key = playlist.segments.first.fullSegmentEncryptionKeyUri;
    if (key != null) {
      content = content.replaceAll(key, _m3u8KeyFilename);
      key = _mergeUrl(key, baseUri);
    }
    // 遍历分片列表并同时生成本地索引文件
    final resources = {};
    for (final item in playlist.segments) {
      // 拼接分片下载地址
      String? url = item.url;
      if (url == null) continue;
      url = _mergeUrl(url, baseUri);
      final filename = _getFilenameFromUrl(url);
      resources[filename] = url;
      // 替换m3u8文件中得分片地址为本地
      final origin = item.url ?? '';
      content = content.replaceAll(origin, filename);
    }
    return {
      ...resources,
      _m3u8IndexFilename: content,
      if (key != null) _m3u8KeyFilename: key,
    };
  }

  // 判断是否支持断点续传
  Future<bool> _supportPause(String url) async {
    try {
      final options = Options(headers: _getRange(0, 1024));
      final resp = await Dio().get(url, options: options);
      if (resp.statusCode == 200) {
        final headers = resp.headers.map;
        return [
          HttpHeaders.rangeHeader,
          HttpHeaders.acceptRangesHeader,
          HttpHeaders.contentRangeHeader,
        ].any(headers.containsKey);
      }
    } catch (e) {
      LogTool.e('检查断点续传失败', error: e);
    }
    return false;
  }

  // 生成range头部
  Map<String, String> _getRange(int start, [int? end]) =>
      {'range': '$start-${end ?? ''}'};

  // 合并url
  String _mergeUrl(String path, Uri baseUri) {
    if (path.startsWith('http')) return path;
    if (!path.startsWith('/')) {
      final tmp = baseUri.path;
      final index = tmp.lastIndexOf('/');
      path = '${tmp.substring(0, index)}/$path';
    }
    return '${baseUri.scheme}://${baseUri.host}$path';
  }

  // 获取url中得文件名
  String _getFilenameFromUrl(String url) {
    final path = Uri.parse(url).path;
    return path.split('/').lastOrNull ?? '${Tool.md5(url)}.ts';
  }
}

// 单例调用
final download = DownloadManage();
