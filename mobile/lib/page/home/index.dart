import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/anime_parser/funtions.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/page/home/list.dart';
import 'package:jtech_anime/page/home/source.dart';
import 'package:jtech_anime/page/home/timetable.dart';
import 'package:jtech_anime/tool/debounce.dart';
import 'package:jtech_anime/tool/loading.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/version.dart';
import 'package:jtech_anime/widget/source/logo.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/refresh/controller.dart';
import 'package:jtech_anime/widget/status_box.dart';
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
  // 是否允许退出
  final appQuite = ValueChangeNotifier<bool>(false);

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
    // 监听解析源变化
    event.on<SourceChangeEvent>().listen((event) {
      // 如果解析源为空则弹出不可取消的强制选择弹窗
      if (event.source == null) {
        AnimeSourceChangeDialog.show(context, dismissible: false);
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: DefaultTabController(
        length: 2,
        child: SourceStreamView(builder: (_, snap) {
          return Scaffold(
            appBar: AppBar(
              actions: _appBarActions,
              bottom: _buildAppBarBottom(),
              title: const Text(Common.appName),
              notificationPredicate: (notification) {
                return notification.depth == 1;
              },
            ),
            body: _buildContent(),
          );
        }),
      ),
      onWillPop: () async {
        if (appQuite.value) return true;
        appQuite.setValue(true);
        SnackTool.showMessage(message: '再次点击退出');
        Debounce.c(() => appQuite.setValue(false), 'appQuite');
        return false;
      },
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
        SourceStreamView(
          builder: (c, snap) {
            final event = snap.data;
            if (event?.source == null) return const SizedBox();
            return GestureDetector(
              child: AnimeSourceLogo(source: event!.source!),
              onTap: () => router.pushNamed(RoutePath.animeSource),
              onLongPress: () {
                HapticFeedback.vibrate();
                AnimeSourceChangeDialog.show(c);
              },
            );
          },
        ),
        const SizedBox(width: 14),
      ];

  // 构建首页内容体
  Widget _buildContent() {
    return TabBarView(
      physics: !animeParser.isSupport(AnimeParserFunction.timeTable)
          ? const NeverScrollableScrollPhysics()
          : null,
      children: [_buildAnimeList(), _buildAnimeTimeTable()],
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList() {
    return HomeLatestAnimeList(
      itemTap: logic.goDetail,
      animeList: logic.animeList,
      controller: logic.controller,
      onRefresh: logic.loadAnimeList,
      filterSelect: logic.filterSelect,
      onFilterChange: (filters) => Loading.show(
        loadFuture: logic.updateFilterSelect(filters),
      ),
    );
  }

  // 构建番剧时间表
  Widget _buildAnimeTimeTable() {
    return StatusBoxCacheFuture<TimeTableModel?>(
      controller: logic.timeTableController,
      future: animeParser.getTimeTable,
      builder: (timeTable) {
        if (timeTable == null) return const SizedBox();
        return HomeAnimeTimeTable(
          itemTap: logic.goDetail,
          timeTable: timeTable,
        );
      },
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

  // 记录过滤条件
  final filterSelect = ListValueChangeNotifier<FilterSelect>.empty();

  // 刷新控制器
  final controller = CustomRefreshController();

  // 番剧时间表控制器
  final timeTableController = CacheFutureBuilderController<TimeTableModel?>();

  // 维护分页页码
  int _pageIndex = 1;

  // 维护分页数据量
  final _pageSize = 25;

  @override
  void init() {
    super.init();
    // 获取过滤条件
    _loadFilterSelect();
    // 监听解析源切换
    event.on<SourceChangeEvent>().listen((_) async {
      animeList.clear();
      controller.finish();
      _loadFilterSelect();
      filterSelect.clear();
      await Future.delayed(const Duration(milliseconds: 100));
      timeTableController.refreshValue();
      controller.startRefresh();
    });
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
