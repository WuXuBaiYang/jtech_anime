import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:jtech_anime/model/download.dart';

part 'download_record.g.dart';

@collection
class DownloadRecord {
  Id id = Isar.autoIncrement;

  // 番剧名称
  String title = '';

  // 番剧封面
  String cover = '';

  // 番剧地址
  @Index(type: IndexType.value)
  String url = '';

  // 番剧来源
  @Index(type: IndexType.value)
  String source = '';

  // 下载状态(默认是准备中)
  @enumerated
  @Index(type: IndexType.value)
  DownloadRecordStatus status = DownloadRecordStatus.download;

  // 异常描述
  String? failText;

  // 资源地址
  String resUrl = '';

  // 下载地址
  @Index(type: IndexType.value, unique: true, replace: true)
  String downloadUrl = '';

  // 名称
  String name = '';

  // 保存地址
  String savePath = '';

  // 更新时间
  DateTime updateTime = DateTime.now();

  // 下载任务
  @ignore
  DownloadTask? task;

  // 判断是否为m3u8文件
  bool get isM3U8 => Uri.parse(url).path.endsWith('.m3u8');

  // 创建下载任务
  DownloadRecord createTask(String savePath) {
    task = DownloadTask(cancelKey: CancelToken());
    this.savePath = savePath;
    return this;
  }

  // 更新下载任务信息
  DownloadRecord updateTask(int progress, int total, int speed) {
    if (task == null) return this;
    return this
      ..task = DownloadTask(
        cancelKey: task!.cancelKey,
        progress: progress,
        total: total,
        speed: speed,
      );
  }
}

enum DownloadRecordStatus { download, complete, fail }
