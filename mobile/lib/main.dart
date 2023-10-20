import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:mobile/common/route.dart';
import 'package:mobile/common/theme.dart';
import 'package:mobile/manage/config.dart';
import 'package:mobile/manage/notification.dart';
import 'package:mobile/page/home/index.dart';
import 'package:mobile/tool/network.dart';
import 'package:mobile/tool/tool.dart';

import 'model/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 下方设置系统主题，全局的配置/样式
  setupConfigTheme(
    config: JTechConfig(
      noPictureMode: true,
      noPlayerContent: true,
    ),
    themeData: JTechThemeData(),
    systemTheme: CustomTheme.dataMap,
  );
  // 初始化核心内容
  await ensureInitializedCore();
  // 初始化各种manage
  await platformConfig.init(); // 初始化平台配置
  await notice.init(); // 初始化消息通知
  // 强制竖屏
  setScreenOrientation(true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
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
  // 监听下载任务变化并弹出通知
  const noticeFlag = 9527;
  download.downloadProgress.listen((task) {
    if (task != null && task.downloadingMap.isNotEmpty) {
      final progress = task.totalRatio * 100;
      final totalCount = task.downloadingMap.length;
      final content = '(${progress.toStringAsFixed(1)}%)  正在下载 $totalCount 条视频';
      notice.showProgress(
        progress: progress.toInt(),
        indeterminate: false,
        maxProgress: 100,
        title: content,
        id: noticeFlag,
      );
      return;
    }
    notice.cancel(noticeFlag);
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
void setupConfigTheme({
  required JTechConfig config,
  required JTechThemeData themeData,
  required Map<Brightness, ThemeData> systemTheme,
}) {
  theme.setup(systemTheme);
  rootConfig.setup(config: config, theme: themeData);
  platformConfig.setup(config: config, theme: themeData);
}
