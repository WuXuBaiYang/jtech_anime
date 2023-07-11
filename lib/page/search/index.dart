import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/search_record.dart';
import 'package:jtech_anime/page/search/search.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
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
          _buildSearchList(context),
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
        inSearching: logic.inSearching,
        searchRecordList: logic.searchRecordList,
        search: (keyword) => logic.search(context, keyword, false),
        recordDelete: (item) => logic.deleteSearchRecord(context, item),
      ),
    );
  }

  // 构建搜索列表
  Widget _buildSearchList(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<AnimeModel>>(
        valueListenable: logic.searchList,
        builder: (_, searchList, __) {
          if (searchList.isEmpty) {
            return const Center(
              child: StatusBox(
                status: StatusBoxStatus.empty,
                title: Text('搜搜看~'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            itemCount: searchList.length,
            itemBuilder: (_, i) {
              final item = searchList[i];
              return _buildSearchListItem(item);
            },
          );
        },
      ),
    );
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 14, color: Colors.black87);

  // 内容文本样式
  final subTitleStyle = const TextStyle(fontSize: 12, color: Colors.black38);

  // 构建搜索列表子项
  Widget _buildSearchListItem(AnimeModel item) {
    // ,
    // maxLines: 2,
    // overflow: TextOverflow.ellipsis
    return InkWell(
      child: DefaultTextStyle(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageView.net(item.cover,
                  width: 100, height: 120, fit: BoxFit.cover),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(item.name, style: titleStyle),
                  Text(item.status, style: subTitleStyle),
                  Text(item.intro, style: subTitleStyle),
                ],
              ),
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
* 搜索页-逻辑
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class _SearchLogic extends BaseLogic {
  // 搜索列表
  final searchList = ListValueChangeNotifier<AnimeModel>.empty();

  // 缓存搜索记录
  final searchRecordList = ListValueChangeNotifier<SearchRecord>.empty();

  // 是否正在搜索中
  final inSearching = ValueChangeNotifier<bool>(false);

  // 滚动控制器
  final scrollController = ScrollController();

  @override
  void init() {
    super.init();
    // 初始化搜索记录
    db.getSearchRecordList().then((v) {
      searchRecordList.setValue(v);
    });
  }

  // 执行搜索
  Future<void> search(
      BuildContext context, String keyword, bool loadMore) async {
    if (inSearching.value) return;
    if (keyword.trim().isEmpty) return;
    try {
      inSearching.setValue(true);
      // 缓存搜索记录
      final record = await db.addSearchRecord(keyword);
      if (record != null) {
        searchRecordList
          ..removeWhere((e) => e.id == record.id, notify: false)
          ..addValue(record);
      }
      // 执行搜索请求
      final result = await (loadMore
          ? parserHandle.searchAnimeListNextPage(keyword)
          : parserHandle.searchAnimeList(keyword));
      loadMore ? searchList.addValues(result) : searchList.setValue(result);
    } catch (e) {
      SnackTool.showMessage(context, message: '搜索请求失败，请重试~');
    } finally {
      inSearching.setValue(false);
    }
  }

  // 删除搜索记录
  Future<bool> deleteSearchRecord(
      BuildContext context, SearchRecord item) async {
    var result = false;
    try {
      result = await db.removeSearchRecord(item.id);
      if (result) searchRecordList.removeValue(item);
    } catch (e) {
      SnackTool.showMessage(context, message: '搜索记录删除失败，请重试~');
    }
    return result;
  }
}
