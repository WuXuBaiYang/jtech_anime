import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:text_scroll/text_scroll.dart';

/*
* 切换视频弹窗
* @author wuxubaiyang
* @Time 2023/7/13 9:44
*/
class ChangeVideoSheet extends StatefulWidget {
  // 资源集合
  final List<List<ResourceItemModel>> resources;

  // 已选资源
  final ResourceItemModel? selectItem;

  const ChangeVideoSheet({
    super.key,
    required this.resources,
    this.selectItem,
  });

  static Future<ResourceItemModel?> show(
    BuildContext context, {
    required List<List<ResourceItemModel>> resources,
    ResourceItemModel? selectItem,
  }) {
    return showModalBottomSheet<ResourceItemModel>(
      elevation: 0,
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (_) => ChangeVideoSheet(
        selectItem: selectItem,
        resources: resources,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ChangeVideoSheetState();
}

/*
* 切换视频弹窗-状态
* @author wuxubaiyang
* @Time 2023/7/13 9:45
*/
class _ChangeVideoSheetState extends State<ChangeVideoSheet> {
  // 二维数组定位下标
  int resIndex = -1, index = -1;

  // 判断是否存在定位信息
  bool get hasPosition => resIndex != -1 && index != -1;

  // 列表滚动控制
  ScrollController? gridController;

  // 列表代理
  final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    mainAxisExtent: 50,
    crossAxisCount: 3,
  );

  @override
  void initState() {
    super.initState();
    // 计算初始化定位的位置
    if (widget.selectItem != null) {
      resIndex = widget.resources.indexWhere((e) {
        index = e.indexWhere((e) => e.url == widget.selectItem?.url);
        return index != -1;
      });
      if (hasPosition) {
        final count = gridDelegate.crossAxisCount;
        final extent = gridDelegate.mainAxisExtent ?? 0;
        final lines = (index - index % count) / count;
        gridController = ScrollController(
          initialScrollOffset: lines * (extent + 2),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      width: Tool.getScreenWidth(context) * 0.45,
      child: DefaultTabController(
        length: widget.resources.length,
        initialIndex: resIndex != -1 ? resIndex : 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabBar(),
            const Divider(color: Colors.white, thickness: 0.2, height: 1),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
    );
  }

  // 构建tabBar
  Widget _buildTabBar() {
    return TabBar(
      isScrollable: true,
      dividerColor: Colors.transparent,
      unselectedLabelColor: Colors.white,
      tabs: List.generate(
        widget.resources.length,
        (i) => Tab(text: '资源${i + 1}'),
      ),
    );
  }

  // 构建tabBarView
  Widget _buildTabBarView() {
    return TabBarView(
      children: List.generate(widget.resources.length, (i) {
        final items = widget.resources[i];
        final hasSelected = resIndex == i;
        return GridView.builder(
          itemCount: items.length,
          gridDelegate: gridDelegate,
          padding: const EdgeInsets.all(8),
          controller: hasSelected ? gridController : null,
          itemBuilder: (_, i) {
            final item = items[i];
            final playing = hasSelected && i == index;
            return _buildTabBarViewGridItem(item, playing);
          },
        );
      }),
    );
  }

  // 构建番剧资源子项
  Widget _buildTabBarViewGridItem(ResourceItemModel item, bool playing) {
    const textStyle = TextStyle(color: Colors.white, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: DefaultTextStyle(
          maxLines: 1,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white24,
                )),
            child: playing
                ? TextScroll(
                    '正在播放：${item.name}        ',
                    pauseBetween: const Duration(milliseconds: 0),
                    style: textStyle.copyWith(color: kPrimaryColor),
                    velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                  )
                : Text(item.name),
          ),
        ),
        onTap: () => router.pop(item),
      ),
    );
  }
}
