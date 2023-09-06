import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/common/theme.dart';
import 'package:jtech_anime/manage/notification.dart';
import 'package:jtech_anime/page/home/index.dart';
import 'package:jtech_anime/tool/network.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime_base/base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 是否启用无图模式
  ImageView.noPictureMode = false;
  // 设置音量控制
  VolumeTool.setup();
  // 初始化视频播放器
  MediaKit.ensureInitialized();
  // 强制竖屏
  setScreenOrientation(true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  // 初始化ffmpeg
  await FFMpegHelper.instance.initialize();
  // 初始化各种manage
  await router.init(); // 路由服务
  await cache.init(); // 缓存服务
  await event.init(); // 事件服务
  await db.init(); // 数据库
  await download.init(); // 下载管理
  await notice.init(); // 消息通知
  await animeParser.init(); // 番剧解析器
  // 设置沉浸式状态栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }
  // 监听网络状态变化
  Connectivity().onConnectivityChanged.listen((status) async {
    // 当网络状态切换为流量时，则判断是否需要暂停所有下载任务
    if (status == ConnectivityResult.mobile) {
      if (cache.getBool(Network.checkNetworkStatusKey) ?? true) {
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
