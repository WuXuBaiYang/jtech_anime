import 'package:desktop/common/route.dart';
import 'package:desktop/common/theme.dart';
import 'package:desktop/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:window_manager/window_manager.dart';

import 'manage/config.dart';
import 'model/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 下方设置系统主题，全局的配置/样式
  _setupConfigTheme(
    config: JTechConfig(
      noPictureMode: true,
      noPlayerContent: true,
      loadingDismissible: true,
      m3u8DownloadBatchSize: 30,
      baseCachePath: 'jtech_anime',
    ),
    themeData: JTechThemeData(
      loadingSize: 100,
    ),
    systemTheme: CustomTheme.dataMap,
  );
  // 初始化核心内容
  await ensureInitializedCore();
  // 初始化窗口管理
  await windowManager.ensureInitialized();
  const size = Size(800, 600);
  const windowOptions = WindowOptions(
    size: size,
    center: true,
    minimumSize: size,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomMaterialApp(
      routesMap: RoutePath.routes,
      home: const HomePage(),
    );
  }
}

// 管理所有配置样式
void _setupConfigTheme({
  required JTechConfig config,
  required JTechThemeData themeData,
  required Map<Brightness, ThemeData> systemTheme,
}) {
  theme.setup(systemTheme);
  rootConfig.setup(config: config, theme: themeData);
  platformConfig.setup(config: config, theme: themeData);
}
