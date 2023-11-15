import 'package:flutter/material.dart';
import 'package:jtech_anime_base/model/anime.dart';
import 'package:jtech_anime_base/widget/image.dart';
import 'package:jtech_anime_base/widget/refresh/refresh_view.dart';
import 'package:jtech_anime_base/widget/status_box.dart';
import 'anime_list.dart';

/*
* 番剧列表-移动端
* @author wuxubaiyang
* @Time 2023/8/28 16:13
*/
class MobileAnimeListView extends BaseAnimeListView {
  const MobileAnimeListView({
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
  State<StatefulWidget> createState() => _MobileAnimeListViewState();
}

/*
* 番剧列表-状态
* @author wuxubaiyang
* @Time 2023/8/28 16:14
*/
class _MobileAnimeListViewState extends State<MobileAnimeListView> {
  @override
  Widget build(BuildContext context) {
    return CustomRefreshView(
      onRefresh: widget.onRefresh,
      enableRefresh: widget.enableRefresh,
      controller: widget.refreshController,
      enableLoadMore: widget.enableLoadMore,
      initialRefresh: widget.initialRefresh,
      child: _buildAnimeList(),
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList() {
    final isMultiLine = widget.columnCount > 1;
    final isThird = widget.columnCount == 3;
    return Stack(
      fit: StackFit.expand,
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
              padding: widget.padding ??
                  (widget.columnCount > 1
                      ? const EdgeInsets.all(8)
                      : EdgeInsets.zero),
              sliver: SliverGrid.builder(
                itemCount: widget.animeList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.columnCount,
                  mainAxisSpacing: isMultiLine ? 4 : 0,
                  crossAxisSpacing: isMultiLine ? 4 : 0,
                  mainAxisExtent: isMultiLine ? (isThird ? 160 : 240) : 120,
                ),
                itemBuilder: (_, i) {
                  final item = widget.animeList[i];
                  if (!isMultiLine) return _buildAnimeListItem(item);
                  return _buildAnimeItemMulti(item);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建搜索列表子项
  Widget _buildAnimeListItem(AnimeModel item) {
    return InkWell(
      child: DefaultTextStyle(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: Colors.black38),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageView.net(item.cover,
                    width: 80, height: 120, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(item.name,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 8),
                    Text('${item.status.trim()}'
                        '${item.types.isNotEmpty ? ' · ${item.types.join('/')}' : ''}'),
                    const SizedBox(height: 4),
                    Text(item.intro.trim()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => widget.itemTap?.call(item),
    );
  }

  // 构建列表子项-多行模式
  Widget _buildAnimeItemMulti(AnimeModel item) {
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
