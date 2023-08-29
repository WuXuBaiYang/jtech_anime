import 'package:flutter/material.dart';
import 'package:jtech_anime/common/manage.dart';

import 'cache.dart';
import 'event.dart';

/*
* 样式管理
* @author wuxubaiyang
* @Time 2022/10/14 10:09
*/
class ThemeManage extends BaseManage {
  // 默认样式缓存字段
  final String _themeCacheKey = 'theme_cache';

  // 默认色调
  final _defBrightness = Brightness.light;

  static final ThemeManage _instance = ThemeManage._internal();

  factory ThemeManage() => _instance;

  ThemeManage._internal();

  // 获取主色
  Color get primaryColor => currentTheme.colorScheme.primary;

  // 次要颜色
  Color get secondaryColor => currentTheme.colorScheme.secondary;

  // 判断当前是否为暗色调
  bool get isDarkMode => currentTheme.brightness == Brightness.dark;

  // 切换默认样式
  Future<void> switchTheme(Brightness brightness) async {
    if (await cache.setInt(_themeCacheKey, brightness.index)) {
      _currentTheme = getThemeByBrightness(brightness);
      event.send(ThemeEvent(_currentTheme!));
    }
  }

  // 明暗样式开关
  Future<void> toggleTheme() async {
    final type = currentTheme.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    return switchTheme(type);
  }

  // 缓存当前样式
  ThemeData? _currentTheme;

  // 当前样式
  ThemeData get currentTheme => _currentTheme ??= getThemeByBrightness(
      Brightness.values[cache.getInt(_themeCacheKey) ?? _defBrightness.index]);

  // 根据色调获取对应的样式
  ThemeData getThemeByBrightness(Brightness brightness) => {
        Brightness.dark: _createThemeData(
          colorScheme: const ColorScheme.dark(),
        ),
        Brightness.light: _createThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF7DB0),
            secondary: Color(0xFF84EBE1),
          ),
        ),
      }[brightness]!;

  // 样式配置
  ThemeData _createThemeData({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        chipTheme: const ChipThemeData(
          pressElevation: 0,
        ),
        dialogTheme: const DialogTheme(
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
        ),
        iconTheme: const IconThemeData(size: 30),
        bottomSheetTheme: const BottomSheetThemeData(
          clipBehavior: Clip.hardEdge,
        ),
      );
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
