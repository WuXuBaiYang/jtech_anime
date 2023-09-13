import 'package:desktop/common/route.dart';
import 'package:desktop/widget/anime_list.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'filter.dart';
import 'search.dart';

/*
* 首页番剧列表（过滤/搜索）
* @author wuxubaiyang
* @Time 2023/9/7 16:13
*/
class HomeAnimePage extends StatefulWidget {
  const HomeAnimePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeAnimePageState();
}

/*
* 首页番剧列表（过滤/搜索）-状态
* @author wuxubaiyang
* @Time 2023/9/7 16:13
*/
class _HomeAnimePageState extends LogicState<HomeAnimePage, _HomeAnimeLogic> {
  @override
  _HomeAnimeLogic initLogic() => _HomeAnimeLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: _buildAnimeList(),
    );
  }

  // 构建番剧列表头部
  Widget _buildAnimeListHeader() {
    final supportSearch = animeParser.isSupport(AnimeParserFunction.search);
    final supportFilter = animeParser.isSupport(AnimeParserFunction.filter);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          if (supportSearch) _buildSearchBar(),
          const SizedBox(width: 14),
          if (supportFilter) Expanded(child: _buildFilterChips(context)),
          const SizedBox(width: 8),
          if (supportFilter) _buildFilterButton(),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // 构建搜索框
  Widget _buildSearchBar() {
    return SizedBox(
      width: 180,
      child: SearchBarView(
        searchRecordList: logic.searchRecordList,
        search: (keyword) => logic.startSearch(keyword),
        recordDelete: (item) => logic.deleteSearchRecord(item),
      ),
    );
  }

  // 构建番剧过滤配置组件
  Widget _buildFilterChips(BuildContext context) {
    return ValueListenableBuilder<List<FilterSelect>>(
      valueListenable: logic.filterSelect,
      builder: (_, filters, __) {
        final tempFilters = filters.isNotEmpty
            ? filters
            : [
                FilterSelect()
                  ..parentName = '默认'
                  ..name = '全部',
              ];
        return SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: List.generate(tempFilters.length, (i) {
              final item = tempFilters[i];
              final text = '${item.parentName} · ${item.name}';
              return RawChip(label: Text(text));
            })
                .expand((child) => [const SizedBox(width: 8), child])
                .skip(1)
                .toList(),
          ),
        );
      },
    );
  }

  // 构建过滤条件弹窗按钮
  Widget _buildFilterButton() {
    return IconButton(
      icon: const Icon(Icons.sort),
      onPressed: () => HomeAnimeFilterSheet.show(
        context,
        selectFilters: logic.filterSelect.value,
      ).then((v) {
        if (v == null) return;
        Loading.show(loadFuture: logic.updateFilterSelect(v));
      }),
    );
  }

  // 构建番剧列表
  Widget _buildAnimeList() {
    return ValueListenableBuilder<List<AnimeModel>>(
      valueListenable: logic.animeList,
      builder: (_, animeList, __) {
        return AnimeListView(
          animeList: animeList,
          initialRefresh: true,
          itemTap: logic.goDetail,
          onRefresh: logic.loadAnimeList,
          header: _buildAnimeListHeader(),
          refreshController: logic.controller,
        );
      },
    );
  }
}

/*
* 首页番剧列表（过滤/搜索）-逻辑
* @author wuxubaiyang
* @Time 2023/9/7 16:13
*/
class _HomeAnimeLogic extends BaseLogic {
  // 记录过滤条件
  final filterSelect = ListValueChangeNotifier<FilterSelect>.empty();

  // 番剧列表
  final animeList = ListValueChangeNotifier<AnimeModel>.empty();

  // 缓存搜索记录
  final searchRecordList = ListValueChangeNotifier<SearchRecord>.empty();

  // 刷新控制器
  final controller = CustomRefreshController();

  // 分页下标
  int _pageIndex = 1;

  // 缓存最后一次搜索关键字
  String? _lastKeyword;

  // 缓存当前请求token
  CancelToken? _cancelToken;

  @override
  void init() {
    super.init();
    // 获取过滤条件
    _loadFilterSelect();
    // 监听解析源切换
    event.on<SourceChangeEvent>().listen((_) async {
      animeList.clear();
      _loadFilterSelect();
      filterSelect.clear();
      if (_cancelToken != null) {
        _cancelToken?.cancel('解析源切换');
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      controller.startRefresh();
    });
    // 初始化搜索记录
    db.getSearchRecordList().then(searchRecordList.setValue);
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

  // 加载番剧列表
  Future<void> loadAnimeList(bool loadMore) {
    return _lastKeyword?.isNotEmpty == true
        ? searchAnimeList(loadMore)
        : loadFilterAnimeList(loadMore);
  }

  // 加载过滤条件番剧列表
  Future<void> loadFilterAnimeList(bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final pageIndex = loadMore ? _pageIndex + 1 : 1;
      _cancelToken = CancelToken();
      final result = await animeParser.loadHomeList(
        pageIndex: pageIndex,
        filterSelect: filterSelect.value.asMap().map(
              (_, v) => MapEntry(v.key, v.value),
            ),
        cancelToken: _cancelToken,
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
      _cancelToken = null;
    }
  }

  // 启动刷新
  void startSearch(String keyword) {
    _lastKeyword = keyword;
    controller.startRefresh();
  }

  // 执行搜索
  Future<void> searchAnimeList(bool loadMore, {String? keyword}) async {
    keyword ??= _lastKeyword;
    if (isLoading) return;
    if (keyword == null || keyword.isEmpty) return;
    try {
      loading.setValue(true);
      if (!loadMore) {
        // 缓存搜索记录
        final record = await db.addSearchRecord(keyword);
        if (record != null) {
          searchRecordList
            ..removeWhere((e) => e.id == record.id, notify: false)
            ..addValue(record);
        }
        // 记录搜索关键字
        _lastKeyword = keyword;
      }
      // 执行搜索请求
      _cancelToken = CancelToken();
      final pageIndex = loadMore ? _pageIndex + 1 : 1;
      final result = await animeParser.searchAnimeList(keyword,
          pageIndex: pageIndex,
          filterSelect: filterSelect.value.asMap().map(
                (_, v) => MapEntry(v.key, v.value),
              ),
          cancelToken: _cancelToken);
      loadMore ? animeList.addValues(result) : animeList.setValue(result);
      if (loadMore && result.isEmpty) {
        SnackTool.showMessage(message: '没有更多番剧了~');
      }
      _pageIndex = pageIndex;
    } catch (e) {
      SnackTool.showMessage(message: '搜索请求失败，请重试~');
    } finally {
      loading.setValue(false);
      _cancelToken = null;
    }
  }

  // 删除搜索记录
  Future<bool> deleteSearchRecord(SearchRecord item) async {
    var result = false;
    try {
      result = await db.removeSearchRecord(item.id);
      if (result) searchRecordList.removeValue(item);
    } catch (e) {
      SnackTool.showMessage(message: '搜索记录删除失败，请重试~');
    }
    return result;
  }

  // 跳转到详情
  Future<void>? goDetail(AnimeModel item) {
    return router.pushNamed(
      RoutePath.animeDetail,
      arguments: {'animeDetail': item},
    );
  }
}
