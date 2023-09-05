import 'package:jtech_anime/common/model.dart';
import 'database/download_record.dart';

/*
* 下载记录分组
* @author wuxubaiyang
* @Time 2023/8/8 11:03
*/
class DownloadGroup extends BaseModel {
  // 最近的更新时间
  final DateTime updateTime;

  // 番剧名称
  final String title;

  // 番剧封面
  final String cover;

  // 番剧地址
  final String url;

  // 番剧来源
  final String source;

  // 资源列表
  final List<DownloadRecord> records;

  DownloadGroup({
    required this.updateTime,
    required this.title,
    required this.cover,
    required this.url,
    required this.source,
    required this.records,
  });

  // 从记录集合中封装成组
  static DownloadGroup? fromRecords(List<DownloadRecord> records) {
    if (records.isEmpty) return null;
    final item = records.first;
    // 对下载记录列表重新排序并获取最新的更新时间
    DateTime updateTime = item.updateTime;
    records.sort((l, r) {
      if (r.updateTime.compareTo(updateTime) > 1) {
        updateTime = r.updateTime;
      }
      return l.order.compareTo(r.order);
    });
    return DownloadGroup(
      url: item.url,
      title: item.title,
      cover: item.cover,
      source: item.source,
      records: records,
      updateTime: updateTime,
    );
  }
}
