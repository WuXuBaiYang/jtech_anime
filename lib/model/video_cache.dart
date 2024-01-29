import 'package:isar/isar.dart';

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

  // 缓存时间
  int cacheTime = DateTime.now().millisecondsSinceEpoch;
}
