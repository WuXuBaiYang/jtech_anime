import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/cache_future_builder.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 番剧过滤条件配置
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class AnimeFilterConfigFAB extends StatefulWidget {
  // 过滤条件配置
  final MapValueChangeNotifier<String, dynamic> filterConfig;

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
            ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: widget.filterConfig,
                builder: (_, configMap, __) {
                  final hashCode = configMap.values.toString().hashCode;
                  final hasEdited = (lastConfigHash ??= hashCode) != hashCode;
                  final iconData = hasEdited
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.xmark;
                  return IconButton(
                    icon: Icon(iconData),
                    onPressed: () {
                      if (hasEdited) {
                        parserHandle.cacheFilterConfig(configMap);
                        widget.complete();
                      }
                      lastConfigHash = null;
                      filterStatus.setValue(FilterStatus.fold);
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
        return ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: widget.filterConfig,
          builder: (_, configMap, __) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 14),
              itemBuilder: (_, i) {
                return _buildFilterConfigListItem(dataList[i], configMap);
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
      AnimeFilterModel item, Map<String, dynamic> configMap) {
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
          child: _buildFilterConfigListItemTags(item, configMap),
        ),
      ],
    );
  }

  // 构建过滤配置列表标签集合
  Widget _buildFilterConfigListItemTags(
      AnimeFilterModel item, Map<String, dynamic> configMap) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(item.items.length, (i) {
        final it = item.items[i];
        final selects = configMap[item.key];
        return ChoiceChip(
          selected: selects?.contains(it.value) ?? false,
          label: Text(it.name),
          onSelected: (v) => setState(() {
            var result = selects ?? [];
            if (!v) {
              result.remove(it.value);
            } else {
              if (item.maxSelected == 1) {
                result = [it.value];
              } else if (result.length < item.maxSelected) {
                result = result..add(it.value);
              }
            }
            if (result.isEmpty) {
              widget.filterConfig.removeValue(item.key);
            } else {
              widget.filterConfig.putValue(item.key, result);
            }
          }),
        );
      }),
    );
  }
}

// fab状态管理
enum FilterStatus { fold, opening, expanded }
