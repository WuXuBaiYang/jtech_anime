import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

import 'list.dart';

/*
* 下载记录列表-下载中
* @author wuxubaiyang
* @Time 2023/11/2 15:37
*/
class DownloadingRecordList extends StatelessWidget {
  // 下载记录
  final List<DownloadRecord> records;

  // 下载任务
  final DownloadTask? downloadTask;

  // 删除回调
  final DownloadRecordCallback? onRemoveRecords;

  // 开始下载回调
  final DownloadRecordCallback? onStartDownloads;

  // 停止下载回调
  final DownloadRecordCallback? onStopDownloads;

  const DownloadingRecordList({
    super.key,
    required this.records,
    this.onStartDownloads,
    this.onStopDownloads,
    this.onRemoveRecords,
    this.downloadTask,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: records.length,
      padding: const EdgeInsets.only(top: 2),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, i) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        return _buildRecordListItem(records[i]);
      },
    );
  }

  // 构建下载记录列表子项
  Widget _buildRecordListItem(DownloadRecord record) {
    final task = downloadTask?.getDownloadTaskItem(record);
    final speedText =
        task != null ? '  ·  ${FileTool.formatSize(task.speed)}/s' : '';
    const textStyle = TextStyle(color: Colors.black38, fontSize: 12);
    return InkWell(
      child: SizedBox.fromSize(
        size: const Size.fromHeight(40),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (task != null)
              Positioned.fill(
                child: LinearProgressIndicator(
                  value: task.ratio,
                  backgroundColor: Colors.transparent,
                  color: kPrimaryColor.withOpacity(0.2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text('${record.name}$speedText', style: textStyle),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(_getDownloadingStatusIcon(record),
                    color: kPrimaryColor, size: 22),
              ),
            ),
          ],
        ),
      ),
      onLongPress: () => onRemoveRecords?.call([record]),
      onTap: () {
        if (download.inStoppingBuffed(record)) return;
        return (task != null || download.inStartingBuffed(record))
            ? onStopDownloads?.call([record])
            : onStartDownloads?.call([record]);
      },
    );
  }

  // 获取当前下载状态图标
  IconData _getDownloadingStatusIcon(DownloadRecord record) {
    if (downloadTask != null) return FontAwesomeIcons.pause;
    if (download.inWaitingBuffed(record) || download.inPrepareQueue(record)) {
      return FontAwesomeIcons.hourglass;
    }
    return FontAwesomeIcons.play;
  }
}
