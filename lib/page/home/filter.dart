import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/filter_select.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 番剧过滤条件配置
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class AnimeFilterConfigFAB extends StatefulWidget {
  // 过滤条件配置
  final MapValueChangeNotifier<String, FilterSelect> filterConfig;

  // 过滤配置条件回调
  final VoidCallback complete;

  const AnimeFilterConfigFAB(
      {super.key, required this.filterConfig, required this.complete});

  @override
  State<StatefulWidget> createState() => _AnimeFilterConfigFABState();
}

class _AnimeFilterConfigFABState extends State<AnimeFilterConfigFAB> {
  // fab状态管理
  final filterStatus = ValueChangeNotifier<FilterStatus>(FilterStatus.fold);

  // 动画时长
  final duration = const Duration(milliseconds: 200);

  // 记录编辑前的hash值
  int? lastConfigHash;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Tool.getScreenWidth(context);
    return Theme(
      data: _theme,
      child: ValueListenableBuilder<FilterStatus>(
        valueListenable: filterStatus,
        builder: (_, status, __) {
          final folded = status == FilterStatus.fold;
          final expanded = status == FilterStatus.expanded;
          final decoration = BoxDecoration(
            borderRadius: BorderRadius.circular(folded ? 14 : 8),
            color: kPrimaryColor,
            boxShadow: [
              BoxShadow(
                offset: Offset.fromDirection(90, 1),
                color: Colors.black26,
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          );
          final child = folded
              ? _buildFAButton()
              : (expanded ? _buildFilterConfig() : const SizedBox());
          return AnimatedContainer(
            duration: duration,
            decoration: decoration,
            curve: Curves.fastOutSlowIn,
            height: folded ? 55.0 : 350.0,
            width: folded ? 55.0 : screenWidth - 14.0 * 2,
            onEnd: () {
              if (!folded) filterStatus.setValue(FilterStatus.expanded);
            },
            child: child,
          );
        },
      ),
    );
  }

  // 样式管理
  ThemeData get _theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
        canvasColor: Colors.transparent,
        dividerTheme: DividerThemeData(
          color: Colors.white.withOpacity(0.2),
          endIndent: 14,
          thickness: 1,
          indent: 14,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: Colors.transparent,
          selectedColor: Colors.transparent,
          checkmarkColor: Colors.white,
          side: BorderSide.none,
        ),
      );

  // 构建按钮
  Widget _buildFAButton() {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.filter),
      onPressed: () => filterStatus.setValue(FilterStatus.opening),
    );
  }

  // 标题文本样式
  TextStyle titleTextStyle = TextStyle(color: Colors.white.withOpacity(0.6));

  // 构建过滤配置
  Widget _buildFilterConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildFilterConfigList()),
        const Divider(height: 1),
        Row(
          children: [
            const SizedBox(width: 8),
            Text('选择过滤条件', style: titleTextStyle),
            const Spacer(),
            ValueListenableBuilder<Map<String, FilterSelect>>(
                valueListenable: widget.filterConfig,
                builder: (_, configMap, __) {
                  final hashCode = configMap.keys.toString().hashCode;
                  final hasEdited = (lastConfigHash ??= hashCode) != hashCode;
                  final iconData = hasEdited
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.xmark;
                  return IconButton(
                    icon: Icon(iconData),
                    onPressed: () {
                      if (hasEdited) widget.complete();
                      filterStatus.setValue(FilterStatus.fold);
                      lastConfigHash = null;
                    },
                  );
                }),
          ],
        ),
      ],
    );
  }

  // 构建过滤配置列表
  Widget _buildFilterConfigList() {
    return StatusBoxCacheFuture<List<AnimeFilterModel>>(
      future: parserHandle.loadFilterList,
      builder: (dataList) {
        return ValueListenableBuilder<Map<String, FilterSelect>>(
          valueListenable: widget.filterConfig,
          builder: (_, selectMap, __) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 14),
              itemBuilder: (_, i) {
                return _buildFilterConfigListItem(dataList[i], selectMap);
              },
              itemCount: dataList.length,
            );
          },
        );
      },
    );
  }

  // 构建过滤配置列表项
  Widget _buildFilterConfigListItem(
      AnimeFilterModel item, Map<String, FilterSelect> selectMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(item.name,
              textAlign: TextAlign.right, style: titleTextStyle),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: _buildFilterConfigListItemTags(item, selectMap),
        ),
      ],
    );
  }

  // 构建过滤配置列表标签集合
  Widget _buildFilterConfigListItemTags(
      AnimeFilterModel item, Map<String, FilterSelect> selectMap) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(item.items.length, (i) {
        final it = item.items[i];
        final key = item.key + it.value;
        final selectItem = selectMap[key];
        return ChoiceChip(
          label: Text(it.name),
          selected: selectItem != null,
          onSelected: (v) async {
            if (v) {
              final result = await db.addFilterSelect(item, it,
                  source: parserHandle.currentSource);
              if (result != null) {
                final temp = {result.key + result.value: result};
                if (item.maxSelected == 1) {
                  temp.addAll(selectMap
                    ..removeWhere(
                      (_, v) => v.key == item.key,
                    ));
                }
                widget.filterConfig.setValue(temp);
              }
            } else if (selectItem != null) {
              final result = await db.removeFilterSelect(selectItem);
              if (result) widget.filterConfig.removeValue(key);
            }
          },
        );
      }),
    );
  }
}

// fab状态管理
enum FilterStatus { fold, opening, expanded }
