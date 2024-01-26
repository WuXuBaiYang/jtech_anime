import 'package:flutter/material.dart';
import 'package:jtech_anime_base/common/manage.dart';
import 'local_cache.dart';
import 'event.dart';

/*
* 样式管理
* @author wuxubaiyang
* @Time 2022/10/14 10:09
*/
class ThemeManage extends BaseManage {
  // 默认样式缓存字段
  final String _themeCacheKey = 'theme_cache';

  // 缓存样式配置表
  late Map<String, ThemeData> _themeDataMap = {};

  static final ThemeManage _instance = ThemeManage._internal();

  factory ThemeManage() => _instance;

  ThemeManage._internal();

  // 获取主色
  Color get primaryColor => currentTheme.colorScheme.primary;

  // 次要颜色
  Color get secondaryColor => currentTheme.colorScheme.secondary;

  // 判断当前是否为暗色调
  bool get isDarkMode => currentTheme.brightness == Brightness.dark;

  // 设置样式表
  void setup(Map<String, ThemeData> themeDataMap) =>
      _themeDataMap = themeDataMap;

  // 缓存当前样式
  ThemeData? _currentTheme;

  // 当前样式
  ThemeData get currentTheme => _currentTheme ??=
      (_themeDataMap.values.firstOrNull ?? ThemeData(useMaterial3: true));

  // 切换默认样式
  Future<void> switchTheme(String key) async {
    if (await cache.setString(_themeCacheKey, key)) {
      if (_themeDataMap[key] == null) return;
      _currentTheme = _themeDataMap[key];
      event.send(ThemeEvent(_currentTheme!));
    }
  }
}

// 获取当前主色调
Color get kPrimaryColor => theme.primaryColor;

// 获取当前次色调
Color get kSecondaryColor => theme.secondaryColor;

// 判断当前是否为暗色模式
bool get kDarkMode => theme.isDarkMode;

// 单例调用
final theme = ThemeManage();

/*
* 全局样式控制事件
* @author wuxubaiyang
* @Time 2022/4/1 15:14
*/
class ThemeEvent extends EventModel {
  // 全局样式
  final ThemeData data;

  ThemeEvent(this.data);
}
