import 'package:dio/dio.dart';
import 'package:jtech_anime/common/model.dart';

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
  final int speed;

  DownloadTask({
    required this.cancelKey,
    this.progress = 0,
    this.total = 0,
    this.speed = 0,
  });
}
