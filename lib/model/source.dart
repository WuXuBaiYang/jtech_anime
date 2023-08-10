import 'package:jtech_anime/common/model.dart';

/*
* 番剧资源站信息
* @author wuxubaiyang
* @Time 2023/8/10 11:13
*/
class AnimeSource extends BaseModel {
  // 资源站key（唯一英文名/拼音，不可变）
  final String key;

  // 资源站名称
  final String name;

  // 站点首页
  final String homepage;

  // 当前解析方法版本号
  final String version;

  // 最后编辑日期
  final DateTime lastEditDate;

  // 网站logo（在线地址）
  final String logoUrl;

  AnimeSource.from(obj)
      : key = obj['key'] ?? '',
        name = obj['name'] ?? '',
        homepage = obj['homepage'] ?? '',
        version = obj['version'] ?? '',
        lastEditDate =
            DateTime.tryParse(obj['lastEditDate'] ?? '') ?? DateTime(1),
        logoUrl = obj['logoUrl'] ?? '';
}
