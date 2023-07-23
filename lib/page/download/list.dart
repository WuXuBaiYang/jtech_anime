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
        return SizedBox();
      },
    );
  }
}
