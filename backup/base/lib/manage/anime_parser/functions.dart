import 'dart:convert';

/*
* 解析方法枚举
* @author wuxubaiyang
* @Time 2023/8/9 17:23
*/
enum AnimeParserFunction {
  // 番剧时间表
  timeTable,
  // 搜索（支持分页）
  search,
  // 过滤条件（用在首页数据上）
  filter,
  // 首页数据列表（支持分页）
  home,
  // 详情
  detail,
  // 获取视频真实播放地址
  playUrl,
  // 详情页推荐列表
  recommend,
}

/*
* 解析方法枚举扩展
* @author wuxubaiyang
* @Time 2023/8/9 17:30
*/
extension AnimeParserFunctionExtension on AnimeParserFunction {
  // 获取方法中文名
  String get functionNameCN => {
        AnimeParserFunction.timeTable: '番剧时间表',
        AnimeParserFunction.filter: '过滤条件',
        AnimeParserFunction.search: '搜索',
        AnimeParserFunction.home: '番剧列表',
        AnimeParserFunction.detail: '番剧详情',
        AnimeParserFunction.playUrl: '视频解析',
        AnimeParserFunction.recommend: '相关推荐',
      }[this]!;

  // 获取方法名
  String get functionName => {
        AnimeParserFunction.timeTable: 'getTimeTable',
        AnimeParserFunction.filter: 'loadFilterList',
        AnimeParserFunction.search: 'searchAnimeList',
        AnimeParserFunction.home: 'loadHomeList',
        AnimeParserFunction.detail: 'getAnimeDetail',
        AnimeParserFunction.playUrl: 'getPlayUrls',
        AnimeParserFunction.recommend: 'loadRecommendList',
      }[this]!;

  // 判断方法是否为必须
  bool get required => {
        AnimeParserFunction.timeTable: false,
        AnimeParserFunction.filter: false,
        AnimeParserFunction.search: false,
        AnimeParserFunction.home: true,
        AnimeParserFunction.detail: true,
        AnimeParserFunction.playUrl: true,
        AnimeParserFunction.recommend: false,
      }[this]!;

  // 拼装方法请求
  String getCaseFunction(Map<String, dynamic> params) => {
        AnimeParserFunction.timeTable: (params) => '$functionName()',
        AnimeParserFunction.search: (params) {
          final pageIndex = params['pageIndex'];
          final pageSize = params['pageSize'];
          final keyword = params['keyword'];
          final filterSelect = params['filterSelect'];
          return '$functionName($pageIndex, $pageSize, "$keyword", ${jsonEncode(filterSelect)})';
        },
        AnimeParserFunction.filter: (params) => '$functionName()',
        AnimeParserFunction.home: (params) {
          final pageIndex = params['pageIndex'];
          final pageSize = params['pageSize'];
          final filterSelect = params['filterSelect'];
          return '$functionName($pageIndex, $pageSize, ${jsonEncode(filterSelect)})';
        },
        AnimeParserFunction.detail: (params) {
          final animeUrl = params['animeUrl'];
          return '$functionName("$animeUrl")';
        },
        AnimeParserFunction.playUrl: (params) {
          final resourceUrls = params['resourceUrls'];
          return '$functionName(${jsonEncode(resourceUrls)})';
        },
        AnimeParserFunction.recommend: (params) {
          final animeUrl = params['animeUrl'];
          final filterSelect = params['filterSelect'];
          return '$functionName("$animeUrl" , ${jsonEncode(filterSelect)})';
        },
      }[this]!(params);
}
