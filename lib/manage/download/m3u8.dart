import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/tool/file.dart';
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

  // m3u8缓存路径名
  static const _m3u8CachePath = 'cache';

  @override
  Future<File?> start(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? receiveProgress,
  }) async {
    final cacheDir = Directory('$savePath/$_m3u8CachePath/');
    if (!cacheDir.existsSync()) cacheDir.createSync(recursive: true);
    // 解析索引文件并遍历要下载的资源集合
    final baseUri = Uri.parse(url);
    final downloadsMap = await _parseM3U8File(baseUri);
    if (downloadsMap.isEmpty) throw Exception('m3u8文件解析失败，内容为空');
    // 将索引文件直接写入本地
    final content = downloadsMap.remove(_m3u8IndexFilename);
    File? playFile = await _writeM3U8IndexFile(cacheDir.path, content);
    // 获取要下载的文件总量
    final total = downloadsMap.length;
    downloadsMap
        .removeWhere((k, _) => File('${cacheDir.path}/$k').existsSync());
    final startIndex = cacheDir.path.indexOf(FileDirPath.videoCachePath);
    int initCount = total - downloadsMap.length;
    await downloadBatch(
      receiveProgress: (count, _, speed) {
        if (isCanceled(cancelToken)) return;
        receiveProgress?.call(initCount + count, total, speed);
      },
      fileDir: cacheDir.path.substring(startIndex),
      root: Common.videoCacheRoot,
      cancelToken: cancelToken,
      downloadsMap,
    );
    if (isCanceled(cancelToken) || playFile == null) return null;
    // 对视频进行合并
    final outputFile = File('$savePath/$_m3u8MargeFilename');
    if (outputFile.existsSync()) outputFile.deleteSync();
    playFile = await _margeM3U8File2MP4(playFile.path, outputFile.path);
    if (playFile == null) throw Exception('视频合并失败');
    // 清空缓存目录
    FileTool.clearDir(cacheDir.path);
    return playFile;
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
      throw Exception('m3u8文件解析失败');
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
      key = _mergeUrl(key, baseUri);
    }
    // 遍历分片列表并同时生成本地索引文件
    final resources = {};
    for (final item in playlist.segments) {
      // 拼接分片下载地址
      String? url = item.url;
      if (url == null) continue;
      url = _mergeUrl(url, baseUri);
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
}
