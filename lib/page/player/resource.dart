import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/widget/text_scroll.dart';

// 资源选择回调
typedef ResourceSelect = void Function(ResourceItemModel item);

/*
* 播放器资源选择弹窗
* @author wuxubaiyang
* @Time 2023/7/18 12:29
*/
class PlayerResourceDrawer extends StatelessWidget {
  // 资源二维数组
  final List<List<ResourceItemModel>> resources;

  // 当前正在播放的资源
  final ResourceItemModel? currentItem;

  // 资源选择回调
  final ResourceSelect? onResourceSelect;

  const PlayerResourceDrawer({
    super.key,
    required this.resources,
    this.onResourceSelect,
    this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    final length = resources.length;
    return Drawer(
      backgroundColor: Colors.black54,
      child: DefaultTabController(
        length: length,
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
    return TabBarView(
      children: List.generate(resources.length, (i) {
        final items = resources[i];
        return GridView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 40,
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            return _buildAnimeResourcesItem(item);
          },
        );
      }),
    );
  }

  // 构建资源分类tabView子项
  Widget _buildAnimeResourcesItem(ResourceItemModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
      onTap: () => onResourceSelect?.call(item),
    );
  }
}
