import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/page/home/filter.dart';
import 'package:jtech_anime/page/home/time_table.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/refresh/refresh_view.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 首页
* @author wuxubaiyang
* @Time 2023/7/6 10:03
*/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

/*
* 首页-状态
* @author wuxubaiyang
* @Time 2023/7/6 10:03
*/
class _HomePageState extends LogicState<HomePage, _HomeLogic> {
  @override
  _HomeLogic initLogic() => _HomeLogic();

  @override
  void initState() {
    super.initState();
    // 初始化加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化加载首页数据
      logic.loadAnimeList(context, false);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SizedBox();
    return Scaffold(
      body: AnimeFilterConfigMenu(
        complete: () => logic.loadAnimeList(context, false),
        filterConfig: logic.filterConfig,
        filterSelect: logic.filterSelect,
        body: NestedScrollView(
          controller: logic.scrollController,
          headerSliverBuilder: (_, __) {
            return [_buildAppBar(context)];
          },
          body: _buildAnimeList(context),
        ),
      ),
    );
  }

  // 构建页面头部
  Widget _buildAppBar(BuildContext context) {
    return ValueListenableBuilder2<Map<String, FilterSelect>, bool>(
      first: logic.filterConfig,
      second: logic.showAppbar,
      builder: (_, selectMap, showAppbar, __) {
        return SliverAppBar(
          title: _buildSearchButton(showAppbar),
          expandedHeight: _HomeLogic.expandedHeight,
          actions: [
            if (showAppbar) ..._actions,
          ],
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: EdgeInsets.only(
                bottom: selectMap.isNotEmpty ? kToolbarHeight : 0.0,
              ),
              child: AnimeTimeTable(
                onTap: (item) => logic.goDetail(AnimeModel.from({
                  'name': item.name,
                  'url': item.url,
                  'status': item.status,
                })),
              ),
            ),
          ),
          bottom: selectMap.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Container(
                    color: !showAppbar ? Colors.white : null,
                    child: _buildFilterChips(selectMap),
                  ),
                )
              : null,
        );
      },
    );
  }

  // 构建搜索按钮
  Widget _buildSearchButton(bool showAppbar) {
    if (!showAppbar) return const SizedBox();
    const color = Colors.black38;
    const textStyle = TextStyle(color: color, fontSize: 16);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ElevatedButton(
        child: const Row(
          children: [
            Icon(FontAwesomeIcons.magnifyingGlass, color: color, size: 18),
            SizedBox(width: 8),
            Text('嗖嗖嗖~', style: textStyle),
          ],
        ),
        onPressed: () => router.pushNamed(RoutePath.search),
      ),
    );
  }

  // 标题栏动作按钮集合
  List<Widget> get _actions => [
        IconButton(
          icon: const Icon(FontAwesomeIcons.heart),
          onPressed: () => router.pushNamed(RoutePath.collect),
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.clockRotateLeft),
          onPressed: () => router.pushNamed(RoutePath.record),
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.download),
          onPressed: () => router.pushNamed(RoutePath.download),
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.handPointDown),
          onPressed: () => logic.expandedTimeTable(),
        ),
      ];

  // 构建番剧过滤配置组件
  Widget _buildFilterChips(Map<String, FilterSelect> selectMap) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          children: List.generate(selectMap.length, (i) {
            final item = selectMap.values.elementAt(i);
            final text = '${item.parentName} · ${item.name}';
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RawChip(label: Text(text)),
            );
          }),
        ),
      ),
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList(BuildContext context) {
    return CustomRefreshView(
      enableRefresh: true,
      enableLoadMore: true,
      onRefresh: (loadMore) => logic.loadAnimeList(context, loadMore),
      child: ValueListenableBuilder<List<AnimeModel>>(
        valueListenable: logic.animeList,
        builder: (_, animeList, __) {
          return Stack(
            children: [
              if (animeList.isEmpty)
                ValueListenableBuilder<bool>(
                  valueListenable: logic.loading,
                  builder: (_, isLoading, __) {
                    return Center(
                      child: StatusBox(
                        animSize: 34,
                        status: isLoading
                            ? StatusBoxStatus.loading
                            : StatusBoxStatus.empty,
                        title: Text(isLoading ? '正在加载中~' : '下拉试试看~'),
                      ),
                    );
                  },
                ),
              GridView.builder(
                itemCount: animeList.length,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 190,
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final item = animeList[i];
                  return _buildAnimeListItem(item);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // 构建番剧列表子项
  Widget _buildAnimeListItem(AnimeModel item) {
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
      onTap: () => logic.goDetail(item),
    );
  }
}

/*
* 首页-逻辑
* @author wuxubaiyang
* @Time 2023/7/6 10:03
*/
class _HomeLogic extends BaseLogic {
  // 折叠高度
  static const double expandedHeight = 300.0;

  // 标题栏展示状态¶
  final showAppbar = ValueChangeNotifier<bool>(true);

  // 滚动控制器
  final scrollController = ScrollController();

  // 番剧列表
  final animeList = ListValueChangeNotifier<AnimeModel>.empty();

  // 记录过滤条件
  final filterConfig = MapValueChangeNotifier<String, FilterSelect>.empty();

  @override
  void init() {
    super.init();
    // 获取过滤条件
    db.getFilterSelectList(parserHandle.currentSource).then((v) {
      final result = v.asMap().map<String, FilterSelect>((_, v) {
        return MapEntry(_genFilterKey(v), v);
      });
      filterConfig.setValue(result);
      scrollController.jumpTo(_scrollOffset + 1);
    });
    // 监听容器滚动
    scrollController.addListener(() {
      // 判断是否需要展示标题栏
      showAppbar.setValue(scrollController.offset > _scrollOffset);
    });
  }

  // 获取滚动偏移量
  double get _scrollOffset =>
      expandedHeight -
      (filterConfig.isEmpty ? kToolbarHeight : kToolbarHeight * 2);

  // 展开番剧时间表
  void expandedTimeTable() => scrollController.animateTo(0,
      duration: const Duration(milliseconds: 400), curve: Curves.ease);

  // 加载番剧列表
  Future<void> loadAnimeList(BuildContext context, bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final filters = await db.getFilterSelectList(parserHandle.currentSource);
      final params = filters.asMap().map((_, v) => MapEntry(v.key, v.value));
      final result = await (loadMore
          ? parserHandle.loadAnimeListNextPage(params: params)
          : parserHandle.loadAnimeList(params: params));
      loadMore ? animeList.addValues(result) : animeList.setValue(result);

      // var i = 0;
      // for (var e in result) {
      //   db.updateCollect(Collect()
      //     ..url = e.url
      //     ..name = e.name
      //     ..cover = e.cover
      //     ..order = i++
      //     ..source = AnimeSource.yhdmz.name);
      // }
    } catch (e) {
      SnackTool.showMessage(context, message: '番剧加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 选择过滤条件
  Future<void> filterSelect(
      bool selected, FilterSelect item, int maxSelected) async {
    if (selected) {
      final result = await db.addFilterSelect(item, maxSelected);
      if (result != null) {
        final temp = filterConfig.value;
        if (maxSelected == 1) {
          temp.removeWhere((_, v) => v.key == item.key);
        }
        filterConfig.setValue({
          ...temp,
          _genFilterKey(result): result,
        });
      }
    } else {
      final result = await db.removeFilterSelect(item.id);
      if (result) filterConfig.removeValue(_genFilterKey(item));
    }
  }

  // 生成过滤条件唯一key
  String _genFilterKey(FilterSelect item) => '${item.key}${item.value}';

  // 跳转到详情页
  Future<void>? goDetail(AnimeModel item) {
    return router.pushNamed(
      RoutePath.animeDetail,
      arguments: {'animeDetail': item},
    );
  }
}
