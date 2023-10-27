import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
import 'common/custom.dart';
import 'common/route.dart';
import 'manage/config.dart';
import 'page/home/index.dart';

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
  // 初始化各种manage
  await platformConfig.init(); // 初始化平台配置
  // 强制竖屏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  // 设置沉浸式状态栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }
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
