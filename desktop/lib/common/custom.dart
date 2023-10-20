import 'package:desktop/manage/config.dart';
import 'package:desktop/model/config.dart';
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
    loadingDismissible: true,
    m3u8DownloadBatchSize: 30,
    baseCachePath: 'jtech_anime',
  );

  // 全局样式配置
  static final JTechThemeData themeData = JTechThemeData(
    loadingSize: 100,
  );

  // 系统样式表
  static final systemThemeData = <String, ThemeData>{
    Brightness.dark.name: _createThemeData(
      colorScheme: const ColorScheme.dark(),
    ),
    Brightness.light.name: _createThemeData(
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
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          toolbarHeight: kToolbarHeightCustom,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        cardTheme: const CardTheme(
          clipBehavior: Clip.antiAlias,
        ),
        chipTheme: ChipThemeData(
          pressElevation: 0,
          labelPadding: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          labelStyle: TextStyle(fontSize: 12, color: colorScheme.onSurface),
        ),
        iconTheme: const IconThemeData(size: 20),
        bottomSheetTheme: const BottomSheetThemeData(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          showDragHandle: true,
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.black12,
          thickness: 0.3,
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
          sizeConstraints: BoxConstraints.tightFor(width: 45, height: 45),
          extendedSizeConstraints: BoxConstraints.tightFor(height: 45),
          elevation: 1,
        ),
        listTileTheme: const ListTileThemeData(
          subtitleTextStyle: TextStyle(
            color: Colors.black38,
          ),
        ),
      );

  // 管理所有配置样式
  static void setup({
    required JTechConfig config,
    required JTechThemeData themeData,
    required Map<String, ThemeData> systemTheme,
  }) {
    theme.setup(systemTheme);
    rootConfig.setup(config: config, theme: themeData);
    platformConfig.setup(config: config, theme: themeData);
  }
}

const kToolbarHeightCustom = 35.0;
