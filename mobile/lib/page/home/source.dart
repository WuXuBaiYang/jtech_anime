import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widget/source_import.dart';
import 'package:jtech_anime_base/base.dart';

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
    return WillPopScope(
      child: AlertDialog(
        scrollable: true,
        clipBehavior: Clip.hardEdge,
        content: _buildAnimeSourceList(),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onWillPop: () async => widget.dismissible,
    );
  }

  // 构建番剧解析源列表
  Widget _buildAnimeSourceList() {
    final source = animeParser.currentSource;
    return CacheFutureBuilder<List<AnimeSource>>(
      controller: controller,
      future: db.getAnimeSourceList,
      builder: (_, snap) {
        final animeSources = snap.data ?? [];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              animeSources.length,
              (i) => _buildAnimeSourceListItem(animeSources[i], source),
            ),
            if (animeSources.isEmpty)
              IconButton.outlined(
                icon: const Icon(FontAwesomeIcons.plus),
                onPressed: () => AnimeSourceImportSheet.show(
                  context,
                  title: const Text('扫码并导入插件'),
                ).then((source) {
                  if (source != null) controller.refreshValue();
                }),
              ),
          ],
        );
      },
    );
  }

  // 构建番剧解析源列表项
  Widget _buildAnimeSourceListItem(AnimeSource item, AnimeSource? current) {
    final selected = current?.key == item.key;
    return ListTile(
      title: Text(item.name),
      leading: ClipOval(
        child: Container(
          padding: const EdgeInsets.all(2),
          color: selected ? kPrimaryColor : null,
          child: AnimeSourceLogo(source: item, ratio: 20),
        ),
      ),
      subtitle: DefaultTextStyle(
        maxLines: 1,
        style: const TextStyle(color: Colors.black38),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 4),
            // Text(item.homepage),
            Row(
              children: [
                Text('v${item.version}'),
                const SizedBox(width: 8),
                if (item.proxy)
                  const Icon(FontAwesomeIcons.globe,
                      size: 12, color: Colors.red),
                if (item.nsfw) ...[
                  const SizedBox(width: 4),
                  const Icon(FontAwesomeIcons.skullCrossbones,
                      size: 12, color: Colors.red),
                ],
              ],
            ),
          ],
        ),
      ),
      onTap: () async {
        final result = await animeParser.changeSource(item);
        if (!result) return;
        SnackTool.showMessage(
            message: '已切换插件为 ${animeParser.currentSource?.name}');
        router.pop(item);
      },
    );
  }
}
