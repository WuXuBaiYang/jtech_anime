import 'package:desktop/common/route.dart';
import 'package:desktop/common/custom.dart';
import 'package:desktop/page/home/index.dart';
import 'package:desktop/tool/version.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 下方设置系统主题，全局的配置/样式
  Custom.setup(
    config: Custom.config,
    themeData: Custom.themeData,
    systemTheme: Custom.systemThemeData,
  );
  // 初始化核心内容
  await ensureInitializedCore();
  // 初始化窗口管理
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    center: true,
    skipTaskbar: false,
    size: Custom.defaultWindowSize,
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: Custom.defaultWindowSize,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // 监听下载进度变化
  download.downloadProgress.listen((task) {
    if (task != null && task.downloadingMap.isNotEmpty) {
      final progress = task.totalRatio;
      return Throttle.c(
        () => windowManager.setProgressBar(progress),
        delay: const Duration(milliseconds: 500),
        'update_progress',
      );
    }
    windowManager.setProgressBar(0);
  });
  // 监听版本更新状态
  AppVersionTool.downloadProgressStream.listen((progress) {
    if (progress < 1.0) {
      return Throttle.c(
        () => windowManager.setProgressBar(progress),
        delay: const Duration(milliseconds: 500),
        'update_progress',
      );
    }
    windowManager.setProgressBar(0);
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
