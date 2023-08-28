import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/future_builder.dart';

/*
* 番剧过滤条件选择
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class HomeLatestAnimeFilterSheet extends StatefulWidget {
  // 已选择的过滤条件
  final Map<String, FilterSelect> selectMap;

  const HomeLatestAnimeFilterSheet({
    super.key,
    required this.selectMap,
  });

  static Future<List<FilterSelect>?> show(
    BuildContext context, {
    required Map<String, FilterSelect> selectMap,
  }) {
    return showModalBottomSheet<List<FilterSelect>>(
      context: context,
      builder: (_) {
        return HomeLatestAnimeFilterSheet(
          selectMap: selectMap,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('番剧筛选'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.xmark),
            onPressed: () => router.pop(),
          ),
        ],
      ),
      body: _buildFilterList(),
    );
  }

  // 构建过滤配置列表
  Widget _buildFilterList() {
    return CacheFutureBuilder<List<AnimeFilterModel>>(
      future: animeParser.loadFilterList,
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();
        final dataList = snap.data ?? [];
        return ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (_, i) {
            return _buildFilterListItem(
              dataList[i],
              widget.selectMap,
            );
          },
        );
      },
    );
  }

  // 构建过滤配置列表项
  Widget _buildFilterListItem(
      AnimeFilterModel item, Map<String, FilterSelect> selectMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        _buildFilterListItemTags(item, selectMap),
      ],
    );
  }

  // 构建过滤配置列表标签集合
  Widget _buildFilterListItemTags(
      AnimeFilterModel item, Map<String, FilterSelect> selectMap) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(item.items.length, (i) {
        final sub = item.items[i];
        var selectItem = selectMap['${item.key}${sub.value}'];
        return ChoiceChip(
          label: Text(sub.name),
          selected: selectItem != null,
          onSelected: (v) {
            final source = animeParser.currentSource;
            if (source == null) return;
            selectItem ??= FilterSelect()
              ..key = item.key
              ..value = sub.value
              ..parentName = item.name
              ..name = sub.name
              ..source = source.key;
            // widget.filterSelect(v, selectItem!, item.maxSelected);
          },
        );
      }),
    );
  }
}
