import 'package:isar/isar.dart';

part 'video_cache.g.dart';

@collection
class VideoCache {
  Id id = Isar.autoIncrement;

  // 原始地址
  @Index(type: IndexType.hash)
  String url = '';

  // 播放地址
  String playUrl = '';
}
