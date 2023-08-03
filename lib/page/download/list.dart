import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/manage/download/download.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/download.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/status_box.dart';

// 下载任务点击事件
typedef DownloadTaskTapCallback = void Function(DownloadRecord record);

/*
* 下载记录列表
* @author wuxubaiyang
* @Time 2023/7/23 14:05
*/
class DownloadRecordList extends StatelessWidget {
  // 下载记录列表
  final List<DownloadRecord> recordList;

  // 下载任务进度
  final DownloadTask? downloadTask;

  // 下载任务点击事件
  final DownloadTaskTapCallback? onTaskTap;

  // 下载任务长点击事件
  final DownloadTaskTapCallback? onTaskLongTap;

  // 番剧长点击事件
  final DownloadTaskTapCallback? onAnimeLongTap;

  const DownloadRecordList({
    super.key,
    required this.recordList,
    this.onTaskTap,
    this.downloadTask,
    this.onTaskLongTap,
    this.onAnimeLongTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recordList.isEmpty) {
      return const Center(
        child: StatusBox(
          status: StatusBoxStatus.empty,
        ),
      );
    }
    return ListView.builder(
      itemCount: recordList.length,
      itemBuilder: (_, i) {
        final item = recordList[i];
        if (i == 0 || recordList[i - 1].url != item.url) {
          return _buildDownloadAnimeItem(item);
        }
        return Padding(
          padding: const EdgeInsets.only(left: 82, bottom: 6),
          child: _buildDownloadTaskItem(item),
        );
      },
    );
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 16, color: Colors.black87);

  // 子标题文本
  final subTitleStyle = const TextStyle(fontSize: 14, color: Colors.black38);

  // 构建下载任务番剧信息
  Widget _buildDownloadAnimeItem(DownloadRecord item) {
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageView.net(item.cover,
                  width: 60, height: 70, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(item.title, style: titleStyle),
                ),
                const SizedBox(height: 8),
                _buildDownloadTaskItem(item),
              ],
            ),
          ),
        ],
      ),
      onLongPress: () => onAnimeLongTap?.call(item),
    );
  }

  // 构建下载任务列表项
  Widget _buildDownloadTaskItem(DownloadRecord item) {
    final valueColor = AlwaysStoppedAnimation(kPrimaryColor.withOpacity(0.15));
    const borderRadios = BorderRadius.horizontal(left: Radius.circular(8));
    final taskItem = downloadTask?.getDownloadTaskItem(item);
    final isStopping = download.inStoppingBuffed(item);
    final isWaiting = download.inWaitingBuffed(item);
    final statusIcon = !isWaiting
        ? Icon(_getPlayIconStatus(item), color: kPrimaryColor)
        : const SizedBox.square(
            dimension: 30,
            child: CircularProgressIndicator(),
          );
    return ClipRRect(
      borderRadius: borderRadios,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (taskItem != null)
            LinearProgressIndicator(
              valueColor: valueColor,
              value: taskItem.ratio,
              minHeight: 45,
            ),
          InkWell(
            borderRadius: borderRadios,
            child: SizedBox.fromSize(
              size: const Size.fromHeight(45),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(item.name, style: subTitleStyle),
                  const Spacer(),
                  if (taskItem != null)
                    Text('${FileTool.formatSize(taskItem.speed)}/s',
                        style: subTitleStyle),
                  const SizedBox(width: 14),
                  if (item.isFail)
                    IconButton(
                      icon: Icon(FontAwesomeIcons.triangleExclamation,
                          color: Colors.redAccent.withOpacity(0.8), size: 14),
                      onPressed: () =>
                          SnackTool.showMessage(message: item.failText ?? ''),
                    ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: statusIcon,
                    onPressed: () {
                      if (isStopping) return;
                      onTaskTap?.call(item);
                    },
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
            onLongPress: () => onTaskLongTap?.call(item),
            onTap: () {
              if (isStopping) return;
              onTaskTap?.call(item);
            },
          ),
        ],
      ),
    );
  }

  // 获取播放状态
  IconData _getPlayIconStatus(DownloadRecord item) {
    if (item.isComplete) return FontAwesomeIcons.circlePlay;
    if (download.inPrepareQueue(item)) return FontAwesomeIcons.hourglassHalf;
    if (download.inDownloadQueue(item)) return FontAwesomeIcons.pause;
    return FontAwesomeIcons.play;
  }
}
