import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

// 资源选择回调
typedef ResourceSelect = void Function(ResourceItemModel item);

/*
* 播放器资源选择弹窗
* @author wuxubaiyang
* @Time 2023/7/18 12:29
*/
class PlayerResourceDrawer extends StatelessWidget {
  // 当前正在播放的资源
  final ResourceItemModel? currentItem;

  // 资源选择回调
  final ResourceSelect? onResourceSelect;

  // 当前番剧的信息
  final AnimeModel animeInfo;

  const PlayerResourceDrawer({
    super.key,
    required this.animeInfo,
    this.onResourceSelect,
    this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    final length = animeInfo.resources.length;
    final index = _findResourceIndex(currentItem);
    return Drawer(
      backgroundColor: Colors.black54,
      child: DefaultTabController(
        length: length,
        initialIndex: index,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResourceTab(length),
            const Divider(color: Colors.white, thickness: 0.1, height: 1),
            Expanded(child: _buildResourceTabView(length)),
          ],
        ),
      ),
    );
  }

  // 构建资源分类tab
  Widget _buildResourceTab(int length) {
    return TabBar(
      isScrollable: true,
      indicatorColor: kPrimaryColor,
      dividerColor: Colors.transparent,
      unselectedLabelColor: Colors.white54,
      tabs: List.generate(length, (i) {
        return Tab(text: '资源${i + 1}');
      }),
    );
  }

  // 构建资源分类tabView
  Widget _buildResourceTabView(int length) {
    return CacheFutureBuilder<Map<String, DownloadRecord>>(
      future: _loadDownloadRecordMap,
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();
        final downloadMap = snap.data!;
        final resources = animeInfo.resources;
        return TabBarView(
          children: List.generate(resources.length, (i) {
            final items = resources[i];
            return GridView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120,
                mainAxisExtent: 40,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, i) {
                final item = items[i];
                final downloaded = downloadMap.containsKey(item.url);
                return _buildAnimeResourcesItem(item, downloaded);
              },
            );
          }),
        );
      },
    );
  }

  // 构建资源分类tabView子项
  Widget _buildAnimeResourcesItem(ResourceItemModel item, bool downloaded) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: currentItem?.url == item.url
                ? CustomScrollText.slow('正在看 ${item.name}',
                    style: TextStyle(color: kPrimaryColor))
                : Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54),
                  ),
          ),
          if (downloaded)
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(FontAwesomeIcons.circleCheck,
                  color: kPrimaryColor, size: 14),
            ),
        ],
      ),
      onTap: () => onResourceSelect?.call(item),
    );
  }

  // 加载已下载记录表
  Future<Map<String, DownloadRecord>> _loadDownloadRecordMap() async {
    final source = animeParser.currentSource;
    if (source == null) return {};
    return db.getDownloadRecordList(source, animeList: [animeInfo.url]).then(
        (v) => v.asMap().map((_, v) => MapEntry(v.resUrl, v)));
  }

  // 获取资源下标
  int _findResourceIndex(ResourceItemModel? item) {
    if (item == null) return 0;
    final index = animeInfo.resources.indexWhere((e) {
      final first = e.firstWhereOrNull((e) {
        return e.url == item.url;
      });
      return first != null;
    });
    return max(index, 0);
  }
}
