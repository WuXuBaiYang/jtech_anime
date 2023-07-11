import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/cache.dart';

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
      appBar: AppBar(
        titleSpacing: 0,
        title: Autocomplete<String>(
          optionsBuilder: (v) {
            if (v.text.isEmpty) return [];
            return logic.searchHistory.value
                .where((e) => e.contains(v.text.toLowerCase()));
          },
          fieldViewBuilder: (_, c, __, ___) {
            return TextField();
          },
          // onSelected: (v) =>
          //     Tool.showLoading(context, loadFuture: logic.search(v)),
          optionsViewBuilder: (BuildContext context,
              void Function(String) onSelected, Iterable<String> options) {
            return SizedBox();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass),
            onPressed: () {},
            // onPressed: () =>
            //     Tool.showLoading(context, loadFuture: logic.search(v)),
          ),
        ],
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
  // 搜索记录缓存key
  final _searchHistoryKey = 'search_history_key';

  // 存储搜索记录
  final searchHistory = ListValueChangeNotifier<String>.empty();

  @override
  void init() {
    super.init();
    // 设置缓存的搜索记录
    searchHistory.setValue(cache.getStringList(_searchHistoryKey) ?? []);
  }

  // 执行搜索
  Future<void> search(String v) async {
    if (!searchHistory.contains(v)) {
      searchHistory.addValue(v);
      cache.setStringList(
        _searchHistoryKey,
        searchHistory.value,
      );
    }
  }
}
