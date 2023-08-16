import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime/model/database/source.dart';

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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(

    );
  }
}
