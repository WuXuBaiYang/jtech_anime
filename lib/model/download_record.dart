import 'dart:io';
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

  // 资源地址
  String resUrl = '';

  // 下载地址
  @Index(type: IndexType.value, unique: true, replace: true)
  String downloadUrl = '';

  // 名称
  String name = '';

  // 保存地址
  String savePath = '';

  // 播放文件地址
  String playFilePath = '';

  // 更新时间
  DateTime updateTime = DateTime.now();

  // 下载记录排序
  int order = 0;

  // 判断状态是否已完成
  @ignore
  bool get isComplete => status == DownloadRecordStatus.complete;

  // 判断状态是否为下载
  @ignore
  bool get isDownload => status == DownloadRecordStatus.download;

  // 判断状态是否为异常
  @ignore
  bool get isFail => status == DownloadRecordStatus.fail;

  // 判断是否为m3u8文件
  @ignore
  bool get isM3U8 => downloadUrl.endsWith('.m3u8');

  // 获取播放文件
  @ignore
  File get playFile =>
      File(playFilePath.isNotEmpty ? playFilePath : '$savePath/index.m3u8');

  DownloadRecord copyWith({
    Id? id,
    String? url,
    String? source,
    String? name,
    String? cover,
    int? order,
    String? title,
    DownloadRecordStatus? status,
    String? failText,
    String? resUrl,
    String? downloadUrl,
    String? savePath,
    DateTime? updateTime,
  }) =>
      DownloadRecord()
        ..id = id ?? this.id
        ..url = url ?? this.url
        ..source = source ?? this.source
        ..name = name ?? this.name
        ..cover = cover ?? this.cover
        ..title = title ?? this.title
        ..status = status ?? this.status
        ..failText = failText ?? this.failText
        ..resUrl = resUrl ?? this.resUrl
        ..downloadUrl = downloadUrl ?? this.downloadUrl
        ..savePath = savePath ?? this.savePath
        ..updateTime = updateTime ?? this.updateTime
        ..order = order ?? this.order;

  @override
  int get hashCode => id.hashCode;

  @override
  operator ==(other) => other is DownloadRecord && other.id == id;
}

enum DownloadRecordStatus { download, complete, fail }
