import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'list.dart';

/*
* 下载记录选择器
* @author wuxubaiyang
* @Time 2023/11/3 9:34
*/
class DownloadRecordSelectorList extends StatelessWidget {
  // 下载记录集合
  final List<DownloadGroup> groupList;

  // 已选择集合
  final List<DownloadRecord> selectedRecords;

  // 选择回调
  final DownloadRecordCallback? onSelectRecords;

  // 列表间距
  final EdgeInsetsGeometry? padding;

  const DownloadRecordSelectorList({
    super.key,
    required this.selectedRecords,
    required this.groupList,
    this.onSelectRecords,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groupList.length,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      itemBuilder: (_, i) {
        return _buildGroupItem(groupList[i]);
      },
    );
  }

  // 构建分组项
  Widget _buildGroupItem(DownloadGroup group) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: kPrimaryColor.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGroupItemInfo(group),
            const SizedBox(height: 2),
            _buildGroupItemRecords(group.records),
          ],
        ),
        onTap: () => onSelectRecords?.call(group.records),
      ),
    );
  }

  // 构建组信息
  Widget _buildGroupItemInfo(DownloadGroup group) {
    final selectedCount =
        group.records.where((e) => selectedRecords.contains(e)).length;
    final checked = selectedCount > 0
        ? (selectedCount >= group.records.length ? true : null)
        : false;
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
          child: CheckboxListTile(
            value: checked,
            tristate: true,
            contentPadding: const EdgeInsets.only(left: 14, right: 8),
            onChanged: (value) {
              final records = value == true
                  ? group.records
                  : group.records.where(selectedRecords.contains).toList();
              onSelectRecords?.call(records);
            },
            title: Text(
              group.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text('共有 ${group.records.length} 条下载任务',
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 12,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  // 构建组子列表
  Widget _buildGroupItemRecords(List<DownloadRecord> records) {
    const textStyle = TextStyle(color: Colors.black38, fontSize: 12);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: records.length,
      itemBuilder: (_, i) {
        final record = records[i];
        return InkWell(
          child: Padding(
            padding: const EdgeInsets.all(4).copyWith(right: 0, left: 8),
            child: Row(
              children: [
                Text(
                  record.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
                const Spacer(),
                Checkbox(
                  value: selectedRecords.contains(record),
                  onChanged: (_) => onSelectRecords?.call([record]),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          onTap: () => onSelectRecords?.call([record]),
        );
      },
    );
  }
}
