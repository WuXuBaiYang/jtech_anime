import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/parser.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/model/database/video_cache.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:html/parser.dart';

/*
* 樱花动漫网页解析器
* @author wuxubaiyang
* @Time 2023/7/6 10:19
*/
class YHDMZParserHandle extends ParserHandle {
  // 过滤条件附件地址
  final String _filterJson = 'assets/filter/yhdmz.json';

  // 分页下标
  int _pageIndex = 0, _searchPageIndex = 0;

  @override
  Future<List<List<TimeTableItemModel>>> loadAnimeTimeTable() async {
    try {
      final resp = await Dio().getUri(_getUri(null), options: _options);
      if (resp.statusCode == 200) {
        return _parseAnimeTimeTable(resp.data)
            .map<List<TimeTableItemModel>>((e) => e
                .map<TimeTableItemModel>((e) => TimeTableItemModel.from(e))
                .toList())
            .toList();
      } else {
        throw Exception('樱花动漫z番剧时间表获取失败：${resp.statusCode}');
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
        params: {
          'pageindex': '${_pageIndex + 1}',
          'pagesize': '24',
          ...params,
        },
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
        _getUri('/list/', params: params),
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
  Future<List<AnimeModel>> searchAnimeList(String keyword,
      {Map<String, dynamic> params = const {}}) async {
    try {
      if (!params.containsKey('pageindex')) _searchPageIndex = 0;
      final resp = await Dio().getUri(
        _getUri('/s_all', params: {'kw': keyword, ...params}),
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
  Future<List<VideoCache>> getAnimeVideoCache(List<ResourceItemModel> items,
      {ParserProgressCallback? progress}) async {
    final result = <VideoCache>[];
    for (final it in items) {
      try {
        var playUrl = await db.getCachePlayUrl(it.url);
        playUrl ??= await parseByHeadlessBrowser<String?>(it.url, (doc) {
          final path = doc.querySelector('iframe')?.attributes['src'];
          if (path == null) return path;
          return Uri.parse(path).queryParameters['url'];
        });
        if (playUrl == null || playUrl.isEmpty) continue;
        result.add(VideoCache()
          ..url = it.url
          ..playUrl = playUrl);
        progress?.call(result.length, items.length);
        await db.cachePlayUrl(it.url, playUrl);
      } catch (e) {
        LogTool.e('视频播放地址转换失败：', error: e);
      }
    }
    return result;
  }

  // 解析番剧时间表
  Stream<List<Map>> _parseAnimeTimeTable(String html) async* {
    final document = parse(html);
    final uls = document.querySelectorAll(
        'body > div.area > div.side.r > div.bg > div.tlist > ul');
    for (final ul in uls) {
      final temp = <Map>[];
      for (final li in ul.querySelectorAll('li')) {
        final status = li.querySelectorAll('a').first.text;
        temp.add({
          'name': li.querySelectorAll('a').last.text,
          'url': _getUri(li.querySelectorAll('a').last.attributes['href'])
              .toString(),
          'status': status.replaceAll('new', '').trim(),
          'isUpdate': status.contains('new'),
        });
      }
      yield temp;
    }
  }

  // 解析番剧列表
  Stream<Map> _parseAnimeList(String html) async* {
    final document = parse(html);
    for (final li in document.querySelectorAll(
        'body > div:nth-child(7) > div.fire.l > div.lpic > ul > li')) {
      var cover = li.querySelector('li > a > img')?.attributes['src'];
      if (cover?.startsWith('//') ?? false) {
        cover = 'https:$cover';
      }
      yield {
        'name': li.querySelector('h2 > a')?.text,
        'cover': cover,
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
    var cover = document
        .querySelector(
            'body > div:nth-child(3) > div.fire.l > div.thumb.l > img')
        ?.attributes['src'];
    if (cover?.startsWith('//') ?? false) {
      cover = 'https:$cover';
    }
    return {
      'url': url,
      'name': info?.querySelector('h1')?.text,
      'cover': cover,
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
    String? path, {
    Map<String, dynamic>? params,
  }) {
    return Uri(
      scheme: 'https',
      host: 'www.yhdmz.org',
      path: path,
      queryParameters: params,
    );
  }

  // 获取请求配置
  Options get _options => Options(
        headers: {
          'Host': 'www.yhdmz.org',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.67',
        },
        contentType: 'text/html; charset=utf-8',
        responseType: ResponseType.plain,
      );
}
