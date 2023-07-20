import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/tool/log.dart';

/*
* 下载管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DownloadManage extends BaseManage {
  static final DownloadManage _instance = DownloadManage._internal();

  factory DownloadManage() => _instance;

  DownloadManage._internal();

  @override
  Future<void> init() async {}

  // 解析m3u8文件并获取全部的下载记录
  Future<Map<String, String>> _parseM3U8File(String url) async {
    try {
      final resp = await Dio().get(url);
      if (resp.statusCode == 200) {
        final uri = Uri.parse(url);
        final parser = HlsPlaylistParser.create();
        final playlist = parser.parseString(uri, resp.data);
        if (playlist is HlsMasterPlaylist) {
        } else if (playlist is HlsMediaPlaylist) {

        }
      }
    } catch (e) {
      LogTool.e('m3u8文件解析失败', error: e);
    }
    return {};
  }

  // 判断是否支持断点续传
  Future<bool> _supportPause(String url) async {
    try {
      final options = Options(headers: _getRange(0, 1024));
      final resp = await Dio().get(url, options: options);
      if (resp.statusCode == 200) {
        final headers = resp.headers.map;
        return ['range', 'accept-ranges', 'content-range']
            .any(headers.containsKey);
      }
    } catch (e) {
      LogTool.e('检查断点续传失败', error: e);
    }
    return false;
  }

  // 生成range头部
  Map<String, String> _getRange(int start, [int? end]) =>
      {'range': '$start-${end ?? ''}'};
}

// 单例调用
final download = DownloadManage();
