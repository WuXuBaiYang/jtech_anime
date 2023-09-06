import 'package:jtech_anime_base/common/model.dart';

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
    required this.url,
    required this.name,
    required this.cover,
    this.status = '',
    this.types = const [],
    this.region = '',
    this.intro = '',
    this.updateTime = '',
    this.resources = const [],
  });

  AnimeModel.from(obj)
      : name = obj['name'] ?? '',
        cover = obj['cover'] ?? '',
        status = obj['status'] ?? '',
        types = (obj['types'] ?? []).map<String>((e) => '$e').toList(),
        region = obj['region'] ?? '',
        intro = obj['intro'] ?? '',
        updateTime = obj['updateTime'] ?? '',
        url = obj['url'] ?? '',
        resources = (obj['resources'] ?? []).map<List<ResourceItemModel>>((e) {
          return (e as List)
              .map<ResourceItemModel>((e) => ResourceItemModel.from(e))
              .toList();
        }).toList();

  // 合并详情（将传入对象合并到当前对象中）
  AnimeModel merge(AnimeModel model) {
    return AnimeModel(
      url: _mergeString(model.url, url),
      name: _mergeString(model.name, name),
      cover: _mergeString(model.cover, cover),
      status: _mergeString(model.status, status),
      region: _mergeString(model.region, region),
      intro: _mergeString(model.intro, intro),
      updateTime: _mergeString(model.updateTime, updateTime),
      types: model.types.isNotEmpty ? model.types : types,
      resources: model.resources.isNotEmpty ? model.resources : resources,
    );
  }

  // 合并字符串
  String _mergeString(String from, String to) {
    if (from.isEmpty) return to;
    return from;
  }

  @override
  Map<String, dynamic> to() => {
        'name': name,
        'cover': cover,
        'status': status,
        'types': types,
        'region': region,
        'intro': intro,
        'updateTime': updateTime,
        'url': url,
        'resources': resources.map((e) {
          return e.map((e) => e.to()).toList();
        }).toList(),
      };
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

  // 排序（1-1代表资源1的第一条资源）
  final int order;

  ResourceItemModel({
    required this.name,
    required this.url,
    this.order = 0,
  });

  ResourceItemModel.from(obj)
      : name = obj['name'] ?? '',
        url = obj['url'] ?? '',
        order = obj['order'] ?? 0;

  @override
  Map<String, dynamic> to() => {
        'name': name,
        'url': url,
        'order': order,
      };
}
