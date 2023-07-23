import 'package:flutter/material.dart';
import 'package:jtech_anime/model/database/download_record.dart';

/*
* 下载记录列表
* @author wuxubaiyang
* @Time 2023/7/23 14:05
*/
class DownloadRecordList extends StatelessWidget {
  // 下载记录列表
  final List<DownloadRecord> recordList;

  const DownloadRecordList({super.key, required this.recordList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recordList.length,
      itemBuilder: (_, i) {
        final item = recordList[i];
        if (i == 0 || recordList[i - 1].url != item.url) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDownloadAnimeItem(item),
              _buildDownloadTaskItem(context, item),
            ],
          );
        }
        return _buildDownloadTaskItem(context, item);
      },
    );
  }

  // 构建下载任务番剧信息
  Widget _buildDownloadAnimeItem(DownloadRecord item) {
    return SizedBox();
  }

  // 构建下载任务列表项
  Widget _buildDownloadTaskItem(BuildContext context, DownloadRecord item) {
    return SizedBox();
  }
}
