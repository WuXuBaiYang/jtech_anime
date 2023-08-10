/*
* 解析方法枚举
* @author wuxubaiyang
* @Time 2023/8/9 17:23
*/
enum AnimeParserFunction {
  // 获取当前资源信息
  source,
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
}

/*
* 解析方法枚举扩展
* @author wuxubaiyang
* @Time 2023/8/9 17:30
*/
extension AnimeParserFunctionExtension on AnimeParserFunction {
  // 获取方法名
  String get functionName => {
        AnimeParserFunction.source: 'getSourceInfo',
        AnimeParserFunction.timeTable: 'loadTimeTableList',
        AnimeParserFunction.search: 'searchAnimeList',
        AnimeParserFunction.filter: 'loadFilterList',
        AnimeParserFunction.home: 'loadHomeList',
        AnimeParserFunction.detail: 'getAnimeDetail',
        AnimeParserFunction.playUrl: 'getPlayUrl',
      }[this]!;

  // 判断方法是否为必须
  bool get required => {
        AnimeParserFunction.timeTable: false,
        AnimeParserFunction.search: false,
        AnimeParserFunction.filter: false,
        AnimeParserFunction.source: true,
        AnimeParserFunction.home: true,
        AnimeParserFunction.detail: true,
        AnimeParserFunction.playUrl: true,
      }[this]!;
}
