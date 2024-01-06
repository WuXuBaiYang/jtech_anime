import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

import 'downloaded.dart';
import 'downloading.dart';
import 'selector.dart';

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

  // 播放记录
  final Map<String, PlayRecord>? playRecordMap;

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

  // 列表间距
  final EdgeInsetsGeometry? padding;

  const DownloadRecordListView({
    super.key,
    required this.groupList,
    this.initialExpanded = const [],
    this.onStartDownloads,
    this.onStopDownloads,
    this.onRemoveRecords,
    this.playRecordMap,
    this.onPlayRecords,
    this.downloadTask,
    this.padding,
  });

  @override
  State<DownloadRecordListView> createState() => _DownloadRecordListViewState();
}

class _DownloadRecordListViewState extends State<DownloadRecordListView> {
  // 记录折叠状态
  late final expandedStatus =
      ListValueChangeNotifier([...widget.initialExpanded]);

  // 已选择下载记录
  final selectedRecords = ListValueChangeNotifier<DownloadRecord>.empty();

  @override
  void initState() {
    super.initState();
    // 监听下载状态变化
    download.addDownloadCompleteListener((record) {
      selectedRecords.removeWhere(
        (e) => e.id == record.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupList.isEmpty) return _buildEmptyView();
    return ValueListenableBuilder<List<DownloadRecord>>(
      valueListenable: selectedRecords,
      builder: (_, selectedRecords, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedRecords.isNotEmpty)
              _buildSelectHeader(context, selectedRecords),
            Expanded(child: _buildDownloadRecords(selectedRecords)),
          ],
        );
      },
    );
  }

  // 构建选择头部
  Widget _buildSelectHeader(
      BuildContext context, List<DownloadRecord> selectedRecords) {
    final totalRecords = widget.groupList.expand((e) => e.records).length;
    final checked = selectedRecords.length >= totalRecords;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 4, horizontal: (widget.padding?.horizontal ?? 0) + 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => _showDeleteDialog(context, selectedRecords),
            child: Text('删除(${selectedRecords.length})'),
          ),
          Checkbox(
            tristate: true,
            value: checked ? true : null,
            onChanged: (value) {
              if (value == true) {
                this.selectedRecords.addValues(
                    widget.groupList.expand((e) => e.records).toList());
              } else {
                this.selectedRecords.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  // 构建下载记录
  Widget _buildDownloadRecords(List<DownloadRecord> selectedRecords) {
    if (selectedRecords.isNotEmpty) {
      return DownloadRecordSelectorList(
        padding: widget.padding,
        groupList: widget.groupList,
        selectedRecords: selectedRecords,
        onSelectRecords: (values) {
          for (final v in values) {
            if (selectedRecords.contains(v)) {
              selectedRecords.remove(v);
            } else {
              selectedRecords.add(v);
            }
          }
          this.selectedRecords.setValue([...selectedRecords]);
        },
      );
    }
    return ValueListenableBuilder<List<String>>(
      valueListenable: expandedStatus,
      builder: (_, expandedList, __) {
        return ListView.builder(
          itemCount: widget.groupList.length,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
          itemBuilder: (_, i) {
            return _buildGroupItem(widget.groupList[i], expandedList);
          },
        );
      },
    );
  }

  // 构建分组项
  Widget _buildGroupItem(DownloadGroup group, List<String> expandedList) {
    final downloadTask = widget.downloadTask;
    final expanded = expandedList.contains(group.url);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: kPrimaryColor.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGroupItemInfo(
              group,
              expanded: expanded,
              downloadTask: downloadTask,
            ),
            const SizedBox(height: 2),
            if (expanded)
              _buildGroupItemRecords(group.records,
                  downloadTask: downloadTask,
                  playRecord: widget.playRecordMap?[group.url]),
          ],
        ),
        onTap: () => _toggleExpanded(group.url),
        onLongPress: () => selectedRecords.addValues(group.records),
      ),
    );
  }

  // 构建组信息
  Widget _buildGroupItemInfo(DownloadGroup group,
      {required bool expanded, DownloadTask? downloadTask}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: ImageView.net(
            width: 70,
            height: 85,
            group.cover,
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 14),
            title: Text(
              group.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: SizedBox.fromSize(
              size: const Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildGroupItemInfoSimple(group.records,
                    expanded: expanded, downloadTask: downloadTask),
              ),
            ),
          ),
        ),
        AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            iconSize: 20,
            color: kPrimaryColor.withOpacity(0.5),
            onPressed: () => _toggleExpanded(group.url),
            icon: const Icon(FontAwesomeIcons.chevronDown),
          ),
        ),
      ],
    );
  }

  // 构建组信息缩略信息
  Widget _buildGroupItemInfoSimple(List<DownloadRecord> records,
      {required bool expanded, DownloadTask? downloadTask}) {
    if (downloadTask != null) {
      num speed = 0, ratio = 0, count = 0;
      // 遍历组内任务并计算速度、进度、正在下载任务数
      for (var e in records) {
        final item = downloadTask.getDownloadTaskItem(e);
        if (item == null) continue;
        speed += item.speed;
        ratio += item.ratio;
        count++;
      }
      if (count > 0) ratio = ratio / count;
      final content = count > 0
          ? '正在下载 $count 条任务  ·  ${FileTool.formatSize(speed.toInt())}/s'
          : '共有 ${records.length} 条下载任务';
      final showProgress = count > 0 && !expanded;
      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 如果有下载任务并且是折叠状态则展示进度条
          if (showProgress)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.toDouble(),
                  backgroundColor: Colors.transparent,
                  color: kPrimaryColor.withOpacity(0.2),
                ),
              ),
            ),
          Padding(
            padding: showProgress
                ? const EdgeInsets.symmetric(horizontal: 8)
                : EdgeInsets.zero,
            child: Text(content,
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 12,
                )),
          ),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '已下载 ${records.length} 条视频',
        style: const TextStyle(color: Colors.black38, fontSize: 12),
      ),
    );
  }

  // 构建折叠列表组件
  Widget _buildGroupItemRecords(List<DownloadRecord> records,
      {DownloadTask? downloadTask, PlayRecord? playRecord}) {
    if (downloadTask != null) {
      return DownloadingRecordList(
        records: records,
        downloadTask: downloadTask,
        onStopDownloads: widget.onStopDownloads,
        onStartDownloads: widget.onStartDownloads,
        onRemoveRecords: selectedRecords.addValues,
      );
    }
    return DownloadedRecordList(
      records: records,
      playRecord: playRecord,
      onPlayRecords: widget.onPlayRecords,
      onRemoveRecords: selectedRecords.addValues,
    );
  }

  // 展示删除弹窗
  Future<void> _showDeleteDialog(
      BuildContext context, List<DownloadRecord> records) async {
    if (records.isEmpty) return;
    final item = records.first;
    final content = '是否删除 ${item.title} ${item.name} '
        '${records.length > 1 ? '等${records.length}条下载记录' : ''}';
    return MessageDialog.show(
      context,
      title: const Text('删除'),
      content: Text(content),
      actionMiddle: TextButton(
        child: const Text('取消'),
        onPressed: () => router.pop(),
      ),
      actionRight: TextButton(
        child: const Text('删除'),
        onPressed: () {
          router.pop();
          widget.onRemoveRecords?.call(records);
          selectedRecords.removeWhere(records.contains);
        },
      ),
    );
  }

  // 标题文本样式
  Widget _buildEmptyView() {
    return const Center(
      child: StatusBox(
        status: StatusBoxStatus.empty,
      ),
    );
  }

  // 切换折叠展开状态
  void _toggleExpanded(String key) {
    if (!expandedStatus.removeValue(key)) {
      expandedStatus.addValue(key);
    }
  }
}
