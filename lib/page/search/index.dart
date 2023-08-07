import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/search_record.dart';
import 'package:jtech_anime/page/search/search.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
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
  @override
  _SearchLogic initLogic() => _SearchLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildSearchList(),
          _buildSearchBar(context),
        ],
      ),
    );
  }

  // 构建搜索条
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14)
          .copyWith(top: MediaQuery.of(context).padding.top),
      child: SearchBarView(
        inSearching: logic.loading,
        searchRecordList: logic.searchRecordList,
        search: (keyword) => logic.startSearch(keyword),
        recordDelete: (item) => logic.deleteSearchRecord(item),
      ),
    );
  }

  // 构建搜索列表
  Widget _buildSearchList() {
    final padding = MediaQuery.of(context).padding;
    return CustomRefreshView(
        enableRefresh: true,
        enableLoadMore: true,
        controller: logic.controller,
        onRefresh: (loadMore) => logic.search(loadMore),
        child: ValueListenableBuilder<List<AnimeModel>>(
            valueListenable: logic.searchList,
            builder: (_, searchList, __) {
              return Stack(
                children: [
                  if (searchList.isEmpty)
                    const Center(
                      child: StatusBox(
                        status: StatusBoxStatus.empty,
                        title: Text('搜搜看~'),
                      ),
                    ),
                  ListView.builder(
                    itemCount: searchList.length,
                    padding: EdgeInsets.only(top: kToolbarHeight + padding.top),
                    itemBuilder: (_, i) {
                      final item = searchList[i];
                      return _buildSearchListItem(item);
                    },
                  ),
                ],
              );
            }));
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 14, color: Colors.black87);

  // 内容文本样式
  final subTitleStyle = const TextStyle(fontSize: 12, color: Colors.black38);

  // 构建搜索列表子项
  Widget _buildSearchListItem(AnimeModel item) {
    return InkWell(
      child: DefaultTextStyle(
        maxLines: 2,
        style: subTitleStyle,
        overflow: TextOverflow.ellipsis,
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
                    Text(item.name, style: titleStyle),
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

  // 刷新控制器
  final controller = CustomRefreshController();

  @override
  void init() {
    super.init();
    // 初始化搜索记录
    db.getSearchRecordList().then((v) {
      searchRecordList.setValue(v);
    });
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
