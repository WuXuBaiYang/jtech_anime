import 'package:flutter/material.dart';
import 'package:jtech_anime/page/home/index.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 创建路由表
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
      };

  // 首页
  static const String home = '/home';
}
