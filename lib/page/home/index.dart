import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter_select.dart';
import 'package:jtech_anime/page/home/filter.dart';
import 'package:jtech_anime/page/home/time_table.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
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
    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 初始化加载
      logic.loadAnimeList(context, false);
      // 监听容器滚动
      logic.scrollController.addListener(() {
        // 判断是否已滚动到底部
        if (logic.scrollController.offset >=
            logic.scrollController.position.maxScrollExtent) {
          logic.loadAnimeList(context, true);
        }
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => logic.loadAnimeList(context, false),
        child: ValueListenableBuilder<List<AnimeModel>>(
          valueListenable: logic.animeList,
          builder: (_, animeList, __) {
            return CustomScrollView(
              controller: logic.scrollController,
              slivers: [
                _buildAppBar(context),
                _buildAnimeList(context, animeList),
              ],
            );
          },
        ),
      ),
      floatingActionButton: AnimeFilterConfigFAB(
        complete: () => logic.loadAnimeList(context, false),
        filterConfig: logic.filterConfig,
      ),
    );
  }

  // 构建页面头部
  Widget _buildAppBar(BuildContext context) {
    final edgeInsets = MediaQuery.paddingOf(context);
    return ValueListenableBuilder2<Map<String, FilterSelect>, bool>(
      first: logic.filterConfig,
      second: logic.showAppBar,
      builder: (_, selectMap, showAppBar, __) {
        final padding = EdgeInsets.only(
          bottom: selectMap.isNotEmpty ? kToolbarHeight : 0.0,
          top: edgeInsets.top,
        );
        return SliverAppBar(
          title: _buildSearchButton(showAppBar),
          expandedHeight: _HomeLogic.expandedHeight,
          actions: [
            if (showAppBar) ..._actions,
          ],
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: padding,
              child: AnimeTimeTable(
                onTap: (item) => router.pushNamed(
                  RoutePath.animeDetail,
                  arguments: {'url': item.url},
                ),
              ),
            ),
          ),
          bottom: selectMap.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildFilterChips(selectMap),
                  ))
              : null,
        );
      },
    );
  }

  // 构建搜索按钮
  Widget _buildSearchButton(bool showAppBar) {
    if (!showAppBar) return const SizedBox();
    const color = Colors.black38;
    const textStyle = TextStyle(color: color, fontSize: 16);
    return ElevatedButton(
      child: const Row(
        children: [
          Icon(FontAwesomeIcons.magnifyingGlass, color: color, size: 18),
          SizedBox(width: 8),
          Text('嗖嗖嗖~', style: textStyle),
        ],
      ),
      onPressed: () => router.pushNamed(RoutePath.search),
    );
  }

  // 标题栏动作按钮集合
  List<Widget> get _actions => [
        IconButton(
          icon: const Icon(FontAwesomeIcons.handPointDown),
          onPressed: () => logic.expandedTimeTable(),
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.download),
          onPressed: () {
            SnackTool.showMessage(context, message: '还在施工中~');
          },
        ),
      ];

  // 构建番剧过滤配置组件
  Widget _buildFilterChips(Map<String, FilterSelect> selectMap) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList(BuildContext context, List<AnimeModel> animeList) {
    if (animeList.isEmpty) {
      return SliverList.list(children: [
        SizedBox(
          height: Tool.getScreenHeight(context) + 100,
          child: const Padding(
            padding: EdgeInsets.only(top: 100),
            child: StatusBox(
              status: StatusBoxStatus.empty,
              title: Text('试试下拉~'),
            ),
          ),
        ),
      ]);
    }
    return SliverGrid.builder(
      itemCount: animeList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.65,
        crossAxisCount: 3,
      ),
      itemBuilder: (_, i) => _buildAnimeListItem(animeList[i]),
    );
  }

  // 构建番剧列表子项
  Widget _buildAnimeListItem(AnimeModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Text(
                        item.status,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
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
      onTap: () => router.pushNamed(
        RoutePath.animeDetail,
        arguments: {'url': item.url},
      ),
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
  static const double expandedHeight = 350.0;

  // 标题栏展示状态
  final showAppBar = ValueChangeNotifier<bool>(true);

  // 滚动控制器
  final scrollController = ScrollController(
      initialScrollOffset: expandedHeight - kToolbarHeight + 1);

  // 番剧列表
  final animeList = ListValueChangeNotifier<AnimeModel>.empty();

  // 记录过滤条件
  final filterConfig = MapValueChangeNotifier<String, FilterSelect>.empty();

  @override
  void init() {
    super.init();
    // 加载过滤条件
    db.getFilterSelectList(parserHandle.currentSource).then(
          (result) => filterConfig.setValue(result.asMap().map(
                (_, v) => MapEntry(v.key + v.value, v),
              )),
        );
    // 监听容器滚动
    scrollController.addListener(() {
      // 判断是否需要展示标题栏
      showAppBar.setValue(
        scrollController.offset > expandedHeight - kToolbarHeight,
      );
    });
  }

  // 展开番剧时间表
  void expandedTimeTable() => scrollController.animateTo(0,
      duration: const Duration(milliseconds: 400), curve: Curves.ease);

  // 记录当前加载状态，避免重复加载
  bool _loading = false;

  // 加载番剧列表
  Future<void> loadAnimeList(BuildContext context, bool loadMore) async {
    if (_loading) return;
    return Tool.showLoading<void>(context, loadFuture: Future(() async {
      _loading = true;
      try {
        final params =
            filterConfig.value.map((_, v) => MapEntry(v.key, v.value));
        final result = await (loadMore
            ? parserHandle.loadAnimeListNextPage(params: params)
            : parserHandle.loadAnimeList(params: params));
        loadMore ? animeList.addValues(result) : animeList.setValue(result);
      } catch (e) {
        SnackTool.showMessage(context, message: '番剧加载失败，请重试~');
      } finally {
        _loading = false;
      }
    }));
  }
}
