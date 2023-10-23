import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'proxy_update.dart';

/*
* 番剧代理设置弹窗
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class AnimeSourceProxyDialog extends StatefulWidget {
  const AnimeSourceProxyDialog({
    super.key,
  });

  static Future<AnimeSource?> show(BuildContext context) {
    return showCupertinoDialog<AnimeSource>(
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return const AnimeSourceProxyDialog();
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _AnimeSourceProxyDialogState();
}

/*
* 番剧解析源快速切换弹窗-状态
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class _AnimeSourceProxyDialogState extends State<AnimeSourceProxyDialog> {
  // 缓存控制器
  final controller = CacheFutureBuilderController<List<ProxyRecord>>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      clipBehavior: Clip.hardEdge,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      content: CacheFutureBuilder<List<ProxyRecord>>(
        controller: controller,
        future: proxy.getProxyList,
        builder: (_, snap) {
          final proxyList = snap.data ?? [];
          return StreamBuilder(
            stream: event.on<ProxyChangeEvent>(),
            initialData: ProxyChangeEvent(proxy.currentProxy),
            builder: (_, snap) {
              final currentProxy = snap.data?.record;
              return Column(
                children: [
                  ..._buildProxyList(proxyList, currentProxy),
                  if (proxyList.isNotEmpty) const SizedBox(height: 14),
                  IconButton.outlined(
                    icon: const Icon(FontAwesomeIcons.plus),
                    onPressed: () async {
                      final result =
                          await AnimeSourceProxyUpdateSheet.show(context);
                      if (result != null) controller.refreshValue();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // 构建代理列表
  List<Widget> _buildProxyList(
      List<ProxyRecord> proxyList, ProxyRecord? currentProxy) {
    return List.generate(proxyList.length, (i) {
      final item = proxyList[i];
      return RadioListTile(
        toggleable: true,
        value: item.proxy,
        groupValue: currentProxy?.proxy,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        onChanged: (v) => proxy.setCurrentProxy(v == null ? null : item),
        title: Row(
          children: [
            Expanded(child: Text(item.proxy, maxLines: 1)),
            IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                final result = await AnimeSourceProxyUpdateSheet.show(context,
                    record: item);
                if (result != null) controller.refreshValue();
              },
              icon: const Icon(FontAwesomeIcons.pencil),
            ),
            IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                final result = await proxy.deleteProxy(item);
                if (result) controller.refreshValue();
              },
              icon: const Icon(FontAwesomeIcons.trash),
            ),
          ],
        ),
      );
    });
  }
}
