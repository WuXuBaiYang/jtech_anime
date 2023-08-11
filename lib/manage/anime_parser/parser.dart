import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:jtech_anime/common/common.dart';
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
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/tool.dart';

/*
* 解析器管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class AnimeParserManage extends BaseManage {
  // 当前选中的源缓存key
  static const String currentSourceKey = 'current_source';

  // 默认资源配置文件路径
  static const String defaultSourceConfigPath = 'assets/source/default.json';

  static final AnimeParserManage _instance = AnimeParserManage._internal();

  factory AnimeParserManage() => _instance;

  AnimeParserManage._internal();

  // 持有js运行时对象
  final _jsRuntime = getJavascriptRuntime();

  // 缓存当前所选数据源
  AnimeSource? _source;

  // 判断是否存在数据源
  bool get hasSource => _source != null;

  // 获取当前数据源
  AnimeSource? get currentSource => _source;

  // 缓存解析文件内容
  String? _parserFileContent;

  // 读取解析文件内容
  Future<String?> _readParserFileContent() async {
    final fileUri = _source?.fileUri;
    if (fileUri == null) return null;
    if (fileUri.startsWith('asset')) {
      // 如果是assets文件则需要从assets中读取
      return _parserFileContent ??= await rootBundle.loadString(fileUri);
    }
    // 默认其他都为本地file
    return _parserFileContent ??= await File(fileUri).readAsString();
  }

  @override
  Future<void> init() async {
    // 获取当前缓存的数据源
    _source = await _getSource();
  }

  // 切换数据源
  Future<bool> changeSource(AnimeSource source) async {
    if (_source?.key == source.key) return true;
    // 如果是默认配置则将缓存key置空
    final result = await cache.setString(currentSourceKey, source.key);
    if (!result) return result;
    // 如果修改成功则发送消息通知并替换当前数据源
    event.send(SourceChangeEvent(source));
    _parserFileContent = null;
    _source = source;
    return result;
  }

  // 获取番剧时间表
  Future<TimeTableModel?> getTimeTable() async {
    final content = await _readParserFileContent();
    if (content == null) return null;
    final request = AnimeParserRequestModel.fromTimeTable();
    final result = await _doJSFunction(content, request);
    return TimeTableModel.from(jsonDecode(result));
  }

  // 获取过滤条件列表
  Future<List<AnimeFilterModel>> loadFilterList() async {
    final content = await _readParserFileContent();
    if (content == null) return [];
    final request = AnimeParserRequestModel.fromFilter();
    final result = await _doJSFunction(content, request);
    return jsonDecode(result)
        .map<AnimeFilterModel>(AnimeFilterModel.from)
        .toList();
  }

  // 搜索番剧列表
  Future<List<AnimeModel>> searchAnimeList(String keyword,
      {int pageIndex = 1, int pageSize = 25}) async {
    final content = await _readParserFileContent();
    if (content == null) return [];
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
    final content = await _readParserFileContent();
    if (content == null) return [];
    final request = AnimeParserRequestModel.fromHome(
        pageIndex: pageIndex, pageSize: pageSize, filterSelect: filterSelect);
    final result = await _doJSFunction(content, request);
    return jsonDecode(result).map<AnimeModel>(AnimeModel.from).toList();
  }

  // 获取详情页数据
  Future<AnimeModel?> getAnimeDetail(String animeUrl) async {
    final content = await _readParserFileContent();
    if (content == null) return null;
    final request = AnimeParserRequestModel.fromDetail(animeUrl: animeUrl);
    final result = await _doJSFunction(content, request);
    return AnimeModel.from(jsonDecode(result));
  }

  // 获取视频播放地址
  Future<List<VideoCache>> getPlayUrls(List<ResourceItemModel> items) async {
    final content = await _readParserFileContent();
    if (content == null) return [];
    final request = AnimeParserRequestModel.fromPlayUrl(
        resourceUrls: items.map((e) => e.url).toList());
    final result = await _doJSFunction(content, request);
    return jsonDecode(result).map<VideoCache>((e) {
      final item = items.firstWhere(
        (it) => it.url == e['url'],
      );
      return VideoCache.from(e, item);
    }).toList();
  }

  // 将配置文件信息导入数据库
  Future<AnimeSource?> importAnimeSource(AnimeSource source) async {
    try {
      String? fileUri = source.fileUri;
      // 如果是在线文件地址，则将文件下载下来并存储到本地
      if (fileUri.startsWith('http')) {
        final resp = await Dio().get(fileUri);
        if (resp.statusCode != 200) return null;
        final localFile = await _writeAnimeParserFile(source, resp.data);
        if (localFile == null) return null;
        fileUri = localFile.path;
      } else if (fileUri.startsWith('asset')) {
        // 如果是assets文件，则将文件复制到本地
        final result = await rootBundle.loadString(fileUri);
        final localFile = await _writeAnimeParserFile(source, result);
        if (localFile == null) return null;
        fileUri = localFile.path;
      }
      // 将本地文件路径写入到数据库
      return db.updateAnimeSource(source..fileUri = fileUri);
    } catch (e) {
      LogTool.e('配置文件解析失败', error: e);
    }
    return null;
  }

  // 将解析js写入本地
  Future<File?> _writeAnimeParserFile(
      AnimeSource source, String content) async {
    final savePath = await FileTool.getDirPath(FileDirPath.animeParserCachePath,
        root: FileDir.applicationDocuments);
    if (savePath == null) return null;
    final file = File('$savePath/${Tool.md5(source.fileUri)}.js');
    return await file.writeAsString(content);
  }

  // 加载数据源配置
  Future<AnimeSource?> _getSource() async {
    final key = cache.getString(currentSourceKey);
    if (key == null || key.isEmpty) return _getDefaultSource();
    final source = await db.getAnimeSource(key);
    return source ?? await _getDefaultSource();
  }

  // 加载默认数据源
  Future<AnimeSource?> _getDefaultSource() async {
    final sourceConfig = await rootBundle.loadString(defaultSourceConfigPath);
    if (sourceConfig.isEmpty) return null;
    AnimeSource? source = AnimeSource.from(jsonDecode(sourceConfig));
    final dbSource = await db.getAnimeSource(source.key);
    if (dbSource != null) return dbSource;
    return importAnimeSource(source);
  }

  // 执行js方法
  Future<String> _doJSFunction(
      String sourceCode, AnimeParserRequestModel request) async {
    final params = request.to();
    final function = request.function.getCaseFunction(params);
    final result = await _jsRuntime.evaluateAsync('''
          $sourceCode
          async function doJSFunction() {
              let result = await $function
              return JSON.stringify(result)
          }
          doJSFunction()
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
  final AnimeSource source;

  SourceChangeEvent(this.source);
}