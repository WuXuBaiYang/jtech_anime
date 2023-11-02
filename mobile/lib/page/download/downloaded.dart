import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:mobile/widget/text_scroll.dart';
import 'list.dart';

/*
* 下载记录列表-已下载
* @author wuxubaiyang
* @Time 2023/11/2 15:37
*/
class DownloadedRecordList extends StatelessWidget {
  // 下载记录
  final List<DownloadRecord> records;

  // 当前播放记录
  final PlayRecord? playRecord;

  // 删除回调
  final DownloadRecordCallback? onRemoveRecords;

  // 播放回调
  final DownloadRecordCallback? onPlayRecords;

  const DownloadedRecordList({
    super.key,
    required this.records,
    this.onRemoveRecords,
    this.onPlayRecords,
    this.playRecord,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: records.length,
      padding: const EdgeInsets.all(4),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 40,
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        return _buildRecordListItem(records[i]);
      },
    );
  }

  // 构建下载记录列表子项
  Widget _buildRecordListItem(DownloadRecord record) {
    final hasPlayRecord = playRecord?.resUrl == record.resUrl;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onPlayRecords?.call([record]),
      onLongPress: () => onRemoveRecords?.call([record]),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
        ),
        child: hasPlayRecord
            ? CustomScrollText.slow('上次看到 ${record.name}',
            style: TextStyle(color: kPrimaryColor))
            : Text(record.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
