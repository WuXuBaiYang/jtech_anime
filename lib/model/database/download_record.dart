import 'package:isar/isar.dart';

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

  // 所在资源组的名称
  String resName = '';

  // 下载地址
  @Index(type: IndexType.value)
  String downloadUrl = '';

  // 名称
  String name = '';

  // 保存地址
  String savePath = '';

  // 更新时间
  DateTime updateTime = DateTime.now();
}

enum DownloadRecordStatus { download, complete, fail }
