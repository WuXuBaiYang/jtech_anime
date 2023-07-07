import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
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

  // 无头浏览器
  HeadlessInAppWebView? _headlessWebView;

  // 无头浏览器控制器
  InAppWebViewController? _headlessWebViewController;

  // 创建无头浏览器并发起请求，在请求完成之后获取数据
  Future<T?> parseByHeadlessBrowser<T>(
      String url, T Function(Document document) handle) async {
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
        completer.complete(await parseByHeadlessBrowser(url, handle));
      },
      onLoadStop: (c, url) async {
        final html = await _headlessWebViewController!.getHtml();
        completer.complete(html != null ? handle(parse(html)) : null);
      },
    )..run();
    _headlessWebViewController?.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(url)));
    return completer.future;
  }
}
