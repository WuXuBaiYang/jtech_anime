import 'package:flutter/material.dart';
import 'package:mobile/page/collect/index.dart';
import 'package:mobile/page/detail/index.dart';
import 'package:mobile/page/download/index.dart';
import 'package:mobile/page/home/index.dart';
import 'package:mobile/page/player/index.dart';
import 'package:mobile/page/record/index.dart';
import 'package:mobile/page/search/index.dart';
import 'package:mobile/page/source/index.dart';

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
        record: (_) => const PlayRecordPage(),
        download: (_) => const DownloadPage(),
        animeDetail: (_) => const AnimeDetailPage(),
        animeSource: (_) => const AnimeSourcePage(),
      };

  // 首页
  static const String home = '/home';

  // 搜索页
  static const String search = '/search';

  // 播放器页
  static const String player = '/player';

  // 收藏页
  static const String collect = '/collect';

  // 播放记录页
  static const String record = '/record';

  // 下载管理页
  static const String download = '/download';

  // 动漫详情页
  static const String animeDetail = '/anime/detail';

  // 番剧解析源管理页
  static const String animeSource = 'anime/source';
}
