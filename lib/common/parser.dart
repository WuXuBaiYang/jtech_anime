import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter.dart';

// 进度回调
typedef ParserProgressCallback = void Function(int count, int total);

/*
* 网页解析器基类
* @author wuxubaiyang
* @Time 2023/7/6 10:19
*/
abstract mixin class ParserHandle {
  // 搜索番剧列表下一页
  Future<List<AnimeModel>> searchAnimeListNextPage(String keyword);

  // 搜索番剧列表
  Future<List<AnimeModel>> searchAnimeList(String keyword,
      {Map<String, dynamic> params = const {}});

  // 获取过滤列表
  Future<List<AnimeFilterModel>> loadFilterList();

  // 获取番剧列表下一页
  Future<List<AnimeModel>> loadAnimeListNextPage(
      {Map<String, dynamic> params = const {}});

  // 获取番剧列表
  Future<List<AnimeModel>> loadAnimeList(
      {Map<String, dynamic> params = const {}});

  // 获取视频详情
  Future<AnimeModel> getAnimeDetail(String url);

  // 获取视频播放地址
  Future<List<ResourceItemModel>> getAnimePlayUrl(List<ResourceItemModel> items,
      {ParserProgressCallback? progress});
}
