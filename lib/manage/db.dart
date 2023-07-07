import 'package:isar/isar.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/model/video_cache.dart';
import 'package:path_provider/path_provider.dart';

/*
* 数据库管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DBManage extends BaseManage {
  static final DBManage _instance = DBManage._internal();

  factory DBManage() => _instance;

  DBManage._internal();

  // 数据库对象
  late Isar isar;

  @override
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [VideoCacheSchema],
      directory: dir.path,
    );
  }

  // 根据原视频地址获取已缓存播放地址
  Future<String?> getCachePlayUrl(String url) async {
    final cache = await isar.videoCaches.where().urlEqualTo(url).findFirst();
    return cache?.playUrl;
  }

  // 缓存视频播放地址
  Future<void> cachePlayUrl(String url, String playUrl) async {
    await isar.writeTxn(() {
      // 插入或更新
      return isar.videoCaches.put(
        VideoCache()
          ..url = url
          ..playUrl = playUrl,
      );
    });
  }
}

// 单例调用
final db = DBManage();
