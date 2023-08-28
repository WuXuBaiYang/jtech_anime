import 'package:flutter/material.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/refresh/controller.dart';
import 'package:jtech_anime/widget/refresh/refresh_view.dart';
import 'package:jtech_anime/widget/status_box.dart';

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

  // 列数
  final int columnCount;

  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 添加头部组件
  final Widget? header;

  const AnimeListView({
    super.key,
    this.header,
    this.itemTap,
    this.emptyHint,
    this.columnCount = 3,
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
      child: _buildAnimeList(),
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList() {
    final isMultiLine = widget.columnCount > 1;
    final isThird = widget.columnCount == 3;
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
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid.builder(
                itemCount: widget.animeList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.columnCount,
                  mainAxisSpacing: isMultiLine ? 14 : 0,
                  crossAxisSpacing: isMultiLine ? 14 : 0,
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 14),
                    Text('${item.status} · ${item.types.join('/')}'),
                    const SizedBox(height: 8),
                    Text(item.intro),
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
                  Container(
                    width: double.maxFinite,
                    color: Colors.black.withOpacity(0.6),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      item.status,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
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
