import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/future_builder.dart';

// 过滤条件选择回调
typedef FilterSelectCallback = void Function(
    bool selected, FilterSelect item, int maxSelected);

/*
* 番剧过滤条件配置
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class AnimeFilterConfigMenu extends StatefulWidget {
  // 过滤条件配置
  final MapValueChangeNotifier<String, FilterSelect> filterConfig;

  // 选择回调
  final FilterSelectCallback filterSelect;

  // 过滤配置条件回调
  final VoidCallback complete;

  // 内容体
  final Widget body;

  const AnimeFilterConfigMenu({
    super.key,
    required this.filterConfig,
    required this.filterSelect,
    required this.complete,
    required this.body,
  });

  @override
  State<AnimeFilterConfigMenu> createState() => _AnimeFilterConfigMenuState();
}

class _AnimeFilterConfigMenuState extends State<AnimeFilterConfigMenu> {
  // fab状态管理
  final filterStatus = ValueChangeNotifier<FilterStatus>(FilterStatus.fold);

  // 标题文本样式
  final TextStyle titleTextStyle =
      TextStyle(color: Colors.white.withOpacity(0.6));

  // 记录编辑前的hash值
  final lastConfigHash = ValueChangeNotifier<int?>(null);

  // 动画时长
  final duration = const Duration(milliseconds: 120);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: widget.body),
        Positioned.fill(child: _buildBackground()),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: _buildFAB(context),
          ),
        ),
      ],
    );
  }

  // 构建背景
  Widget _buildBackground() {
    return ValueListenableBuilder<FilterStatus>(
      valueListenable: filterStatus,
      builder: (_, status, __) {
        final folded = status == FilterStatus.fold;
        return AnimatedOpacity(
          duration: duration,
          opacity: folded ? 0 : 1,
          child: folded
              ? const SizedBox()
              : GestureDetector(
                  child: Container(color: Colors.black12),
                  onTapDown: (_) => filterStatus.setValue(FilterStatus.fold),
                ),
        );
      },
    );
  }

  // 样式配置
  ThemeData get _themeData => ThemeData(
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

  // 创建装饰器
  BoxDecoration _createDecoration(bool folded) => BoxDecoration(
        borderRadius: BorderRadius.circular(folded ? 14 : 8),
        color: kPrimaryColor,
        boxShadow: [
          BoxShadow(
            offset: Offset.fromDirection(90, 1),
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      );

  // 构建fab
  Widget _buildFAB(BuildContext context) {
    final screenWidth = Tool.getScreenWidth(context);
    return Theme(
      data: _themeData,
      child: ValueListenableBuilder<FilterStatus>(
        valueListenable: filterStatus,
        builder: (_, status, __) {
          final folded = status == FilterStatus.fold;
          final expanded = status == FilterStatus.expanded;
          return AnimatedContainer(
            duration: duration,
            curve: Curves.fastOutSlowIn,
            height: folded ? 55.0 : 350.0,
            margin: const EdgeInsets.all(14),
            decoration: _createDecoration(folded),
            width: folded ? 55.0 : screenWidth - 14.0 * 2,
            onEnd: () {
              if (!folded) filterStatus.setValue(FilterStatus.expanded);
            },
            child: !folded
                ? (expanded ? _buildFilterConfig() : const SizedBox())
                : _buildFAButton(),
          );
        },
      ),
    );
  }

  // 构建按钮
  Widget _buildFAButton() {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.filter),
      onPressed: () => filterStatus.setValue(FilterStatus.opening),
    );
  }

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
                  if (lastConfigHash.value == null) {
                    lastConfigHash.setValue(hashCode);
                  }
                  final hasEdited = lastConfigHash.value != hashCode;
                  final iconData = hasEdited
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.xmark;
                  return IconButton(
                    icon: Icon(iconData),
                    onPressed: () {
                      if (hasEdited) widget.complete();
                      filterStatus.setValue(FilterStatus.fold);
                      lastConfigHash.setValue(null);
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
    return CacheFutureBuilder<List<AnimeFilterModel>>(
      future: parserHandle.loadFilterList,
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();
        final dataList = snap.data ?? [];
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
        final sub = item.items[i];
        var selectItem = selectMap['${item.key}${sub.value}'];
        return ChoiceChip(
          label: Text(sub.name),
          selected: selectItem != null,
          onSelected: (v) {
            selectItem ??= FilterSelect()
              ..key = item.key
              ..value = sub.value
              ..parentName = item.name
              ..name = sub.name
              ..source = parserHandle.currentSource;
            widget.filterSelect(v, selectItem!, item.maxSelected);
          },
        );
      }),
    );
  }
}

// fab状态管理
enum FilterStatus { fold, opening, expanded }
