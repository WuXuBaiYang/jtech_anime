import 'package:isar/isar.dart';
import 'package:jtech_anime/model/anime.dart';

part 'video_cache.g.dart';

@collection
class VideoCache {
  Id id = Isar.autoIncrement;

  // 原始地址
  @Index(type: IndexType.hash)
  String url = '';

  // 播放地址
  String playUrl = '';

  // 原始资源信息
  @Ignore()
  ResourceItemModel? item;
}
