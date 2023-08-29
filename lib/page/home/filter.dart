import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:collection/collection.dart';

/*
* 番剧过滤条件选择
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class HomeLatestAnimeFilterSheet extends StatefulWidget {
  // 已选择的过滤条件
  final List<FilterSelect> selectFilters;

  const HomeLatestAnimeFilterSheet({
    super.key,
    required this.selectFilters,
  });

  static Future<List<FilterSelect>?> show(
    BuildContext context, {
    required List<FilterSelect> selectFilters,
  }) {
    return showModalBottomSheet<List<FilterSelect>>(
      context: context,
      builder: (_) {
        return HomeLatestAnimeFilterSheet(
          selectFilters: selectFilters,
        );
      },
    );
  }

  @override
  State<HomeLatestAnimeFilterSheet> createState() =>
      _HomeLatestAnimeFilterSheetState();
}

class _HomeLatestAnimeFilterSheetState
    extends State<HomeLatestAnimeFilterSheet> {
  // 选择数据回调
  late MapValueChangeNotifier<String, List<FilterSelect>> filterSelect =
      MapValueChangeNotifier(
          groupBy<FilterSelect, String>(widget.selectFilters, (e) => e.key));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('番剧筛选'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.xmark),
            onPressed: () => router.pop(),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.check),
            onPressed: () => router.pop(
              filterSelect.values.expand((e) => e).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(child: _buildFilterList()),
        ],
      ),
    );
  }

  // 构建过滤配置列表
  Widget _buildFilterList() {
    return CacheFutureBuilder<List<AnimeFilterModel>>(
      future: animeParser.loadFilterList,
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();
        final dataList = snap.data ?? [];
        return ValueListenableBuilder<Map<String, List<FilterSelect>>>(
          valueListenable: filterSelect,
          builder: (_, filters, __) {
            return ListView.separated(
              itemCount: dataList.length,
              separatorBuilder: (_, i) => const SizedBox(height: 14),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              itemBuilder: (_, i) {
                return _buildFilterListItem(dataList[i], filters);
              },
            );
          },
        );
      },
    );
  }

  // 构建过滤配置列表项
  Widget _buildFilterListItem(
      AnimeFilterModel item, Map<String, List<FilterSelect>> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
        ),
        const SizedBox(height: 4),
        _buildFilterListItemTags(item, filters),
      ],
    );
  }

  // 构建过滤配置列表标签集合
  Widget _buildFilterListItemTags(
      AnimeFilterModel item, Map<String, List<FilterSelect>> filters) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(item.items.length, (i) {
        final sub = item.items[i];
        var selectItem = filters[item.key]?.firstWhereOrNull(
          (e) => e.value == sub.value,
        );
        return ChoiceChip(
          label: Text(sub.name),
          selected: selectItem != null,
          onSelected: (v) => _filterItemSelected(item, sub, selectItem),
        );
      }),
    );
  }

  // 过滤条件选择事件
  void _filterItemSelected(AnimeFilterModel item, AnimeFilterItemModel sub,
      FilterSelect? selectItem) {
    if (selectItem == null) {
      final source = animeParser.currentSource;
      if (source == null) return;
      final temp = filterSelect.value;
      final values = temp[item.key] ?? [];
      if (item.maxSelected == 1) values.clear();
      if (values.length >= item.maxSelected) return;
      values.add(FilterSelect()
        ..key = item.key
        ..value = sub.value
        ..parentName = item.name
        ..name = sub.name
        ..source = source.key);
      filterSelect.setValue({...temp, item.key: values});
    } else {
      final temp = filterSelect.value;
      temp[item.key]?.removeWhere((e) => e.value == sub.value);
      filterSelect.setValue({...temp});
    }
  }
}
