import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/localization/chinese_cupertino_localizations.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/manage/notification/notification.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/page/home/index.dart';
import 'package:jtech_anime/widget/stream_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化各种manage
  await router.init(); // 路由服务
  await notice.init(); // 通知服务
  await cache.init(); // 缓存服务
  await event.init(); // 事件服务
  // 设置沉浸式状态栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }
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
        debugShowCheckedModeBanner: false,
        navigatorKey: router.navigateKey,
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
