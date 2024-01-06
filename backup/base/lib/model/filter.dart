import 'package:jtech_anime_base/common/model.dart';

/*
* 动漫列表过滤条件
* @author wuxubaiyang
* @Time 2023/7/6 11:25
*/
class AnimeFilterModel extends BaseModel {
  // 名称
  final String name;

  // key
  final String key;

  // 最大选择数
  final int maxSelected;

  // 选项
  final List<AnimeFilterItemModel> items;

  AnimeFilterModel.from(obj)
      : name = obj['name'] ?? '',
        key = obj['key'] ?? '',
        maxSelected = obj['maxSelected'] ?? 1,
        items = (obj['items'] ?? [])
            .map<AnimeFilterItemModel>((e) => AnimeFilterItemModel.from(e))
            .toList();
}

/*
* 动漫过滤列表项
* @author wuxubaiyang
* @Time 2023/7/6 11:26
*/
class AnimeFilterItemModel extends BaseModel {
  // 名称
  final String name;

  // 值
  final String value;

  AnimeFilterItemModel.from(obj)
      : name = obj['name'] ?? '',
        value = obj['value'] ?? '';
}
