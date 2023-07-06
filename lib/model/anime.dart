import 'package:jtech_anime/common/model.dart';

/*
* 番剧对象
* @author wuxubaiyang
* @Time 2023/7/6 10:54
*/
class AnimeModel extends BaseModel {
  // 名称
  final String name;

  // 封面
  final String cover;

  // 状态
  final String status;

  // 类型
  final List<String> types;

  // 地区
  final String region;

  // 简介
  final String intro;

  // 更新时间
  final String updateTime;

  // 地址
  final String url;

  // 资源
  final List<List<ResourceItemModel>> resources;

  AnimeModel({
    this.name = '',
    this.cover = '',
    this.status = '',
    this.types = const [],
    this.region = '',
    this.intro = '',
    this.updateTime = '',
    this.url = '',
    this.resources = const [],
  });
}

/*
* 资源项
* @author wuxubaiyang
* @Time 2023/7/6 10:56
*/
class ResourceItemModel extends BaseModel {
  // 名称
  final String name;

  // 地址
  final String url;

  ResourceItemModel({
    this.name = '',
    this.url = '',
  });
}
