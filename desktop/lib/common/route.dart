import 'package:desktop/page/detail/index.dart';
import 'package:desktop/page/home/index.dart';
import 'package:flutter/material.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 创建路由表
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
    animeDetail: (_) => const AnimeDetailPage(),
      };

  // 首页
  static const String home = '/home';

  // 番剧详情页
  static const String animeDetail = '/anime/detail';
}
