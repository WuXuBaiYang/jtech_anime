import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/download.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/database/source.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/qr_code_sheet.dart';

/*
* 番剧解析源弹窗
* @author wuxubaiyang
* @Time 2023/8/16 14:59
*/
class AnimeSourceDialog extends StatefulWidget {
  const AnimeSourceDialog({super.key});

  static Future<AnimeSource?> show(BuildContext context) {
    return showCupertinoDialog<AnimeSource>(
      builder: (_) => const AnimeSourceDialog(),
      context: context,
    );
  }

  @override
  State<StatefulWidget> createState() => _AnimeSourceDialogState();
}

/*
* 番剧解析源弹窗-状态
* @author wuxubaiyang
* @Time 2023/8/16 14:59
*/
class _AnimeSourceDialogState extends State<AnimeSourceDialog> {
  // 记录当前选中的解析源信息
  late ValueChangeNotifier<AnimeSource?> currentSource =
      ValueChangeNotifier(animeParser.currentSource);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('选择解析源'),
      actions: [
        TextButton(onPressed: router.pop, child: const Text('取消')),
        TextButton(
          onPressed: () => _importSource(context),
          child: const Text('导入解析源'),
        ),
      ],
    );
  }

  // 导入解析源
  Future<void> _importSource(BuildContext context) async {
    final isMobilePhone = Platform.isAndroid || Platform.isIOS;
    final result = await (isMobilePhone
        ? QRCodeSheet.show(context)
        : Tool.decoderQRCodeFromGallery());
    if (result == null) return;

    /// 实现解析源导入
  }

  // 切换解析源
  Future<void> _changeSource(AnimeSource? source, AnimeSource? current) async {
    if (source == null || current == null) return;
    // 切换解析源同时暂停当前所有进行中的下载任务
    final records = await db.getDownloadRecordList(current,
        status: [DownloadRecordStatus.download]);
    await download.stopTasks(records);
    if (await animeParser.changeSource(source)) {
      return router.pop(source);
    }
    SnackTool.showMessage(message: '解析源切换失败');
  }
}