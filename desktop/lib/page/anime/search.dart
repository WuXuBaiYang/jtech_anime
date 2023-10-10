import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

// 执行搜索回调
typedef SearchCallback = void Function(String keyword);

// 搜索记录删除回调
typedef RecordDeleteCallback = void Function(SearchRecord item);

/*
* 搜索条组件
* @author wuxubaiyang
* @Time 2023/7/11 16:35
*/
class SearchBarView extends StatelessWidget {
  // 搜索记录列表
  final ListValueChangeNotifier<SearchRecord> searchRecordList;

  // 搜索记录删除回调
  final RecordDeleteCallback recordDelete;

  // 搜索回调
  final SearchCallback search;

  // 动作按钮集合
  final List<Widget> actions;

  // 容器限制
  final BoxConstraints constraints;

  // 是否存在搜索内容
  final hasSearchContent = ValueChangeNotifier<bool>(false);

  SearchBarView({
    super.key,
    required this.searchRecordList,
    required this.recordDelete,
    required this.search,
    this.constraints = const BoxConstraints(
      maxWidth: 180,
      maxHeight: 450,
    ),
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchRecordList,
      builder: (_, searchRecords, ___) {
        return ConstrainedBox(
          constraints: constraints,
          child: Autocomplete<SearchRecord>(
            optionsBuilder: (v) {
              final keyword = v.text.trim().toLowerCase();
              if (keyword.isEmpty) return [];
              return searchRecords.where(
                (e) => e.keyword.contains(keyword),
              );
            },
            fieldViewBuilder: _buildFieldView,
            optionsViewBuilder: _buildOptionsView,
            displayStringForOption: (e) => e.keyword,
            onSelected: (v) => search(v.keyword.trim()),
          ),
        );
      },
    );
  }

  // 构建搜索条输入框
  Widget _buildFieldView(BuildContext context, TextEditingController controller,
      FocusNode focusNode, VoidCallback _) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      borderSide: BorderSide(width: 0.8, color: Colors.black38),
    );
    final focusBorder = border.copyWith(
      borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.6)),
    );
    return TextField(
      onSubmitted: search,
      focusNode: focusNode,
      controller: controller,
      cursorRadius: const Radius.circular(4),
      scrollPhysics: const ClampingScrollPhysics(),
      style: const TextStyle(fontSize: 14, height: 1.3),
      decoration: InputDecoration(
        hintText: '嗖~',
        isCollapsed: true,
        enabledBorder: border,
        focusedBorder: focusBorder,
        contentPadding: const EdgeInsets.only(top: 4),
        constraints: const BoxConstraints(maxHeight: 35),
        hintStyle: const TextStyle(color: Colors.black12),
        suffix: _buildFieldViewClear(controller, focusNode),
        prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 14),
      ),
    );
  }

  // 构建搜索条输入框的清除按钮
  Widget _buildFieldViewClear(
      TextEditingController controller, FocusNode focusNode) {
    return IconButton(
      iconSize: 14,
      icon: const Icon(FontAwesomeIcons.xmark),
      onPressed: () {
        controller.clear();
        search('');
      },
    );
  }

  // 构建搜索条选项
  Widget _buildOptionsView(
    BuildContext context,
    AutocompleteOnSelected<SearchRecord> onSelected,
    Iterable<SearchRecord> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: constraints,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: min(options.length, 5),
            itemBuilder: (_, i) {
              final item = options.elementAt(i);
              return _buildOptionsViewItem(item, () => onSelected(item));
            },
          ),
        ),
      ),
    );
  }

  // 构建搜索补充条件子项
  Widget _buildOptionsViewItem(SearchRecord item, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      title: Text(item.keyword),
      contentPadding: const EdgeInsets.only(left: 18, right: 8),
      trailing: IconButton(
        icon: const Icon(FontAwesomeIcons.trashCan,
            color: Colors.black38, size: 18),
        onPressed: () => recordDelete(item),
      ),
    );
  }
}
