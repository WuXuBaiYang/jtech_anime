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

  const SearchBarView({
    super.key,
    required this.searchRecordList,
    required this.recordDelete,
    required this.search,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchRecordList,
      builder: (_, searchRecords, ___) {
        return Autocomplete<SearchRecord>(
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
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: '嗖~',
        isCollapsed: true,
        enabledBorder: border,
        focusedBorder: focusBorder,
        hintStyle: const TextStyle(color: Colors.black12),
        suffix: _buildFieldViewSubmit(controller, focusNode),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 2).copyWith(left: 20),
      ),
    );
  }

  // 构建搜索条输入框的确认按钮
  Widget _buildFieldViewSubmit(
      TextEditingController controller, FocusNode focusNode) {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.magnifyingGlass),
      onPressed: () {
        search(controller.text.trim());
        focusNode.unfocus();
      },
    );
  }

  // 构建搜索条选项
  Widget _buildOptionsView(
    BuildContext context,
    AutocompleteOnSelected<SearchRecord> onSelected,
    Iterable<SearchRecord> options,
  ) {
    return const SizedBox();
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(left: 4, right: 30, top: 8),
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
