import 'package:isar/isar.dart';

part 'play_record.g.dart';

/*
* 播放记录
* @author wuxubaiyang
* @Time 2023/7/13 16:06
*/
@collection
class PlayRecord {
  Id id = Isar.autoIncrement;

  // 番剧url
  @Index(type: IndexType.hash, unique: true, replace: true)
  String url = '';

  // 数据源
  @Index(type: IndexType.hash)
  String source = '';

  // 番剧名称
  String name = '';

  // 播放番剧封面
  String cover = '';

  // 播放资源名称
  String resName = '';

  // 播放的资源url
  String resUrl = '';

  // 播放进度(单位秒)
  int progress = 0;

  // 最后更新时间
  DateTime updateTime = DateTime.now();
}
