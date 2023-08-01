import 'package:jtech_anime/common/model.dart';
import 'package:jtech_anime/model/database/download_record.dart';

/*
* 总下载任务
* @author wuxubaiyang
* @Time 2023/8/1 14:33
*/
class DownloadTask extends BaseModel {
  // 总速度
  final int totalSpeed;

  // 总进度
  final double totalRatio;

  // 回调次数
  final int times;

  // 下载队列
  final List<String> downloadingList;

  // 准备队列
  final List<String> prepareList;

  // 下载队列
  final Map<String, DownloadTaskItem> downloadingMap;

  DownloadTask({
    this.times = 0,
    this.totalSpeed = 0,
    this.totalRatio = 0,
    this.downloadingMap = const {},
    this.downloadingList = const [],
    this.prepareList = const [],
  });

  // 根据任务获取对应的下载状态
  DownloadTaskItem? getDownloadTaskItem(DownloadRecord record) {
    // 如果存在下载任务则返回，如果在队列中则返回空，否则返回null
    return downloadingMap[record.downloadUrl] ??
        (isDownloading(record) || isPrepared(record)
            ? DownloadTaskItem.zero()
            : null);
  }

  // 判断任务是否为下载中
  bool isDownloading(DownloadRecord record) =>
      downloadingList.contains(record.downloadUrl);

  // 判断任务是否为准备中
  bool isPrepared(DownloadRecord record) =>
      prepareList.contains(record.downloadUrl);
}

/*
* 下载任务
* @author wuxubaiyang
* @Time 2023/7/21 10:50
*/
class DownloadTaskItem extends BaseModel {
  // 已下载数量
  final int count;

  // 总数量
  final int total;

  // 下载速度
  final int speed;

  // 获取进度比例
  double get ratio {
    if (total == 0 || count == 0) return 0;
    return count / total;
  }

  DownloadTaskItem(this.count, this.total, this.speed);

  DownloadTaskItem.zero()
      : count = 0,
        total = 0,
        speed = 0;

  // 叠加参数
  DownloadTaskItem stack(int count, int total, int speed) => DownloadTaskItem(
        this.count + count,
        this.total + total,
        this.speed + speed,
      );
}
