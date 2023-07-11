import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/search_record.dart';
import 'package:jtech_anime/page/search/search.dart';
import 'package:jtech_anime/tool/snack.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildSearchBar(context),
      ),
    );
  }

  // 构建搜索条
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
        top: MediaQuery.paddingOf(context).top,
      ),
      child: SearchBarView(
        inSearching: logic.inSearching,
        searchRecordList: logic.searchRecordList,
        search: (keyword) => logic.search(context, keyword, false),
        recordDelete: (item) => logic.deleteSearchRecord(context, item),
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
