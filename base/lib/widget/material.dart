import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jtech_anime_base/common/common.dart';
import 'package:jtech_anime_base/common/localization/chinese_cupertino_localizations.dart';
import 'package:jtech_anime_base/manage/router.dart';
import 'stream_view.dart';

/*
* 自定义material入口
* @author wuxubaiyang
* @Time 2023/9/6 12:01
*/
class CustomMaterialApp extends StatelessWidget {
  // 路由表
  final Map<String, WidgetBuilder> routesMap;

  // 首页
  final Widget? home;

  const CustomMaterialApp({
    super.key,
    this.routesMap = const {},
    this.home,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeStreamView(
      builder: (_, snap) => MaterialApp(
        title: Common.appName,
        theme: snap.data?.data,
        navigatorKey: router.navigateKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: router.onGenerateRoute(
          routesMap: routesMap,
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
        home: home,
      ),
    );
  }
}
