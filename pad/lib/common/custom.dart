import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义样式配置
* @author wuxubaiyang
* @Time 2023/9/6 12:34
*/
class Custom {
  // 全局配置
  static final JTechConfig config = JTechConfig(
    noPictureMode: true,
    noPlayerContent: true,
    screenType: ScreenType.pad,
  );

  // 全局样式配置
  static final JTechThemeData themeData = JTechThemeData();

  // 系统样式表
  static final systemThemeData = <String, ThemeData>{
    'default': _createThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF7DB0),
        secondary: Color(0xFF84EBE1),
      ),
    ),
  };

  // 样式配置
  static ThemeData _createThemeData({required ColorScheme colorScheme}) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        cardTheme: CardTheme(
          color: colorScheme.primary.withOpacity(0.12),
          elevation: 0,
        ),
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
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          clipBehavior: Clip.hardEdge,
          showDragHandle: true,
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.black12,
          thickness: 0.2,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            elevation: const MaterialStatePropertyAll(0),
            backgroundColor:
                MaterialStatePropertyAll(colorScheme.primary.withOpacity(0.12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 1,
        ),
        listTileTheme: const ListTileThemeData(
          subtitleTextStyle: TextStyle(
            color: Colors.black38,
          ),
        ),
      );
}
