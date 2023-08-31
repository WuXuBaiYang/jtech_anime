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
import 'package:jtech_anime/widget/source/import.dart';
import 'package:jtech_anime/widget/source/logo.dart';
import 'package:jtech_anime/widget/future_builder.dart';

/*
* 番剧解析源快速切换弹窗
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class AnimeSourceChangeDialog extends StatefulWidget {
  // 是否可取消
  final bool dismissible;

  const AnimeSourceChangeDialog({
    super.key,
    this.dismissible = true,
  });

  static Future<AnimeSource?> show(BuildContext context,
      {bool dismissible = true}) {
    return showCupertinoDialog<AnimeSource>(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) {
        return AnimeSourceChangeDialog(
          dismissible: dismissible,
        );
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
  // 番剧解析源缓存控制器
  final controller = CacheFutureBuilderController<List<AnimeSource>>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = Tool.getScreenHeight(context);
    return WillPopScope(
      child: AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: EdgeInsets.zero,
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.6,
          ),
          child: _buildAnimeSourceList(),
        ),
      ),
      onWillPop: () async => widget.dismissible,
    );
  }

  // 构建番剧解析源列表
  Widget _buildAnimeSourceList() {
    final current = animeParser.currentSource;
    return CacheFutureBuilder<List<AnimeSource>>(
      controller: controller,
      future: db.getAnimeSourceList,
      builder: (_, snap) {
        final animeSources = snap.data ?? [];
        return CustomScrollView(
          shrinkWrap: true,
          slivers: [
            if (animeSources.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                sliver: SliverList.builder(
                  itemCount: animeSources.length,
                  itemBuilder: (_, i) {
                    return _buildAnimeSourceListItem(
                      animeSources[i],
                      current,
                    );
                  },
                ),
              ),
            if (animeSources.isEmpty)
              SliverList.list(children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  icon: const Icon(FontAwesomeIcons.plus),
                  onPressed: () => AnimeSourceImportSheet.show(context).then(
                    (source) {
                      if (source != null) controller.refreshValue();
                    },
                  ),
                ),
              ]),
          ],
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
          child: AnimeSourceLogo(
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
