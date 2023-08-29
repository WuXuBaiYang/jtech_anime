import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/anime_parser/funtions.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/page/home/list.dart';
import 'package:jtech_anime/tool/loading.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/version.dart';
import 'package:jtech_anime/widget/stream_view.dart';
import 'package:jtech_anime/widget/tab.dart';

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
class _HomePageState extends LogicState<HomePage, _HomeLogic>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  _HomeLogic initLogic() => _HomeLogic();

  @override
  void initState() {
    super.initState();
    // 初始化加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查版本更新
      AppVersionTool.check(context);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SourceStreamView(builder: (c, snap) {
        return Scaffold(
          appBar: AppBar(
            actions: _appBarActions,
            title: const Text(Common.appName),
            bottom: _buildAppBarBottom(),
          ),
          body: _buildContent(),
        );
      }),
    );
  }

  // 构建标题栏底部
  PreferredSize? _buildAppBarBottom() {
    if (!animeParser.isSupport(AnimeParserFunction.timeTable)) return null;
    return const PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 14),
      child: CustomTabBar(
        tabs: [
          Tab(text: '最新番剧'),
          Tab(text: '新番时间表'),
        ],
      ),
    );
  }

  // 标题栏动作按钮集合
  List<Widget> get _appBarActions => [
        if (animeParser.isSupport(AnimeParserFunction.search))
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass),
            onPressed: () => router.pushNamed(RoutePath.search),
          ),
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
      ];

  // 构建首页内容体
  Widget _buildContent() {
    return TabBarView(
      physics: !animeParser.isSupport(AnimeParserFunction.timeTable)
          ? const NeverScrollableScrollPhysics()
          : null,
      children: [_buildAnimeList(), _buildAnimeList()],
    );
  }

  // 周/天换算表
  final _weekdayMap = <IconData, String>{
    FontAwesomeIcons.faceDizzy: '周一',
    FontAwesomeIcons.faceFrown: '周二',
    FontAwesomeIcons.faceFlushed: '周三',
    FontAwesomeIcons.faceGrimace: '周四',
    FontAwesomeIcons.faceGrinStars: '周五',
    FontAwesomeIcons.faceLaughWink: '周六',
    FontAwesomeIcons.faceSadTear: '周日',
  };

  // 构建时间轴tabBar
  // PreferredSizeWidget _buildTimetableTabBar() {
  //   return TabBar(
  //     isScrollable: true,
  //     controller: timetableTabController,
  //     tabs: List.generate(timetableTabController.length, (i) {
  //       final item = _weekdayMap.entries.elementAt(i);
  //       return Tab(
  //         child: Row(
  //           children: [
  //             Text(item.value),
  //             const SizedBox(width: 4),
  //             Icon(item.key, size: 14),
  //           ],
  //         ),
  //       );
  //     }),
  //   );
  // }

  // 构建时间轴tabView
  // Widget _buildTimetableTabView() {
  //   return ValueListenableBuilder<TimeTableModel?>(
  //     valueListenable: logic.timetableDataList,
  //     builder: (_, timeTable, __) {
  //       if (timeTable == null) return _buildEmpty();
  //       return TabBarView(
  //         controller: timetableTabController,
  //         children: List.generate(timetableTabController.length, (i) {
  //           final items = timeTable.getAnimeListByWeekday(i);
  //           return ListView.builder(
  //             primary: false,
  //             itemCount: items.length,
  //             padding: EdgeInsets.zero,
  //             itemBuilder: (_, i) {
  //               final item = items[i];
  //               final updateIcon = item.isUpdate
  //                   ? const Icon(FontAwesomeIcons.seedling,
  //                       color: Colors.green, size: 18)
  //                   : null;
  //               return ListTile(
  //                 dense: true,
  //                 trailing: updateIcon,
  //                 title: Text(item.name),
  //                 subtitle: Text(item.status),
  //                 onTap: () => logic.goDetail(AnimeModel.from({
  //                   'name': item.name,
  //                   'url': item.url,
  //                   'status': item.status,
  //                 })),
  //               );
  //             },
  //           );
  //         }),
  //       );
  //     },
  //   );
  // }

  // 构建番剧列表
  Widget _buildAnimeList() {
    return HomeLatestAnimeList(
      itemTap: logic.goDetail,
      animeList: logic.animeList,
      onRefresh: logic.loadAnimeList,
      filterSelect: logic.filterSelect,
      onFilterChange: (filters) => Loading.show(
        loadFuture: logic.updateFilterSelect(filters),
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
  // 番剧列表
  final animeList = ListValueChangeNotifier<AnimeModel>.empty();

  // 时间轴数据
  final timetableList = ValueChangeNotifier<TimeTableModel?>(null);

  // 记录过滤条件
  final filterSelect = ListValueChangeNotifier<FilterSelect>.empty();

  // 维护分页页码
  int _pageIndex = 1;

  // 维护分页数据量
  final _pageSize = 25;

  @override
  void init() {
    super.init();
    // 获取过滤条件
    _loadFilterSelect();
    // 加载时间轴数据
    _loadTimetableList();
  }

  // 加载番剧列表
  Future<void> loadAnimeList(bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final source = animeParser.currentSource;
      if (source == null) throw Exception('数据源不存在');
      final filters = await db.getFilterSelectList(source);
      final filterSelect =
          filters.asMap().map((_, v) => MapEntry(v.key, v.value));
      final pageIndex = loadMore ? _pageIndex + 1 : 1;
      final result = await animeParser.loadHomeList(
        pageIndex: pageIndex,
        pageSize: _pageSize,
        filterSelect: filterSelect,
      );
      loadMore ? animeList.addValues(result) : animeList.setValue(result);
      if (loadMore && result.isEmpty) {
        SnackTool.showMessage(message: '没有更多番剧了~');
      }
      _pageIndex = pageIndex;
    } catch (e) {
      SnackTool.showMessage(message: '番剧加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 加载时间轴数据
  Future<void> _loadTimetableList() async {
    final result = await animeParser.getTimeTable();
    timetableList.setValue(result);
  }

  // 加载过滤条件配置
  Future<void> _loadFilterSelect() async {
    final source = animeParser.currentSource;
    if (source == null) return;
    final result = await db.getFilterSelectList(source);
    filterSelect.setValue(result);
  }

  // 更新过滤条件
  Future<void> updateFilterSelect(List<FilterSelect> filters) async {
    final source = animeParser.currentSource;
    if (source == null) return;
    final result = await db.replaceFilterSelectList(source, filters);
    filterSelect.setValue(result);
    return loadAnimeList(false);
  }

  // 跳转到详情页
  Future<void>? goDetail(AnimeModel item) {
    return router.pushNamed(
      RoutePath.animeDetail,
      arguments: {'animeDetail': item},
    );
  }
}
