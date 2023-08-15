import 'package:isar/isar.dart';
import 'package:jtech_anime/model/anime.dart';

part 'video_cache.g.dart';

/*
* 视频缓存
* @author wuxubaiyang
* @Time 2023/7/13 16:06
*/
@collection
class VideoCache {
  Id id = Isar.autoIncrement;

  // 原始地址
  @Index(type: IndexType.hash, unique: true, replace: true)
  String url = '';

  // 播放地址
  String playUrl = '';

  // 原始资源信息
  @Ignore()
  ResourceItemModel? item;

  static VideoCache from(obj, [ResourceItemModel? item]) {
    return VideoCache()
      ..url = obj['url'] ?? ''
      ..playUrl = obj['playUrl'] ?? ''
      ..item = item;
  }
}
