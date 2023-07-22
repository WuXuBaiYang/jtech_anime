import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';

/*
* 资源下载弹窗
* @author wuxubaiyang
* @Time 2023/7/22 11:19
*/
class DownloadSheet extends StatefulWidget {
  // 资源二维集合
  final List<List<ResourceItemModel>> resources;

  const DownloadSheet({super.key, required this.resources});

  static Future<void> show(BuildContext context,
      {required List<List<ResourceItemModel>> resources}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return DownloadSheet(resources: resources);
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _DownloadSheetState();
}

/*
* 资源下载弹窗-状态
* @author wuxubaiyang
* @Time 2023/7/22 11:23
*/
class _DownloadSheetState extends State<DownloadSheet> {
  @override
  Widget build(BuildContext context) {
    final length = widget.resources.length;
    return DefaultTabController(
      length: length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResourceTab(length),
          const Divider(color: Colors.white, thickness: 0.1, height: 1),
          Expanded(child: _buildResourceTabView(length)),
        ],
      ),
    );
  }

  // 构建资源分类tab
  Widget _buildResourceTab(int length) {
    return TabBar(
      isScrollable: true,
      indicatorColor: kPrimaryColor,
      dividerColor: Colors.transparent,
      tabs: List.generate(length, (i) {
        return Tab(text: '资源${i + 1}');
      }),
    );
  }

  // 构建资源分类tabView
  Widget _buildResourceTabView(int length) {
    return TabBarView(
      children: List.generate(length, (i) {
        final items = widget.resources[i];
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
        child: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54),
        ),
      ),
      onTap: () {},
    );
  }
}
