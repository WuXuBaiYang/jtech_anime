import 'dart:async';

import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/parser.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/parser/yhdmz.dart';

/*
* 解析器管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ParserHandleManage extends BaseManage with ParserHandle {
  static final ParserHandleManage _instance = ParserHandleManage._internal();

  factory ParserHandleManage() => _instance;

  ParserHandleManage._internal();

  @override
  Future<AnimeModel> getAnimeDetail(String url) =>
      _currentHandler.getAnimeDetail(url);

  @override
  Future<List<ResourceItemModel>> getAnimePlayUrl(List<ResourceItemModel> items,
          {ParserProgressCallback? progress}) =>
      _currentHandler.getAnimePlayUrl(items, progress: progress);

  @override
  Future<List<AnimeModel>> loadAnimeList(
          {Map<String, dynamic> params = const {}}) =>
      _currentHandler.loadAnimeList(params: params);

  @override
  Future<List<AnimeModel>> loadAnimeListNextPage(
          {Map<String, dynamic> params = const {}}) =>
      _currentHandler.loadAnimeListNextPage(params: params);

  @override
  Future<List<List<TimeTableItemModel>>> loadAnimeTimeTable() =>
      _currentHandler.loadAnimeTimeTable();

  @override
  Future<List<AnimeFilterModel>> loadFilterList() =>
      _currentHandler.loadFilterList();

  @override
  Future<List<AnimeModel>> searchAnimeList(String keyword,
          {Map<String, dynamic> params = const {}}) =>
      _currentHandler.searchAnimeList(keyword, params: params);

  @override
  Future<List<AnimeModel>> searchAnimeListNextPage(String keyword) =>
      _currentHandler.searchAnimeListNextPage(keyword);

  // 获取过滤条件配置缓存
  Map<String, dynamic>? get filterConfig => cache.getJson(_filterCacheKey);

  // 缓存过滤条件配置
  void cacheFilterConfig(Map<String, dynamic> config) =>
      cache.setJsonMap(_filterCacheKey, config);

  // 获取过滤条件配置缓存key
  String get _filterCacheKey => 'filter_cache_${currentSource.name}';

  // 解析源
  ParserSource? _source;

  // 获取当前解析源
  ParserSource get currentSource => _source ??= ParserSource.yhdmz;

  // 解析器
  ParserHandle? _handler;

  // 获取当前解析器
  ParserHandle get _currentHandler => _handler ??= currentSource.handle;

  // 切换解析源
  void switchSource(ParserSource source) {
    event.send(ParserSourceEvent(source));
    _handler = source.handle;
    _source = source;
  }
}

// 单例调用
final parserHandle = ParserHandleManage();

// 解析源枚举
enum ParserSource {
  // 樱花动漫z
  yhdmz,
}

// 解析源美剧扩展
extension ParserSourceExtension on ParserSource {
  // 获取中文名
  String get nameCN => {
        ParserSource.yhdmz: '樱花动漫z',
      }[this]!;

  // 获取解析源
  ParserHandle get handle => {
        ParserSource.yhdmz: YHDMZParserHandle(),
      }[this]!;
}

// 解析源事件
class ParserSourceEvent extends EventModel {
  // 解析源
  final ParserSource source;

  ParserSourceEvent(this.source);
}
