import 'package:jtech_anime/common/model.dart';

/*
* 番剧解析方法请求参数对象
* @author wuxubaiyang
* @Time 2023/8/10 10:54
*/
class AnimeParserRequestModel extends BaseModel {
  // 页码
  final int? pageIndex;

  // 单页数据量
  final int? pageSize;

  // 过滤条件map
  final Map<String, dynamic>? filterSelect;

  // 搜索key
  final String? keyword;

  // 番剧详情页地址/id
  final String? animeUrl;

  // 番剧资源地址集合
  final List<String>? resourceUrls;

  // 构建首页请求数据结构
  AnimeParserRequestModel.fromHome({
    this.pageIndex = 1,
    this.pageSize = 25,
    this.filterSelect,
  })  : keyword = null,
        animeUrl = null,
        resourceUrls = null;

  // 构建搜索页请求数据结构
  AnimeParserRequestModel.fromSearch({
    this.pageIndex = 1,
    this.pageSize = 25,
  })  : keyword = null,
        animeUrl = null,
        filterSelect = null,
        resourceUrls = null;

  // 构建详情页请求数据结构
  AnimeParserRequestModel.fromDetail({
    required this.animeUrl,
  })  : pageIndex = null,
        pageSize = null,
        keyword = null,
        filterSelect = null,
        resourceUrls = null;

  // 构建视频播放地址请求数据
  AnimeParserRequestModel.fromPlayUrl({
    required this.resourceUrls,
  })  : pageIndex = null,
        pageSize = null,
        keyword = null,
        animeUrl = null,
        filterSelect = null;

  @override
  Map<String, dynamic> to() => {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'filterSelect': filterSelect,
        'keyword': keyword,
        'animeUrl': animeUrl,
        'resourceUrls': resourceUrls,
      };
}
