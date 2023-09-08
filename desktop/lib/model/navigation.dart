import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页导航栏model
* @author wuxubaiyang
* @Time 2023/9/8 17:05
*/
class HomeNavigationModel extends BaseModel {
  // 名称
  final String name;

  // 图标
  final IconData icon;

  // 选中图标
  final IconData selectedIcon;

  HomeNavigationModel({
    required this.name,
    required this.icon,
    required this.selectedIcon,
  });
}
