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
  final _defBrightness = Brightness.dark;

  static final ThemeManage _instance = ThemeManage._internal();

  factory ThemeManage() => _instance;

  ThemeManage._internal();

  // 获取主色
  Color get primaryColor => currentTheme.colorScheme.primary;

  // 判断当前是否为暗色调
  bool get isDarkMode => currentTheme.brightness == Brightness.dark;

  // 切换默认样式
  Future<void> switchTheme(Brightness brightness) async {
    if (await cache.setInt(_themeCacheKey, brightness.index)) {
      _currentTheme = getThemeByBrightness(brightness);
      event.send(ThemeEvent(data: _currentTheme!));
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
          colorScheme: const ColorScheme.dark(
            primary: Color(0xff49b7ff),
            secondary: Color(0xff48b4f8),
            background: Color(0xff0c1927),
          ),
        ),
        Brightness.light: _createThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff5168ff),
            secondary: Color(0xff5168ff),
            background: Color(0xfff7f7fa),
          ),
        ),
      }[brightness]!;

  // 样式配置
  ThemeData _createThemeData({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 18),
          centerTitle: true,
        ),
        canvasColor: Colors.transparent,
        scaffoldBackgroundColor: colorScheme.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            textStyle: const TextStyle(fontSize: 18),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 0.3),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          fillColor: Colors.white.withOpacity(0.1),
          filled: true,
        ),
        dividerTheme:
            DividerThemeData(color: colorScheme.primary, thickness: 0.2),
        drawerTheme: const DrawerThemeData(width: 260),
        listTileTheme: const ListTileThemeData(minLeadingWidth: 0),
        cardTheme: const CardTheme(elevation: 1),
        tabBarTheme: TabBarTheme(
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (states) => states.contains(MaterialState.focused)
                ? null
                : Colors.transparent,
          ),
          indicator: const BoxDecoration(),
        ),
        chipTheme: ChipThemeData(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          labelStyle: TextStyle(color: colorScheme.primary, fontSize: 12),
          backgroundColor: colorScheme.primary.withOpacity(0.05),
          selectedColor: colorScheme.primary.withOpacity(0.3),
          checkmarkColor: colorScheme.primary,
        ),
      );
}

// 获取当前主色调
Color get kPrimaryColor => theme.primaryColor;

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

  ThemeEvent({required this.data});
}
