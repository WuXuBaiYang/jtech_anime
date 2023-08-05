import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_meedu_videoplayer/init_meedu_player.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/localization/chinese_cupertino_localizations.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/download.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/manage/notification.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/page/home/index.dart';
import 'package:jtech_anime/widget/stream_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化视频播放器
  await initMeeduPlayer(androidUseMediaKit: false);
  // 初始化ffmpeg
  await FFMpegHelper.instance.initialize();
  // 初始化各种manage
  await router.init(); // 路由服务
  await cache.init(); // 缓存服务
  await event.init(); // 事件服务
  await db.init(); // 数据库
  await download.init(); // 下载管理
  await notice.init(); // 消息通知
  // 设置沉浸式状态栏
  if (Platform.isAndroid) {
    AndroidInAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }
  // 监听网络状态变化
  Connectivity().onConnectivityChanged.listen((status) async {
    // 当网络状态切换为流量时，则判断是否需要暂停所有下载任务
    if (status == ConnectivityResult.mobile) {
      if (cache.getBool(Common.checkNetworkStatusKey) ?? true) {
        // 只暂停当前资源下的所有下载任务，切换资源的时候则会暂停全部任务
        final records = await db.getDownloadRecordList(
          parserHandle.currentSource,
          status: [DownloadRecordStatus.download],
        );
        await download.stopTasks(records);
      }
    }
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
