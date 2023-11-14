import 'package:flutter/material.dart';
import 'package:mobile/page/home/filter.dart';
import 'package:jtech_anime_base/base.dart';

// 过滤条件变化
typedef HomeLatestAnimeFilterChange = void Function(List<FilterSelect> items);

/*
* 首页最新番剧列表
* @author wuxubaiyang
* @Time 2023/8/28 16:26
*/
class HomeLatestAnimeList extends StatefulWidget {
  // 刷新控制器
  final CustomRefreshController? controller;

  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 异步加载回调
  final AsyncRefreshCallback onRefresh;

  // 番剧列表
  final ListValueChangeNotifier<AnimeModel> animeList;

  // 过滤条件
  final ListValueChangeNotifier<FilterSelect> filterSelect;

  // 过滤条件变化回调
  final HomeLatestAnimeFilterChange? onFilterChange;

  const HomeLatestAnimeList({
    super.key,
    this.itemTap,
    this.controller,
    this.onFilterChange,
    required this.animeList,
    required this.onRefresh,
    required this.filterSelect,
  });

  @override
  State<StatefulWidget> createState() => _HomeLatestAnimeListState();
}

/*
* 首页最新番剧列表-状态
* @author wuxubaiyang
* @Time 2023/8/28 16:26
*/
class _HomeLatestAnimeListState extends State<HomeLatestAnimeList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildAnimeList();
  }

  // 构建番剧列表
  Widget _buildAnimeList() {
    return ValueListenableBuilder<List<AnimeModel>>(
      valueListenable: widget.animeList,
      builder: (_, animeList, __) {
        return AnimeListView(
          enableRefresh: true,
          enableLoadMore: true,
          initialRefresh: true,
          animeList: animeList,
          itemTap: widget.itemTap,
          header: _buildFilterChips(),
          onRefresh: widget.onRefresh,
          emptyHint: const Text('下拉试试看~'),
          refreshController: widget.controller,
        );
      },
    );
  }

  // 构建番剧过滤配置组件
  Widget? _buildFilterChips() {
    if (!animeParser.isSupport(AnimeParserFunction.filter)) return null;
    return ValueListenableBuilder<List<FilterSelect>>(
      valueListenable: widget.filterSelect,
      builder: (_, filters, __) {
        final tempFilters = filters.isNotEmpty
            ? filters
            : [
                FilterSelect()
                  ..parentName = '默认'
                  ..name = '全部',
              ];
        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: List.generate(tempFilters.length, (i) {
                    final item = tempFilters[i];
                    final text = '${item.parentName} · ${item.name}';
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: RawChip(label: Text(text)),
                    );
                  }),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                HomeLatestAnimeFilterSheet.show(
                  context,
                  selectFilters: filters,
                ).then((v) {
                  if (v != null) widget.onFilterChange?.call(v);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
