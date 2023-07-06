import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/parser.dart';
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
  Future<List<AnimeModel>> searchAnimeListNextPage(String keyword) {}

  @override
  Future<List<AnimeModel>> searchAnimeList(String keyword,
      {Map<String, dynamic> params = const {}}) async {
    try {
      if (!params.containsKey('pageindex')) _searchPageIndex = 0;
      final resp = await Dio().getUri(
        _getUri("/s_all", params: params),
        options: _options,
      );
      if (resp.statusCode == 200) {
        final document = parse(resp.data);
        final result = <AnimeModel>[];
        for (final li in document.querySelectorAll(
            'body > div:nth-child(7) > div.fire.l > div.lpic > ul > li')) {
          final name = li.querySelector('h2 > a')?.text;
          final cover =
              li.querySelector('li:nth-child(1) > a > img')?.attributes['src'];
          final status = li.querySelector('span > font')?.text;
          final types = li
              .querySelector('span:nth-child(7)')
              ?.text
              .replaceAll('类型：', '')
              .split(' ');
          final intro = li.querySelector('p')?.text;
          final path = li.querySelector('a:nth-child(1)')?.attributes['href'];
          result.add(AnimeModel(
            name: name ?? '',
            cover: cover ?? '',
            status: status ?? '',
            types: types ?? [],
            intro: intro ?? '',
            url: _getUri(path ?? '').toString(),
          ));
          // break;
        }
        return result;
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
        final document = parse(resp.data);
        final result = <AnimeModel>[];
        for (final li in document.querySelectorAll(
            'body > div:nth-child(7) > div.fire.l > div.lpic > ul > li')) {
          final name = li.querySelector('h2 > a')?.text;
          final cover =
              li.querySelector('li:nth-child(1) > a > img')?.attributes['src'];
          final status = li.querySelector('span > font')?.text;
          final types = li
              .querySelector('span:nth-child(7)')
              ?.text
              .replaceAll('类型：', '')
              .split(' ');
          final intro = li.querySelector('p')?.text;
          final path = li.querySelector('a:nth-child(1)')?.attributes['href'];
          result.add(AnimeModel(
            name: name ?? '',
            cover: cover ?? '',
            status: status ?? '',
            types: types ?? [],
            intro: intro ?? '',
            url: _getUri(path ?? '').toString(),
          ));
          // break;
        }
        return result;
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
        final document = parse(resp.data);
        final info = document
            .querySelector('body > div:nth-child(3) > div.fire.l > div.rate.r');
        final name = info?.querySelector('h1')?.text;
        final cover = document
            .querySelector(
                'body > div:nth-child(3) > div.fire.l > div.thumb.l > img')
            ?.attributes['src'];
        final updateTime = info
            ?.querySelector('div.sinfo > span')
            ?.text
            .replaceAll(RegExp(r'\n|上映:'), '')
            .trim();
        final region =
            info?.querySelector('div.sinfo > span:nth-child(5) > a')?.text;
        final types = info
            ?.querySelectorAll('div.sinfo > span:nth-child(7) > a')
            .map((e) => e.text)
            .toList();
        final status = info?.querySelector('div.sinfo > p:nth-child(13)')?.text;
        final intro = document
            .querySelector('body > div:nth-child(3) > div.fire.l > div.info')
            ?.text;
        final resources = <List<ResourceItemModel>>[];
        for (final it in document.querySelectorAll('#main0 > div.movurl')) {
          final items = it
              .querySelectorAll('ul > li > a')
              .map((e) => ResourceItemModel(
                    name: e.text,
                    url: _getUri(e.attributes['href'] ?? '').toString(),
                  ))
              .toList();
          if (items.isNotEmpty) resources.add(items);
        }
        return AnimeModel(
          name: name ?? '',
          cover: cover ?? '',
          updateTime: updateTime ?? '',
          region: region ?? '',
          types: types ?? [],
          status: status ?? '',
          url: url,
          intro: intro ?? '',
          resources: resources,
        );
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
        final resp = await Dio().get(it.url, options: _options);
        if (resp.statusCode == 200) {
          final document = parse(resp.data);
          final url = document.querySelector('#yh_playfram');
          result.add(ResourceItemModel(
            name: it.name,
            url: '',
          ));
          progress?.call(result.length, items.length);
        }
      } catch (_) {
        print(_.toString());
      }
    }
    return result;
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
