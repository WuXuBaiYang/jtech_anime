import 'package:jtech_anime_base/common/model.dart';
import 'database/download_record.dart';

/*
* 总下载任务
* @author wuxubaiyang
* @Time 2023/8/1 14:33
*/
class DownloadTask extends BaseModel {
  // 总速度
  final int totalSpeed;

  // 总进度(指正在下载的任务进度和/正在下载的任务数)
  final double totalRatio;

  // 回调次数
  final int times;

  // 下载队列
  final Map<String, DownloadTaskItem> downloadingMap;

  DownloadTask({
    this.times = 0,
    this.totalSpeed = 0,
    this.totalRatio = 0,
    this.downloadingMap = const {},
  });

  // 根据任务获取对应的下载状态
  DownloadTaskItem? getDownloadTaskItem(DownloadRecord record) {
    // 如果存在下载任务则返回，如果在队列中则返回空，否则返回null
    return downloadingMap[record.downloadUrl] ??
        (downloadingMap.containsKey(record.downloadUrl)
            ? DownloadTaskItem.zero()
            : null);
  }
}

/*
* 下载任务
* @author wuxubaiyang
* @Time 2023/7/21 10:50
*/
class DownloadTaskItem extends BaseModel {
  // 已下载数量
  int count = 0;

  // 总数量
  int total = 0;

  // 下载速度
  int speed = 0;

  // 获取进度比例
  double get ratio {
    if (total == 0 || count == 0) return 0;
    return count / total;
  }

  DownloadTaskItem.zero();

  DownloadTaskItem(this.count, this.total, this.speed);

  // 叠加参数
  DownloadTaskItem stack(int count, int total, int speed) => this
    ..count = count
    ..total = total
    ..speed += speed;

  DownloadTaskItem copyWith({
    int? count,
    int? total,
    int? speed,
  }) =>
      DownloadTaskItem(
        count = count ?? this.count,
        total = total ?? this.total,
        speed = speed ?? this.speed,
      );
}
