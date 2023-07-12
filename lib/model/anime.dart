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

  AnimeModel.from(obj)
      : name = obj['name'] ?? '',
        cover = obj['cover'] ?? '',
        status = obj['status'] ?? '',
        types = (obj['types'] ?? <String>[]) as List<String>,
        region = obj['region'] ?? '',
        intro = obj['intro'] ?? '',
        updateTime = obj['updateTime'] ?? '',
        url = obj['url'] ?? '',
        resources = (obj['resources'] ?? []).map<List<ResourceItemModel>>((e) {
          return (e as List)
              .map<ResourceItemModel>((e) => ResourceItemModel.from(e))
              .toList();
        }).toList();

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
        'resources': resources
            .map(
              (e) => e.map((e) => e.to()),
            )
            .toList(),
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

  ResourceItemModel.from(obj)
      : name = obj['name'] ?? '',
        url = obj['url'] ?? '';

  @override
  Map<String, dynamic> to() => {
        'name': name,
        'url': url,
      };
}
