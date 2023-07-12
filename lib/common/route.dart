import 'package:flutter/material.dart';
import 'package:jtech_anime/page/collect/index.dart';
import 'package:jtech_anime/page/detail/index.dart';
import 'package:jtech_anime/page/download/index.dart';
import 'package:jtech_anime/page/history/index.dart';
import 'package:jtech_anime/page/home/index.dart';
import 'package:jtech_anime/page/player/index.dart';
import 'package:jtech_anime/page/search/index.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 创建路由表
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
        search: (_) => const SearchPage(),
        player: (_) => const PlayerPage(),
        collect: (_) => const CollectPage(),
        history: (_) => const HistoryPage(),
        download: (_) => const DownloadPage(),
        animeDetail: (_) => const AnimeDetailPage(),
      };

  // 首页
  static const String home = '/home';

  // 搜索页
  static const String search = '/search';

  // 播放器页
  static const String player = '/player';

  // 收藏页
  static const String collect = '/collect';

  // 历史记录页
  static const String history = '/history';

  // 下载管理页
  static const String download = '/download';

  // 动漫详情页
  static const String animeDetail = '/anime/detail';
}
