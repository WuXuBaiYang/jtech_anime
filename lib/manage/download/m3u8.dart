import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:jtech_anime/manage/download/base.dart';
import 'package:jtech_anime/tool/log.dart';

/*
* m3u8下载
* @author wuxubaiyang
* @Time 2023/8/1 11:15
*/
class M3U8Downloader extends Downloader {
  // m3u8密钥文件名
  static const m3u8KeyFilename = 'key.key';

  // m3u8索引文件名
  static const m3u8IndexFilename = 'index.m3u8';

  // 根据m3u8下载番剧
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
      // 解析索引文件并遍历要下载的资源集合
      final baseUri = Uri.parse(url);
      final downloads = await _parseM3U8File(baseUri);
      if (downloads.isNotEmpty) {
        int speed = 0, count = 0;
        final total = downloads.length;
        receiveProgress?.call(count, total, speed);
        timer = Timer.periodic(updateDelay, (_) {
          if (cancelToken?.isCancelled ?? false) return;
          receiveProgress?.call(count, total, speed);
          speed = 0;
        });
        // 如果是索引文件则直接存储到本地
        final firstUrl = downloads.values.firstOrNull ?? '';
        for (final filename in downloads.keys) {
          final content = downloads[filename] ?? '';
          final file = File('$savePath/$filename');
          if (filename != m3u8IndexFilename) {
            // 文件不存在则启用下载
            if (!file.existsSync()) {
              // 下载文件并存储到本地
              final temp = await download(
                content,
                '${file.path}.tmp',
                onReceiveProgress: (c, _) => speed += c,
                cancelToken: cancelToken,
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
      content = content.replaceAll(key, m3u8KeyFilename);
      key = mergeUrl(key, baseUri);
    }
    // 遍历分片列表并同时生成本地索引文件
    final resources = {};
    for (final item in playlist.segments) {
      // 拼接分片下载地址
      String? url = item.url;
      if (url == null) continue;
      url = mergeUrl(url, baseUri);
      final filename = getFilenameFromUrl(url);
      resources[filename] = url;
      // 替换m3u8文件中得分片地址为本地
      final origin = item.url ?? '';
      content = content.replaceAll(origin, filename);
    }
    return {
      if (key != null) m3u8KeyFilename: key,
      m3u8IndexFilename: content,
      ...resources,
    };
  }
}