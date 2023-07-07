import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/parser.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:html/parser.dart';

/*
* 樱花动漫网页解析器
* @author wuxubaiyang
* @Time 2023/7/6 10:19
*/
class YHDMZParserHandle extends ParserHandle {
  // 过滤条件附件地址
  final String _filterJson = "assets/filter/yhdmz.json";

  // 分页下标
  int _pageIndex = 0, _searchPageIndex = 0;

  @override
  Future<List<AnimeModel>> searchAnimeListNextPage(String keyword) async {
    try {
      final result = await searchAnimeList(
        keyword,
        params: {'pageindex': '${_searchPageIndex + 1}', 'pagesize': '24'},
      );
      _searchPageIndex += 1;
      return result;
    } catch (e) {
      LogTool.e('樱花动漫z番剧列表获取失败：', error: e);
    }
    return [];
  }

  @override
  Future<List<AnimeModel>> searchAnimeList(String keyword,
      {Map<String, dynamic> params = const {}}) async {
    try {
      if (!params.containsKey('pageindex')) _searchPageIndex = 0;
      final resp = await Dio().getUri(
        _getUri("/s_all", params: {'kw': keyword, ...params}),
        options: _options,
      );
      if (resp.statusCode == 200) {
        return _parseAnimeList(resp.data)
            .map<AnimeModel>((e) => AnimeModel.from(e))
            .toList();
      } else {
        throw Exception('樱花动漫z番剧列表获取失败：${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AnimeFilterModel>> loadFilterList() async {
    final json = await rootBundle.loadString(_filterJson);
    return jsonDecode(json)
        .map<AnimeFilterModel>((e) => AnimeFilterModel.from(e))
        .toList();
  }

  @override
  Future<List<AnimeModel>> loadAnimeListNextPage(
      {Map<String, dynamic> params = const {}}) async {
    try {
      final result = await loadAnimeList(
        params: {'pageindex': '${_pageIndex + 1}', 'pagesize': '24'},
      );
      _pageIndex += 1;
      return result;
    } catch (e) {
      LogTool.e('樱花动漫z番剧列表获取失败：', error: e);
    }
    return [];
  }

  @override
  Future<List<AnimeModel>> loadAnimeList(
      {Map<String, dynamic> params = const {}}) async {
    try {
      if (!params.containsKey('pageindex')) _pageIndex = 0;
      final resp = await Dio().getUri(
        _getUri("/list/", params: params),
        options: _options,
      );
      if (resp.statusCode == 200) {
        return _parseAnimeList(resp.data)
            .map<AnimeModel>((e) => AnimeModel.from(e))
            .toList();
      } else {
        throw Exception('樱花动漫z番剧列表获取失败：${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AnimeModel> getAnimeDetail(String url) async {
    try {
      final resp = await Dio().get(url, options: _options);
      if (resp.statusCode == 200) {
        return AnimeModel.from(_parseAnimeInfo(resp.data, url));
      } else {
        throw Exception('樱花动漫z番剧详情获取失败：${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ResourceItemModel>> getAnimePlayUrl(List<ResourceItemModel> items,
      {ParserProgressCallback? progress}) async {
    final result = <ResourceItemModel>[];
    for (final it in items) {
      try {
        var playUrl = await db.getCachePlayUrl(it.url);
        playUrl ??= await parseByHeadlessBrowser<String?>(it.url, (doc) {
          final path = doc.querySelector('iframe')?.attributes['src'];
          if (path == null) return path;
          return Uri.parse(path).queryParameters['url'];
        });
        if (playUrl == null) continue;
        result.add(ResourceItemModel.from({
          'name': it.name,
          'url': playUrl,
        }));
        progress?.call(result.length, items.length);
        await db.cachePlayUrl(it.url, playUrl);
      } catch (e) {
        LogTool.e('视频播放地址转换失败：', error: e);
      }
    }
    return result;
  }

  // 解析番剧列表
  Stream<Map> _parseAnimeList(String html) async* {
    final document = parse(html);
    for (final li in document.querySelectorAll(
        'body > div:nth-child(7) > div.fire.l > div.lpic > ul > li')) {
      yield {
        'name': li.querySelector('h2 > a')?.text,
        'cover':
            li.querySelector('li:nth-child(1) > a > img')?.attributes['src'],
        'status': li.querySelector('span > font')?.text,
        'types': li
            .querySelector('span:nth-child(7)')
            ?.text
            .replaceAll('类型：', '')
            .split(' '),
        'intro': li.querySelector('p')?.text,
        'url': _getUri(
                li.querySelector('a:nth-child(1)')?.attributes['href'] ?? '')
            .toString(),
      };
    }
  }

  // 解析番剧详情信息
  Map _parseAnimeInfo(String html, String url) {
    final document = parse(html);
    final info = document
        .querySelector('body > div:nth-child(3) > div.fire.l > div.rate.r');
    return {
      'url': url,
      'name': info?.querySelector('h1')?.text,
      'cover': document
          .querySelector(
              'body > div:nth-child(3) > div.fire.l > div.thumb.l > img')
          ?.attributes['src'],
      'updateTime': info
          ?.querySelector('div.sinfo > span')
          ?.text
          .replaceAll(RegExp(r'\n|上映:'), '')
          .trim(),
      'region': info?.querySelector('div.sinfo > span:nth-child(5) > a')?.text,
      'types': info
          ?.querySelectorAll('div.sinfo > span:nth-child(7) > a')
          .map((e) => e.text)
          .toList(),
      'status': info?.querySelector('div.sinfo > p:nth-child(13)')?.text,
      'intro': document
          .querySelector('body > div:nth-child(3) > div.fire.l > div.info')
          ?.text,
      'resources': document
          .querySelectorAll('#main0 > div.movurl')
          .map((e) => e
              .querySelectorAll('ul > li > a')
              .map((e) => {
                    'name': e.text,
                    'url': _getUri(e.attributes['href'] ?? '').toString(),
                  })
              .toList())
          .where((e) => e.isNotEmpty)
          .toList(),
    };
  }

  // 获取访问地址
  Uri _getUri(
    String path, {
    Map<String, dynamic>? params,
  }) {
    return Uri(
      scheme: "https",
      host: "www.yhdmz.org",
      path: path,
      queryParameters: params,
    );
  }

  // 获取请求配置
  Options get _options => Options(
        headers: {
          "Host": "www.yhdmz.org",
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.67",
        },
        contentType: 'text/html; charset=utf-8',
        responseType: ResponseType.plain,
      );
}
