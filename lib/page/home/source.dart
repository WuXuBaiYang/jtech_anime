import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime/model/database/source.dart';

/*
* 番剧解析源快速切换弹窗
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class AnimeSourceChangeDialog extends StatefulWidget {
  const AnimeSourceChangeDialog({super.key});

  static Future<AnimeSource?> show(BuildContext context) {
    return showCupertinoDialog<AnimeSource>(
      context: context,
      builder: (_) {
        return const AnimeSourceChangeDialog();
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _AnimeSourceChangeDialogState();
}

/*
* 番剧解析源快速切换弹窗-状态
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class _AnimeSourceChangeDialogState extends State<AnimeSourceChangeDialog> {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
