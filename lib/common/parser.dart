import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/time_table.dart';

// 进度回调
typedef ParserProgressCallback = void Function(int count, int total);

/*
* 网页解析器基类
* @author wuxubaiyang
* @Time 2023/7/6 10:19
*/
abstract mixin class ParserHandle {
  // 获取番剧时间表(下标0从周一开启计算)
  Future<List<List<TimeTableItemModel>>> loadAnimeTimeTable();

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

  // 无头浏览器
  HeadlessInAppWebView? _headlessWebView;

  // 无头浏览器控制器
  InAppWebViewController? _headlessWebViewController;

  // 创建无头浏览器并发起请求，在请求完成之后获取数据
  Future<T?> parseByHeadlessBrowser<T>(
      String url, T Function(Document document) handle) async {
    if (_headlessWebView == null) {
      final completer = Completer<T?>();
      _headlessWebView ??= HeadlessInAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        onWebViewCreated: (c) async {
          _headlessWebViewController = c;
          completer.complete(parseByHeadlessBrowser(url, handle));
        },
      )..run();
      return completer.future;
    }
    // 请求目标网址并获取解析结果
    await _headlessWebViewController?.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(url)));
    final html = await _headlessWebViewController?.getHtml();
    if (html == null) return null;
    return handle(parse(html));
  }
}
