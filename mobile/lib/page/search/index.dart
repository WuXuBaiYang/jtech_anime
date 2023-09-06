import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/page/search/search.dart';
import 'package:jtech_anime/widget/anime_list.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 搜索页
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

/*
* 搜索页-状态
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class _SearchPageState extends LogicState<SearchPage, _SearchLogic> {
  // 搜索页列表列数缓存key
  static const String searchColumnsKey = 'search_columns';

  @override
  _SearchLogic initLogic() => _SearchLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        automaticallyImplyLeading: false,
        title: _buildSearchBar(),
      ),
      body: _buildSearchList(),
    );
  }

  // 构建搜索框
  Widget _buildSearchBar() {
    return SearchBarView(
      inSearching: logic.loading,
      searchRecordList: logic.searchRecordList,
      search: (keyword) => logic.startSearch(keyword),
      recordDelete: (item) => logic.deleteSearchRecord(item),
      actions: [
        ValueListenableBuilder(
          valueListenable: logic.columnCount,
          builder: (_, columnCount, __) {
            return IconButton(
              onPressed: () {
                int value = columnCount + 1;
                if (value > 3) value = 1;
                logic.columnCount.setValue(value);
              },
              icon: Icon([
                Icons.format_list_bulleted_rounded,
                Icons.drag_indicator_rounded,
                Icons.apps_rounded,
              ][columnCount - 1]),
            );
          },
        ),
      ],
    );
  }

  // 构建搜索列表
  Widget _buildSearchList() {
    return ValueListenableBuilder2<List<AnimeModel>, int>(
      first: logic.searchList,
      second: logic.columnCount,
      builder: (_, searchList, columnCount, __) {
        return AnimeListView(
          animeList: searchList,
          onRefresh: logic.search,
          itemTap: logic.goDetail,
          columnCount: columnCount,
          refreshController: logic.controller,
        );
      },
    );
  }
}

/*
* 搜索页-逻辑
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class _SearchLogic extends BaseLogic {
  // 搜索列表
  final searchList = ListValueChangeNotifier<AnimeModel>.empty();

  // 缓存搜索记录
  final searchRecordList = ListValueChangeNotifier<SearchRecord>.empty();

  // 记录搜索页列数
  late ValueChangeNotifier<int> columnCount =
      ValueChangeNotifier(cache.getInt(_SearchPageState.searchColumnsKey) ?? 1);

  // 刷新控制器
  final controller = CustomRefreshController();

  @override
  void init() {
    super.init();
    // 初始化搜索记录
    db.getSearchRecordList().then((v) {
      searchRecordList.setValue(v);
    });
    // 监听列数变化，并覆盖缓存记录
    columnCount.addListener(() => cache.setInt(
          _SearchPageState.searchColumnsKey,
          columnCount.value,
        ));
  }

  // 维护分页页码
  int _pageIndex = 1;

  // 维护分页数据量
  final _pageSize = 25;

  // 缓存最后一次搜索关键字
  String? _lastKeyword;

  // 启动刷新
  startSearch(String keyword) {
    _lastKeyword = keyword;
    controller.startRefresh();
  }

  // 执行搜索
  Future<void> search(bool loadMore, {String? keyword}) async {
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
      final pageIndex = loadMore ? _pageIndex + 1 : 1;
      final result = await animeParser.searchAnimeList(keyword,
          pageIndex: pageIndex, pageSize: _pageSize);
      loadMore ? searchList.addValues(result) : searchList.setValue(result);
      if (loadMore && result.isEmpty) {
        SnackTool.showMessage(message: '没有更多番剧了~');
      }
      _pageIndex = pageIndex;
    } catch (e) {
      SnackTool.showMessage(message: '搜索请求失败，请重试~');
    } finally {
      loading.setValue(false);
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
