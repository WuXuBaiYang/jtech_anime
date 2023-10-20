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
    themeDataMap: CustomTheme.dataMap,

    /// 如需自定义基本配置请更改此处
    config: RootJTechConfig(
      noPictureMode: true,
      noPlayerContent: true,
      loadingDismissible: true,
      m3u8DownloadBatchSize: 30,
      baseCachePath: 'jtech_anime',
    ),

    /// 如需自定义基本样式请更改此处
    themeData: RootJTechThemeData(
      loadingSize: 100,
    ),
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
