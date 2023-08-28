import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/anime_parser/funtions.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/page/home/filter.dart';
import 'package:jtech_anime/widget/anime_list.dart';
import 'package:jtech_anime/widget/refresh/refresh_view.dart';

// 过滤条件变化
typedef HomeLatestAnimeFilterChange = void Function(List<FilterSelect> items);

/*
* 首页最新番剧列表
* @author wuxubaiyang
* @Time 2023/8/28 16:26
*/
class HomeLatestAnimeList extends StatefulWidget {
  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 异步加载回调
  final AsyncRefreshCallback onRefresh;

  // 番剧列表
  final ListValueChangeNotifier<AnimeModel> animeList;

  // 过滤条件
  final MapValueChangeNotifier<String, FilterSelect> filterSelect;

  // 过滤条件变化回调
  final HomeLatestAnimeFilterChange? onFilterChange;

  const HomeLatestAnimeList({
    super.key,
    this.itemTap,
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
class _HomeLatestAnimeListState extends State<HomeLatestAnimeList> {
  @override
  Widget build(BuildContext context) {
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
        );
      },
    );
  }

  // 构建番剧过滤配置组件
  Widget? _buildFilterChips() {
    if (!animeParser.isSupport(AnimeParserFunction.filter)) return null;
    return ValueListenableBuilder<Map<String, FilterSelect>>(
      valueListenable: widget.filterSelect,
      builder: (_, filterMap, __) {
        final tempFilter = filterMap.isNotEmpty
            ? filterMap
            : {
                'default': FilterSelect()
                  ..parentName = '默认'
                  ..name = '全部'
              };
        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: List.generate(tempFilter.length, (i) {
                    final item = tempFilter.values.elementAt(i);
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
              icon: const Icon(FontAwesomeIcons.filter),
              onPressed: () {
                HomeLatestAnimeFilterSheet.show(
                  context,
                  selectMap: filterMap,
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
}
