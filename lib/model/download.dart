import 'package:dio/dio.dart';
import 'package:jtech_anime/common/model.dart';

/*
* 下载任务
* @author wuxubaiyang
* @Time 2023/7/21 10:50
*/
class DownloadTask extends BaseModel {
  // 是否正在下载(准备状态下，也是false)
  final bool downloading;

  // 下载地址
  final String url;

  // 已下载数量
  final int progress;

  // 总数量
  final int total;

  // 是否为m3u8
  final bool isM3U8;

  // 下载取消key
  final CancelToken? cancelKey;

  // 下载速度
  final String speed;

  // 存储路径
  final String savePath;

  DownloadTask({
    required this.savePath,
    required this.isM3U8,
    required this.url,
    this.downloading = false,
    this.progress = 0,
    this.cancelKey,
    this.total = 0,
    this.speed = '0kb',
  });

  DownloadTask copyWith({
    CancelToken? cancelKey,
    bool? downloading,
    String? savePath,
    String? speed,
    int? progress,
    bool? isM3U8,
    String? url,
    int? total,
  }) =>
      DownloadTask(
        downloading: downloading ?? this.downloading,
        cancelKey: cancelKey ?? this.cancelKey,
        savePath: savePath ?? this.savePath,
        progress: progress ?? this.progress,
        isM3U8: isM3U8 ?? this.isM3U8,
        speed: speed ?? this.speed,
        total: total ?? this.total,
        url: url ?? this.url,
      );
}
