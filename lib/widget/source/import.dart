import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jtech_anime/model/database/source.dart';
import 'package:jtech_anime/widget/qr_code/sheet.dart';

/*
* 番剧解析源导入sheet
* @author wuxubaiyang
* @Time 2023/8/31 17:09
*/
class AnimeSourceImportSheet extends StatefulWidget {
  // 获取到的解析源
  final AnimeSource source;

  const AnimeSourceImportSheet({super.key, required this.source});

  static Future<AnimeSource?> show(BuildContext context) async {
    return QRCodeSheet.show(context).then((result) {
      if (result == null) return null;
      final source = AnimeSource.from(jsonDecode(result));
      return showModalBottomSheet<AnimeSource>(
        context: context,
        builder: (_) {
          return AnimeSourceImportSheet(
            source: source,
          );
        },
      );
    });
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
