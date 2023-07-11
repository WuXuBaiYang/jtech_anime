import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/search_record.dart';
import 'package:jtech_anime/tool/snack.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildSearchBar(context),
      ),
    );
  }

  // 构建搜索条
  Widget _buildSearchBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ValueListenableBuilder(
          valueListenable: logic.searchRecordList,
          builder: (_, __, ___) {
            return Autocomplete<SearchRecord>(
              optionsBuilder: (v) {
                final keyword = v.text.trim();
                if (keyword.isEmpty) return [];
                return logic.searchRecordList.value.where(
                  (e) => e.keyword.contains(keyword),
                );
              },
              fieldViewBuilder: _buildSearchBarField,
              displayStringForOption: (e) => e.keyword,
              optionsViewBuilder: _buildSearchBarOptions,
              onSelected: (v) => logic.search(context, v.keyword, false),
            );
          },
        ),
      ),
    );
  }

  // 构建搜索条输入框
  Widget _buildSearchBarField(BuildContext context,
      TextEditingController controller, FocusNode focusNode, VoidCallback _) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: TextField(
          autofocus: true,
          focusNode: focusNode,
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.black38),
            border: InputBorder.none,
            hintText: '嗖嗖嗖~',
            prefixIcon: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft),
              onPressed: () => router.pop(),
            ),
            suffixIcon: _buildSearchBarFieldSubmit(controller, focusNode),
          ),
          onSubmitted: (v) {
            logic.search(context, v, false);
          },
        ),
      ),
    );
  }

  // 构建搜索条输入框的确认按钮
  Widget _buildSearchBarFieldSubmit(
      TextEditingController controller, FocusNode focusNode) {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.loading,
      builder: (_, loading, __) {
        return AnimatedCrossFade(
          firstChild: IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass),
            onPressed: () {
              final keyword = controller.text.trim();
              logic.search(context, keyword, false);
              focusNode.unfocus();
            },
          ),
          secondChild: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: StatusBox(
              status: StatusBoxStatus.loading,
              animSize: 14,
            ),
          ),
          duration: const Duration(milliseconds: 100),
          crossFadeState:
              loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        );
      },
    );
  }

  // 构建搜索条选项
  Widget _buildSearchBarOptions(
    BuildContext context,
    AutocompleteOnSelected<SearchRecord> onSelected,
    Iterable<SearchRecord> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(left: 4, right: 30),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: min(options.length, 5),
            itemBuilder: (_, i) {
              final item = options.elementAt(i);
              return _buildSearchBarOptionsItem(item, onSelected);
            },
          ),
        ),
      ),
    );
  }

  // 构建搜索补充条件子项
  Widget _buildSearchBarOptionsItem(
      SearchRecord item, AutocompleteOnSelected<SearchRecord> onSelected) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 18, right: 8),
      title: Text(item.keyword),
      trailing: IconButton(
        icon: const Icon(FontAwesomeIcons.trashCan,
            color: Colors.black38, size: 18),
        onPressed: () => logic.deleteSearchRecord(context, item),
      ),
      onTap: () => onSelected(item),
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

  // 加载状态管理
  final loading = ValueChangeNotifier<bool>(false);

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
    if (loading.value) return;
    if (keyword.trim().isEmpty) return;
    try {
      loading.setValue(true);
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
      loading.setValue(false);
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
