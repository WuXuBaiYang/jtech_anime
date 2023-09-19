import 'package:desktop/page/detail/index.dart';
import 'package:desktop/page/home/index.dart';
import 'package:desktop/page/player/index.dart';
import 'package:desktop/page/source/index.dart';
import 'package:flutter/material.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 路由表
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
        player: (_) => const PlayerPage(),
        animeDetail: (_) => const AnimeDetailPage(),
        animeSource: (_) => const AnimeSourcePage(),
      };

  // 首页
  static const String home = '/home';

  // 番剧详情页
  static const String animeDetail = '/anime/detail';

  // 播放器页
  static const String player = '/player';

  // 番剧解析源管理页
  static const String animeSource = 'anime/source';
}
