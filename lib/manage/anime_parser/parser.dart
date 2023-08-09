import 'package:jtech_anime/common/manage.dart';

/*
* 解析器管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class AnimeParserManage extends BaseManage {
  static final AnimeParserManage _instance = AnimeParserManage._internal();

  factory AnimeParserManage() => _instance;

  AnimeParserManage._internal();
}

// 单例调用
final animeParser = AnimeParserManage();
