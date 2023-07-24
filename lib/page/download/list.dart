import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/widget/image.dart';

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

  // 下载任务点击事件
  final DownloadTaskTapCallback? onTaskTap;

  const DownloadRecordList(
      {super.key, required this.recordList, this.onTaskTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recordList.length,
      itemBuilder: (_, i) {
        final item = recordList[i];
        if (i == 0 || recordList[i - 1].url != item.url) {
          return _buildDownloadAnimeItem(context, item);
        }
        return Padding(
          padding: const EdgeInsets.only(left: 77, bottom: 6),
          child: _buildDownloadTaskItem(context, item),
        );
      },
    );
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 16, color: Colors.black87);

  // 子标题文本
  final subTitleStyle = const TextStyle(fontSize: 14, color: Colors.black38);

  // 构建下载任务番剧信息
  Widget _buildDownloadAnimeItem(BuildContext context, DownloadRecord item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageView.net(item.cover,
                width: 60, height: 80, fit: BoxFit.cover),
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
              _buildDownloadTaskItem(context, item),
            ],
          ),
        ),
      ],
    );
  }

  // 构建下载任务列表项
  Widget _buildDownloadTaskItem(BuildContext context, DownloadRecord item) {
    final iconData = item.isComplete
        ? FontAwesomeIcons.circlePlay
        : ((item.task != null && item.task!.downloading)
            ? FontAwesomeIcons.pause
            : FontAwesomeIcons.play);
    const borderRadios = BorderRadius.horizontal(left: Radius.circular(8));
    return ClipRRect(
      borderRadius: borderRadios,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item.task != null)
            LinearProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(kPrimaryColor.withOpacity(0.15)),
              value: item.task!.progress / item.task!.total,
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
                  if (item.task != null && item.task!.downloading)
                    Text('${FileTool.formatSize(item.task!.speed)}/s',
                        style: subTitleStyle),
                  const SizedBox(width: 14),
                  if (item.isFail)
                    Icon(FontAwesomeIcons.triangleExclamation,
                        color: Colors.redAccent.withOpacity(0.8), size: 12),
                  const SizedBox(width: 14),
                  Icon(iconData, color: kPrimaryColor),
                  const SizedBox(width: 14),
                ],
              ),
            ),
            onTap: () => onTaskTap?.call(item),
          ),
        ],
      ),
    );
  }
}
