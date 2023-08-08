import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/download.dart';
import 'package:jtech_anime/model/download_group.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/status_box.dart';

// 下载记录事件回调
typedef DownloadRecordCallback = void Function(List<DownloadRecord> records);

/*
* 下载记录列表(下载队列/已下载队列)
* @author wuxubaiyang
* @Time 2023/7/23 14:05
*/
class DownloadRecordListView extends StatefulWidget {
  // 下载记录列表
  final List<DownloadGroup> groupList;

  // 下载任务进度
  final DownloadTask? downloadTask;

  // 删除回调
  final DownloadRecordCallback? onRemoveRecords;

  // 播放回调
  final DownloadRecordCallback? onPlayRecords;

  // 开始下载回调
  final DownloadRecordCallback? onStartDownloads;

  // 停止下载回调
  final DownloadRecordCallback? onStopDownloads;

  // 默认展开的组
  final List<String> initialExpanded;

  const DownloadRecordListView({
    super.key,
    required this.groupList,
    this.initialExpanded = const [],
    this.onStartDownloads,
    this.onStopDownloads,
    this.onRemoveRecords,
    this.onPlayRecords,
    this.downloadTask,
  });

  @override
  State<DownloadRecordListView> createState() => _DownloadRecordListViewState();
}

class _DownloadRecordListViewState extends State<DownloadRecordListView> {
  // 记录折叠状态
  late ListValueChangeNotifier<String> expandedStatus =
      ListValueChangeNotifier([...widget.initialExpanded]);

  @override
  Widget build(BuildContext context) {
    if (widget.groupList.isEmpty) return _buildEmptyView();
    return ValueListenableBuilder<List<String>>(
      valueListenable: expandedStatus,
      builder: (_, expandedList, __) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: widget.groupList.length,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemBuilder: (_, i) {
            final item = widget.groupList[i];
            final expanded = expandedList.contains(item.url);
            return _buildGroupItem(item, expanded);
          },
        );
      },
    );
  }

  // 构建分组项
  Widget _buildGroupItem(DownloadGroup item, bool expanded) {
    final downloadTask = widget.downloadTask;
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              ImageView.net(
                width: 70,
                height: 80,
                item.cover,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 8),
                  title: Text(item.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: SizedBox.fromSize(
                    size: const Size.fromHeight(40),
                    child: _buildGroupItemSimpleDownloadingInfo(
                        item.records,
                        downloadTask ??
                            DownloadTask(
                              downloadingMap: {
                                item.records.first.downloadUrl:
                                    DownloadTaskItem(10, 100, 581012),
                              },
                            ),
                        expanded),
                  ),
                  // subtitle: downloadTask != null
                  //     ? _buildGroupItemSimpleDownloadingInfo(
                  //         item.records, downloadTask, expanded)
                  //     : _buildGroupItemSimpleDownloadedInfo(item.records),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(FontAwesomeIcons.chevronDown),
                  onPressed: () => _toggleExpanded(item.url),
                ),
              ),
            ]),
            if (expanded)
              widget.downloadTask != null
                  ? _buildGroupItemDownloadingRecords(item.records)
                  : _buildGroupItemDownloadedRecords(item.records),
          ],
        ),
        onTap: () => _toggleExpanded(item.url),
        onLongPress: () => widget.onRemoveRecords?.call(item.records),
      ),
    );
  }

  // 构建组信息中下载队列简略信息
  Widget _buildGroupItemSimpleDownloadingInfo(
      List<DownloadRecord> records, DownloadTask task, bool expanded) {
    num speed = 0, ratio = 0, count = 0;
    // 遍历组内任务并计算速度、进度、正在下载任务数
    for (var e in records) {
      final item = task.getDownloadTaskItem(e);
      if (item == null) continue;
      speed += item.speed;
      ratio += item.ratio;
      count++;
    }
    if (count > 0) ratio = ratio / count;
    final content = count > 0
        ? '正在下载 $count 条任务  ·  ${FileTool.formatSize(speed.toInt())}'
        : '共有 ${records.length} 条下载任务';
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // 如果有下载任务并且是折叠状态则展示进度条
        if (count > 0)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.toDouble(),
                  backgroundColor: Colors.transparent,
                  color: kPrimaryColor.withOpacity(0.2),
                ),
              ),
            ),
          ),
        Padding(
          padding: count > 0 ? const EdgeInsets.only(left: 8) : EdgeInsets.zero,
          child: Text(
            style: const TextStyle(color: Colors.black38, fontSize: 12),
            content,
          ),
        ),
      ],
    );
  }

  // 构建组信息中已下载队列简略信息
  Widget _buildGroupItemSimpleDownloadedInfo(List<DownloadRecord> records) {
    return Text('已下载 ${records.length} 条视频');
  }

  // 构建分组项下载中列表
  Widget _buildGroupItemDownloadingRecords(List<DownloadRecord> records) {
    return SizedBox(
      height: 300,
    );
  }

  // 构建分组项已下载列表
  Widget _buildGroupItemDownloadedRecords(List<DownloadRecord> records) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: records.length,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 40,
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        final item = records[i];
        return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }

  // 标题文本样式
  Widget _buildEmptyView() {
    return const Center(
      child: StatusBox(status: StatusBoxStatus.empty),
    );
  }

  // 切换折叠展开状态
  void _toggleExpanded(String key) {
    if (!expandedStatus.removeValue(key)) {
      expandedStatus.addValue(key);
    }
  }
}
