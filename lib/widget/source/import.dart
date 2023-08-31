import 'package:flutter/material.dart';
import 'package:jtech_anime/model/database/source.dart';

/*
* 番剧解析源导入sheet
* @author wuxubaiyang
* @Time 2023/8/31 17:09
*/
class AnimeSourceImportSheet extends StatefulWidget {
  const AnimeSourceImportSheet({super.key});

  static Future<AnimeSource?> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return const AnimeSourceImportSheet();
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _AnimeSourceImportSheetState();
}

/*
* 番剧解析源导入sheet-状态
* @author wuxubaiyang
* @Time 2023/8/31 17:10
*/
class _AnimeSourceImportSheetState extends State<AnimeSourceImportSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
