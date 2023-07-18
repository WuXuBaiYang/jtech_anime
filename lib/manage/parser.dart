import 'dart:async';

import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/parser.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/model/database/video_cache.dart';
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

  // 解析器对照表(新增解析器请放到这里)
  final _handlerMap = {
    // 樱花动漫
    'yhdmz': YHDMZParserHandle(),
  };

  // 解析源
  String? _source;

  // 获取当前解析源(默认使用樱花动漫)
  String get currentSource => _source ??= 'yhdmz';

  // 解析器
  ParserHandle? _handler;

  // 获取当前解析器
  ParserHandle get _currentHandler => _handler ??= _handlerMap[_source]!;

  // 切换解析源
  void switchSource(String source) {
    event.send(AnimeSourceEvent(source));
    _source = source;
    _handler = null;
  }

  @override
  Future<AnimeModel> getAnimeDetail(String url) =>
      _currentHandler.getAnimeDetail(url);

  @override
  Future<List<VideoCache>> getAnimeVideoCache(List<ResourceItemModel> items,
          {ParserProgressCallback? progress}) =>
      _currentHandler.getAnimeVideoCache(items, progress: progress);

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
}

// 单例调用
final parserHandle = ParserHandleManage();

// 解析源事件
class AnimeSourceEvent extends EventModel {
  // 解析源
  final String source;

  AnimeSourceEvent(this.source);
}
