import 'package:flutter/material.dart';
import 'package:jtech_anime_base/model/anime.dart';
import 'package:jtech_anime_base/widget/image.dart';
import 'package:jtech_anime_base/widget/refresh/refresh_view.dart';
import 'package:jtech_anime_base/widget/status_box.dart';
import 'anime_list.dart';

/*
* 番剧列表
* @author wuxubaiyang
* @Time 2023/8/28 16:13
*/
class DesktopAnimeListView extends BaseAnimeListView {
  const DesktopAnimeListView({
    super.key,
    required super.animeList,
    required super.onRefresh,
    super.header,
    super.itemTap,
    super.padding,
    super.emptyHint,
    super.itemSpacing,
    super.columnCount,
    super.enableRefresh,
    super.maxItemExtent,
    super.enableLoadMore,
    super.initialRefresh,
    super.refreshController,
  });

  @override
  State<StatefulWidget> createState() => _DesktopAnimeListViewState();
}

/*
* 番剧列表-状态
* @author wuxubaiyang
* @Time 2023/8/28 16:14
*/
class _DesktopAnimeListViewState extends State<DesktopAnimeListView> {
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
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
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
      ),
    );
  }
}
