import 'package:dio/dio.dart';
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
  Future<void> init() async {
    final a = await _supportPause(
        'https://vip.ffzyread.com/20230706/13485_c3370ee5/2000k/hls/73a9cf475d2000000.ts');
    print('');
  }

  // 判断是否支持断点续传
  Future<bool> _supportPause(String url) async {
    try {
      final options = Options(headers: _getRange(0, 1024));
      final resp = await Dio().get(url, options: options);
      if (resp.statusCode == 200) {
        final headers = resp.headers.map;
        return ['range', 'Accept-Ranges', 'Content-Range']
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
