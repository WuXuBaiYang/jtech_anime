import 'package:dio/dio.dart';
import 'package:jtech_anime/common/model.dart';
import 'package:jtech_anime/model/database/download_record.dart';

/*
* 下载任务
* @author wuxubaiyang
* @Time 2023/7/21 10:50
*/
class DownloadTask extends BaseModel {
  // 已下载数量
  final int progress;

  // 总数量
  final int total;

  // 下载取消key
  final CancelToken cancelKey;

  // 下载速度
  final String speed;

  // 下载记录
  final DownloadRecord record;

  DownloadTask({
    required this.cancelKey,
    required this.record,
    this.speed = '0kb',
    this.progress = 0,
    this.total = 0,
  });

  // 从下载记录生成下载任务
  static DownloadTask fromRecord(DownloadRecord record, String savePath) {
    return DownloadTask(
      record: record..savePath = savePath,
      cancelKey: CancelToken(),
    );
  }

  DownloadTask copyWith({
    DownloadRecord? record,
    CancelToken? cancelKey,
    String? speed,
    int? progress,
    int? total,
  }) =>
      DownloadTask(
        cancelKey: cancelKey ?? this.cancelKey,
        progress: progress ?? this.progress,
        record: record ?? this.record,
        speed: speed ?? this.speed,
        total: total ?? this.total,
      );

  // 获取下载地址
  String get url => record.downloadUrl;

  // 获取存储路径
  String get savePath => record.savePath;

  // 判断是否为m3u8文件
  bool get isM3U8 => Uri.parse(url).path.endsWith('.m3u8');
}
