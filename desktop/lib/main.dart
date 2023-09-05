import 'package:desktop/common/route.dart';
import 'package:desktop/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime/library.dart';
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
  // 监听网络状态变化
  Connectivity().onConnectivityChanged.listen((status) async {
    // 当网络状态切换为流量时，则判断是否需要暂停所有下载任务
    if (status == ConnectivityResult.mobile) {
      if (cache.getBool(Common.checkNetworkStatusKey) ?? true) {
        // 只暂停当前资源下的所有下载任务，切换资源的时候则会暂停全部任务
        final source = animeParser.currentSource;
        if (source == null) return;
        final records = await db.getDownloadRecordList(source,
            status: [DownloadRecordStatus.download]);
        await download.stopTasks(records);
      }
    }
  });
  // 监听解析源切换
  event.on<SourceChangeEvent>().listen((event) {
    // 暂停当前所有的下载任务
    download.stopAllTasks();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeStreamView(
      builder: (c, snap) => MaterialApp(
        title: Common.appName,
        theme: snap.data?.data,
        navigatorKey: router.navigateKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: router.onGenerateRoute(
          routesMap: RoutePath.routes,
        ),
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          ChineseCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        home: const HomePage(),
      ),
    );
  }
}
