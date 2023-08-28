import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/theme.dart';

/*
* 自定义tabBar
* @author wuxubaiyang
* @Time 2023/8/28 14:18
*/
class CustomTabBar extends StatelessWidget {
  // tab集合
  final List<Widget> tabs;

  const CustomTabBar({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);
    return Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: kPrimaryColor.withOpacity(0.15),
      ),
      child: TabBar(
        tabs: tabs,
        indicatorWeight: 0,
        labelColor: Colors.white,
        dividerColor: Colors.transparent,
        splashBorderRadius: borderRadius,
        unselectedLabelColor: kPrimaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: borderRadius,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}
