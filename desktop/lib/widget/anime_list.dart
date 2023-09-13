import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

// 番剧点击事件
typedef AnimeListItemTap = void Function(AnimeModel item);

/*
* 番剧列表
* @author wuxubaiyang
* @Time 2023/8/28 16:13
*/
class AnimeListView extends StatefulWidget {
  // 刷新控制器
  final CustomRefreshController? refreshController;

  // 是否启用下拉刷新
  final bool enableRefresh;

  // 是否启用上拉加载
  final bool enableLoadMore;

  // 是否初始化加载
  final bool initialRefresh;

  // 异步加载回调
  final AsyncRefreshCallback onRefresh;

  // 番剧列表
  final List<AnimeModel> animeList;

  // 空内容提示
  final Widget? emptyHint;

  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 添加头部组件
  final Widget? header;

  // 内间距
  final EdgeInsetsGeometry? padding;

  // 子项最大尺寸
  final Size? maxItemExtent;

  // 子项间距
  final double itemSpacing;

  const AnimeListView({
    super.key,
    this.header,
    this.itemTap,
    this.padding,
    this.emptyHint,
    this.maxItemExtent,
    this.itemSpacing = 8,
    this.refreshController,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.initialRefresh = false,
    required this.animeList,
    required this.onRefresh,
  });

  @override
  State<StatefulWidget> createState() => _AnimeListViewState();
}

/*
* 番剧列表-状态
* @author wuxubaiyang
* @Time 2023/8/28 16:14
*/
class _AnimeListViewState extends State<AnimeListView> {
  @override
  Widget build(BuildContext context) {
    return CustomRefreshView(
      onRefresh: widget.onRefresh,
      enableRefresh: widget.enableRefresh,
      controller: widget.refreshController,
      enableLoadMore: widget.enableLoadMore,
      initialRefresh: widget.initialRefresh,
      header: CustomRefreshViewHeader.classic,
      child: _buildAnimeList(),
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList() {
    final itemExtent = widget.maxItemExtent ?? const Size(180, 240);
    return Stack(
      children: [
        if (widget.animeList.isEmpty) _buildEmptyResults(),
        CustomScrollView(
          slivers: [
            if (widget.header != null)
              SliverList(
                delegate: SliverChildListDelegate(
                  [widget.header!],
                ),
              ),
            SliverPadding(
              padding: widget.padding ?? const EdgeInsets.all(8),
              sliver: SliverGrid.builder(
                itemCount: widget.animeList.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: widget.itemSpacing,
                  crossAxisSpacing: widget.itemSpacing,
                  mainAxisExtent: itemExtent.height,
                  maxCrossAxisExtent: itemExtent.width,
                ),
                itemBuilder: (_, i) {
                  final item = widget.animeList[i];
                  return _buildAnimeGridItem(item);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建列表子项
  Widget _buildAnimeGridItem(AnimeModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      child: ImageView.net(item.cover, fit: BoxFit.cover),
                    ),
                    if (item.status.isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        color: Colors.black.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Text(
                          item.status,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      onTap: () => widget.itemTap?.call(item),
    );
  }

  // 构建空内容状态
  Widget _buildEmptyResults() {
    return Center(
      child: StatusBox(
        status: StatusBoxStatus.empty,
        title: widget.emptyHint,
        animSize: 100,
      ),
    );
  }
}
