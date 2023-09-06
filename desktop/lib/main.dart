import 'package:desktop/common/route.dart';
import 'package:desktop/common/theme.dart';
import 'package:desktop/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化窗口管理
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    center: true,
    skipTaskbar: false,
    size: Size(800, 600),
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // 设置音量控制
  VolumeTool.setup();
  // 初始化视频播放器
  MediaKit.ensureInitialized();
  // 初始化ffmpeg
  await FFMpegHelper.instance.initialize();
  // 初始化各种manage
  await router.init(); // 路由服务
  await cache.init(); // 缓存服务
  await event.init(); // 事件服务
  await db.init(); // 数据库
  await download.init(); // 下载管理
  await animeParser.init(); // 番剧解析器
  // 监听解析源切换
  event.on<SourceChangeEvent>().listen((event) {
    // 暂停当前所有的下载任务
    download.stopAllTasks();
  });
  // 设置初始化样式
  theme.setup(CustomTheme.dataMap);
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
