import 'package:desktop/common/route.dart';
import 'package:desktop/common/theme.dart';
import 'package:desktop/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化核心内容
  await ensureInitializedCore(
    noPictureMode: false,
    defaultStatusAnimeSize: 100,
    defaultLoadingAnimeSize: 60,
    defaultLoadingDismissible: true,
    themeDataMap: CustomTheme.dataMap,
    defaultImageLoadingAnimeRatio: 0.8,
  );
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
