import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/search_record.dart';
import 'package:jtech_anime/page/search/search.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/refresh/controller.dart';
import 'package:jtech_anime/widget/refresh/refresh_view.dart';
import 'package:jtech_anime/widget/status_box.dart';

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
      body: Stack(
        children: [
          _buildSearchList(),
          _buildAppBar(context),
        ],
      ),
    );
  }

  // 构建标题栏
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14)
          .copyWith(top: MediaQuery.of(context).padding.top, right: 8),
      child: Row(
        children: [
          Expanded(
            child: SearchBarView(
              inSearching: logic.loading,
              searchRecordList: logic.searchRecordList,
              search: (keyword) => logic.startSearch(keyword),
              recordDelete: (item) => logic.deleteSearchRecord(item),
            ),
          ),
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
                  FontAwesomeIcons.personWalking,
                  FontAwesomeIcons.personRunning,
                  FontAwesomeIcons.personSnowboarding
                ][columnCount - 1]),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建搜索列表
  Widget _buildSearchList() {
    final multiPadding = const EdgeInsets.symmetric(horizontal: 14)
        .copyWith(top: kToolbarHeight + MediaQuery.of(context).padding.top + 8);
    return ValueListenableBuilder2<List<AnimeModel>, int>(
        first: logic.searchList,
        second: logic.columnCount,
        builder: (_, searchList, columnCount, __) {
          final isMultiLine = columnCount > 1;
          final isThird = columnCount == 3;
          return CustomRefreshView(
            enableRefresh: true,
            enableLoadMore: true,
            controller: logic.controller,
            onRefresh: (loadMore) => logic.search(loadMore),
            child: Stack(
              children: [
                if (searchList.isEmpty) _buildEmptyResults(),
                GridView.builder(
                  itemCount: searchList.length,
                  padding: isMultiLine
                      ? multiPadding
                      : multiPadding.copyWith(left: 0, right: 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisSpacing: isMultiLine ? 14 : 0,
                    crossAxisSpacing: isMultiLine ? 14 : 0,
                    mainAxisExtent: isMultiLine ? (isThird ? 160 : 240) : 120,
                  ),
                  itemBuilder: (_, i) {
                    final item = searchList[i];
                    if (!isMultiLine) return _buildSearchListItem(item);
                    return _buildSearchListItemMulti(item);
                  },
                ),
              ],
            ),
          );
        });
  }

  // 构建搜索列表子项
  Widget _buildSearchListItem(AnimeModel item) {
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
      onTap: () => logic.goDetail(item),
    );
  }

  // 构建搜索列表子项-多行模式
  Widget _buildSearchListItemMulti(AnimeModel item) {
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

  // 构建空内容状态
  Widget _buildEmptyResults() {
    return const Center(
      child: StatusBox(
        status: StatusBoxStatus.empty,
        title: Text('搜搜看~'),
      ),
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
      final result = await (loadMore
          ? parserHandle.searchAnimeListNextPage(keyword)
          : parserHandle.searchAnimeList(keyword));
      loadMore ? searchList.addValues(result) : searchList.setValue(result);
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
