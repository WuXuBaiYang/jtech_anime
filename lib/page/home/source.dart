import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/database/source.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/anime_source.dart';
import 'package:jtech_anime/widget/future_builder.dart';

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
      barrierDismissible: true,
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
    final screenHeight = Tool.getScreenHeight(context);
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6,
        ),
        child: _buildAnimeSourceList(),
      ),
    );
  }

  // 构建番剧解析源列表
  Widget _buildAnimeSourceList() {
    final current = animeParser.currentSource;
    return CacheFutureBuilder<List<AnimeSource>>(
      future: db.getAnimeSourceList,
      builder: (_, snap) {
        final animeSources = snap.data ?? [];
        return ListView.builder(
          shrinkWrap: true,
          itemCount: animeSources.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, i) {
            return _buildAnimeSourceListItem(
              animeSources[i],
              current,
            );
          },
        );
      },
    );
  }

  // 构建番剧解析源列表项
  Widget _buildAnimeSourceListItem(AnimeSource item, AnimeSource? current) {
    final selected = current?.key == item.key;
    return ListTile(
      isThreeLine: true,
      title: Text(item.name),
      leading: ClipOval(
        child: Container(
          padding: const EdgeInsets.all(2),
          color: selected ? kPrimaryColor : null,
          child: AnimeSourceView(
            source: item,
            ratio: selected ? 24 : 20,
          ),
        ),
      ),
      subtitle: DefaultTextStyle(
        maxLines: 1,
        style: const TextStyle(color: Colors.black38),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.homepage),
            Row(
              children: [
                Text('v${item.version}'),
                const SizedBox(width: 8),
                Icon(FontAwesomeIcons.globe, size: 12, color: kPrimaryColor),
                const SizedBox(width: 4),
                Icon(FontAwesomeIcons.skullCrossbones,
                    size: 12, color: kPrimaryColor),
              ],
            ),
          ],
        ),
      ),
      onTap: () async {
        final result = await animeParser.changeSource(item);
        if (!result) return;
        SnackTool.showMessage(
            message: '已切换解析源为 ${animeParser.currentSource?.name}');
        router.pop(item);
      },
    );
  }
}
