import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:path/path.dart';

/*
* m3u8下载
* @author wuxubaiyang
* @Time 2023/8/1 11:15
*/
class M3U8Downloader extends Downloader {
  // m3u8密钥文件名
  static const _m3u8KeyFilename = 'key.key';

  // m3u8合并之后的文件名
  static const _m3u8MargeFilename = 'index.mp4';

  // m3u8索引文件名
  static const _m3u8IndexFilename = 'index.m3u8';

  // 下载并发数量
  static const _m3u8ConcurrentLimit = 10;

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
      // 解析索引文件并遍历要下载的资源集合
      final baseUri = Uri.parse(url);
      final downloads = await _parseM3U8File(baseUri);
      if (downloads.isEmpty) return null;
      // 将索引文件直接写入本地
      final content = downloads.remove(_m3u8IndexFilename);
      File? playFile = await _writeM3U8IndexFile(savePath, content);
      // 剔除掉已经下载过的文件
      downloads.removeWhere((k, _) => File('$savePath/$k').existsSync());
      // 限制并发数使用异步队列
      int count = 0, total = downloads.length;
      receiveProgress?.call(count, total, 0);
      final runningTasks = <Completer<File?>>[];
      for (final filename in downloads.keys) {
        // 下载文件并存储到本地
        final future = _doDownloadTask(
          downloads[filename] ?? '',
          '$savePath/$filename',
          cancelToken: cancelToken,
          onReceiveProgress: (c, _, s) =>
              receiveProgress?.call(count++, total, s),
        );
        runningTasks.add(Completer()..complete(future));
        // 如果被取消则直接返回done
        if (cancelToken?.isCancelled ?? false) {
          done?.call();
          return null;
        }
        // 判断是否达到最大并发数，达到则等待其中一个完成再继续
        if (runningTasks.length >= _m3u8ConcurrentLimit) {
          await Future.any(runningTasks.map((e) => e.future));
          runningTasks.removeWhere((e) => e.isCompleted);
        }
      }
      // 等待剩余任务的完成
      await Future.wait(runningTasks.map((e) => e.future));
      // 如果存在key则对视频进行合并
      if (downloads.containsKey(_m3u8KeyFilename) && playFile != null) {
        final outputFile = File('$savePath/$_m3u8MargeFilename');
        if (outputFile.existsSync()) outputFile.deleteSync();
        playFile = await _margeM3U8File2MP4(playFile.path, outputFile.path);
        if (playFile == null) throw Exception('视频合并失败');
      }
      complete?.call(savePath);
      return playFile;
    } catch (e) {
      LogTool.e('m3u8视频下载失败', error: e);
      failed?.call(e as Exception);
    }
    return null;
  }

  // 执行下载任务
  Future<File?> _doDownloadTask(
    String downloadUrl,
    String filePath, {
    DownloaderProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final result = await download(
      downloadUrl,
      '$filePath.tmp',
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    // 如果没有返回下载的文件则认为是异常
    if (result == null) throw Exception('下载文件返回为空');
    // 下载完成后去掉.tmp标记
    return result.rename(filePath);
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
      key = mergeUrl(key, baseUri);
    }
    // 遍历分片列表并同时生成本地索引文件
    final resources = {};
    for (final item in playlist.segments) {
      // 拼接分片下载地址
      String? url = item.url;
      if (url == null) continue;
      url = mergeUrl(url, baseUri);
      final filename = basename(url);
      resources[filename] = url;
      // 替换m3u8文件中得分片地址为本地
      final origin = item.url ?? '';
      content = content.replaceAll(origin, filename);
    }
    return {
      if (key != null) _m3u8KeyFilename: key,
      _m3u8IndexFilename: content,
      ...resources,
    };
  }

  // m3u8视频合并
  Future<File?> _margeM3U8File2MP4(
    String inputPath,
    String outputPath, {
    Function(Statistics statistics)? callback,
  }) {
    final args = '-allowed_extensions ALL '
        '-protocol_whitelist "file,http,https,tls,tcp,crypto" '
        '-i $inputPath -c copy';
    return FFMpegHelper.instance.runSync(
      statisticsCallback: callback,
      FFMpegCommand(
        args: [CustomArgument(args.split(' '))],
        outputFilepath: outputPath,
      ),
    );
  }

  // 将m3u8索引文件直接写入本地
  Future<File?> _writeM3U8IndexFile(String savePath, String? content) async {
    if (content == null) return null;
    final file = File('$savePath/$_m3u8IndexFilename');
    if (file.existsSync()) return file;
    final raf = await file.open(mode: FileMode.write);
    await raf.writeString(content);
    await raf.close();
    return file;
  }
}
