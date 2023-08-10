import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/manage/anime_parser/funtions.dart';
import 'package:jtech_anime/manage/anime_parser/model.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/source.dart';
import 'package:jtech_anime/model/database/video_cache.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/source.dart';
import 'package:jtech_anime/model/time_table.dart';

/*
* 解析器管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class AnimeParserManage extends BaseManage {
  // 当前选中的源缓存key
  static const String currentSourceKey = 'current_source';

  // 默认资源配置文件路径
  static const String defaultSourceConfigPath = 'assets/source/default.js';

  static final AnimeParserManage _instance = AnimeParserManage._internal();

  factory AnimeParserManage() => _instance;

  AnimeParserManage._internal();

  // 持有js运行时对象
  final _jsRuntime = getJavascriptRuntime();

  // 缓存当前所选数据源
  SourceConfig? _source;

  // 判断是否存在数据源
  bool get hasSource => _source != null;

  // 获取当前数据源
  SourceConfig? get currentSource => _source;

  @override
  Future<void> init() async {
    // 获取当前缓存的数据源
    _source = await _getSource();
    print('object');
  }

  // 切换数据源
  Future<bool> changeSource(SourceConfig source) async {
    if (_source?.key == source.key) return true;
    // 如果是默认配置则将缓存key置空
    final result = source.isDefault
        ? await cache.setString(currentSourceKey, source.key)
        : await cache.remove(currentSourceKey);
    // 如果修改成功则发送消息通知并替换当前数据源
    if (result) event.send(SourceChangeEvent(_source = source));
    return result;
  }

  // 获取数据源信息
  Future<AnimeSource?> getAnimeSource() async {
    if (_source == null) return null;
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromSource();
    final result = await _doJSFunction(content, request);
    return AnimeSource.from(jsonDecode(result));
  }

  // 获取番剧时间表
  Future<TimeTableModel?> getTimeTable() async {
    if (_source == null) return null;
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromTimeTable();
    final result = await _doJSFunction(content, request);
    return TimeTableModel.from(jsonDecode(result));
  }

  // 获取过滤条件列表
  Future<List<AnimeFilterModel>> loadFilterList() async {
    if (_source == null) return [];
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromFilter();
    final result = await _doJSFunction(content, request);
    return jsonDecode(result)
        .map<AnimeFilterModel>(AnimeFilterModel.from)
        .toList();
  }

  // 搜索番剧列表
  Future<List<AnimeModel>> searchAnimeList(String keyword,
      {int pageIndex = 1, int pageSize = 25}) async {
    if (_source == null) return [];
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromSearch(
        pageIndex: pageIndex, pageSize: pageSize, keyword: keyword);
    final result = await _doJSFunction(content, request);
    return jsonDecode(result).map<AnimeModel>(AnimeModel.from).toList();
  }

  // 获取首页番剧列表
  Future<List<AnimeModel>> loadHomeList({
    int pageIndex = 1,
    int pageSize = 25,
    Map<String, dynamic> filterSelect = const {},
  }) async {
    if (_source == null) return [];
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromHome(
        pageIndex: pageIndex, pageSize: pageSize, filterSelect: filterSelect);
    final result = await _doJSFunction(content, request);
    return jsonDecode(result).map<AnimeModel>(AnimeModel.from).toList();
  }

  // 获取详情页数据
  Future<AnimeModel?> getAnimeDetail(String animeUrl) async {
    if (_source == null) return null;
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromDetail(animeUrl: animeUrl);
    final result = await _doJSFunction(content, request);
    return AnimeModel.from(jsonDecode(result));
  }

  // 获取视频播放地址
  Future<List<VideoCache>> getPlayUrls(List<ResourceItemModel> items) async {
    if (_source == null) return [];
    final content = await _source!.content;
    final request = AnimeParserRequestModel.fromPlayUrl(
        resourceUrls: items.map((e) => e.url).toList());
    final result = await _doJSFunction(content, request);
    return jsonDecode(result).map<VideoCache>((e) {
      final url = e['url'];
      return VideoCache()
        ..url = url
        ..playUrl = e['playUrl']
        ..item = items.firstWhere((e) => e.url == url);
    }).toList();
  }

  // 加载数据源配置
  Future<SourceConfig?> _getSource() async {
    final key = cache.getString(currentSourceKey);
    if (key == null || key.isEmpty) return _getDefaultSource();
    final source = await db.getSourceConfig(key);
    return source ?? await _getDefaultSource();
  }

  // 加载默认数据源
  Future<SourceConfig?> _getDefaultSource() async {
    final content = await rootBundle.loadString('assets/source/default.js');
    if (content.isEmpty) return null;
    final request = AnimeParserRequestModel.fromSource();
    final result = await _doJSFunction(content, request);
    final source = AnimeSource.from(jsonDecode(result));
    return SourceConfig.fromContent(
      key: source.key,
      isDefault: true,
      content: content,
      name: source.name,
      logoUrl: source.logoUrl,
    );
  }

  // 执行js方法
  Future<String> _doJSFunction(
      String sourceCode, AnimeParserRequestModel request) async {
    final params = request.to();
    final result = await _jsRuntime.evaluateAsync('''
          $sourceCode 
          ${request.function.getCaseFunction(params)}
    ''');
    _jsRuntime.executePendingJob();
    return (await _jsRuntime.handlePromise(result)).stringResult;
  }
}

// 单例调用
final animeParser = AnimeParserManage();

/*
* 数据源切换事件
* @author wuxubaiyang
* @Time 2023/8/10 15:01
*/
class SourceChangeEvent extends EventModel {
  // 当前的数据源配置
  final SourceConfig source;

  SourceChangeEvent(this.source);
}
