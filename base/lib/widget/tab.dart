import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/theme.dart';

/*
* 自定义tabBar
* @author wuxubaiyang
* @Time 2023/8/28 14:18
*/
class CustomTabBar extends StatelessWidget {
  // tab集合
  final List<Widget> tabs;

  // 是否为滚动状态
  final bool isScrollable;

  // 点击事件
  final ValueChanged<int>? onTap;

  // 控制器
  final TabController? controller;

  // 覆盖颜色
  final Color? overlayColor;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.onTap,
    this.controller,
    this.overlayColor,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: kPrimaryColor.withOpacity(0.12),
      ),
      child: _buildTabBar(borderRadius),
    );
  }

  // 构建tabBar
  Widget _buildTabBar(BorderRadius borderRadius) {
    return TabBar(
      tabs: tabs,
      onTap: onTap,
      controller: controller,
      labelColor: Colors.white,
      isScrollable: isScrollable,
      dividerColor: Colors.transparent,
      splashBorderRadius: borderRadius,
      unselectedLabelColor: kPrimaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      overlayColor: MaterialStatePropertyAll(overlayColor),
      tabAlignment: isScrollable ? TabAlignment.center : TabAlignment.fill,
      indicator: BoxDecoration(
        borderRadius: borderRadius,
        color: kPrimaryColor,
      ),
    );
  }
}
