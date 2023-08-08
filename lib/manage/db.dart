import 'package:isar/isar.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/model/database/collect.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/database/filter_select.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/model/database/search_record.dart';
import 'package:jtech_anime/model/database/video_cache.dart';
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
      [
        VideoCacheSchema,
        FilterSelectSchema,
        SearchRecordSchema,
        PlayRecordSchema,
        CollectSchema,
        DownloadRecordSchema,
      ],
      directory: dir.path,
    );
  }

  // 删除下载记录
  Future<bool> removeDownloadRecord(int id) => isar.writeTxn<bool>(() {
        // 移除下载记录
        return isar.downloadRecords.delete(id);
      });

  // 添加或更新下载记录
  Future<DownloadRecord?> updateDownload(DownloadRecord item) =>
      isar.writeTxn<DownloadRecord?>(() {
        // 更新或添加下载记录
        return isar.downloadRecords
            .put(item)
            .then((id) => isar.downloadRecords.get(id));
      });

  // 获取下载记录(根据番剧的播放地址，不是访问地址)
  Future<DownloadRecord?> getDownloadRecord(
    String playUrl, {
    // 按照下载状态过滤
    List<DownloadRecordStatus> status = const [],
  }) =>
      isar.downloadRecords
          .filter()
          .downloadUrlEqualTo(playUrl)
          .and()
          .anyOf(status, (q, e) => q.statusEqualTo(e))
          .findFirst();

  // 获取下载记录列表
  Future<List<DownloadRecord>> getDownloadRecordList(
    String source, {
    // 按照下载状态过滤
    List<DownloadRecordStatus> status = const [],
    // 按照番剧地址过滤
    List<String> animeList = const [],
  }) async {
    return isar.downloadRecords
        .where()
        .sourceEqualTo(source)
        .filter()
        .anyOf(status, (q, e) => q.statusEqualTo(e))
        .and()
        .anyOf(animeList, (q, e) => q.urlEqualTo(e))
        .sortByUrl()
        .findAll();
  }

  // 添加或移除收藏
  Future<Collect?> updateCollect(Collect item) =>
      isar.writeTxn<Collect?>(() async {
        // 已存在则移除收藏
        if (item.id > 0) {
          return isar.collects.delete(item.id).then((v) => null);
        }
        // 不存在则添加(排序增加)
        final count =
            await isar.collects.where().sourceEqualTo(item.source).count();
        return isar.collects
            .put(item..order = count)
            .then((id) => isar.collects.get(id));
      });

  // 更新排序
  Future<bool> updateCollectOrder(String url,
          {required String source, required int to}) =>
      isar.writeTxn<bool>(() async {
        // 查出全部收藏列表
        final items = await isar.collects
            .where()
            .sourceEqualTo(source)
            .sortByOrder()
            .findAll();
        // 对收藏列表重排序并更新收藏列表
        int i = 0;
        return isar.collects
            .putAll(items.map((e) {
              if (i == to) i++;
              return e..order = e.url == url ? to : i++;
            }).toList())
            .then((v) => v.length == items.length);
      });

  // 根据播放地址获取收藏
  Future<Collect?> getCollect(String url) =>
      isar.collects.where().urlEqualTo(url).findFirst();

  // 获取收藏列表(分页)
  Future<List<Collect>> getCollectList(String source,
      {int pageIndex = 1, int pageSize = 25}) async {
    if (pageIndex < 1 || pageSize < 1) return [];
    return isar.collects
        .where()
        .sourceEqualTo(source)
        .sortByOrderDesc()
        .offset((--pageIndex) * pageSize)
        .limit(pageSize)
        .findAll();
  }

  // 更新播放记录
  Future<PlayRecord?> updatePlayRecord(PlayRecord item) =>
      isar.writeTxn<PlayRecord?>(() {
        // 插入播放记录并返回最新记录
        return isar.playRecords.put(item).then(isar.playRecords.get);
      });

  // 根据播放地址获取播放记录
  Future<PlayRecord?> getPlayRecord(String url) =>
      isar.playRecords.where().urlEqualTo(url).findFirst();

  // 获取播放记录(分页)
  Future<List<PlayRecord>> getPlayRecordList(String source,
      {int pageIndex = 1, int pageSize = 25}) async {
    if (pageIndex < 1 || pageSize < 1) return [];
    return isar.playRecords
        .where()
        .sourceEqualTo(source)
        .sortByUpdateTimeDesc()
        .offset((--pageIndex) * pageSize)
        .limit(pageSize)
        .findAll();
  }

  // 获取搜索记录列表
  Future<List<SearchRecord>> getSearchRecordList() =>
      isar.searchRecords.where().sortByHeatDesc().findAll();

  // 添加搜索记录
  Future<SearchRecord?> addSearchRecord(String keyword) =>
      isar.writeTxn<SearchRecord?>(() async {
        // 查询是否已存在搜索记录
        var item = await isar.searchRecords
            .where()
            .keywordEqualTo(keyword)
            .findFirst();
        // 不存在则创建新的搜索记录并热度+1
        item ??= SearchRecord();
        return isar.searchRecords
            .put(item
              ..heat += 1
              ..keyword = keyword)
            .then(isar.searchRecords.get);
      });

  // 移除搜索记录
  Future<bool> removeSearchRecord(int id) => isar.writeTxn<bool>(() {
        // 移除搜索记录
        return isar.searchRecords.delete(id);
      });

  // 获取已选过滤条件
  Future<List<FilterSelect>> getFilterSelectList(String source) =>
      isar.filterSelects.where().sourceEqualTo(source).findAll();

  // 添加过滤条件
  Future<FilterSelect?> addFilterSelect(FilterSelect item,
          [int maxSelected = 1]) =>
      isar.writeTxn<FilterSelect?>(() async {
        if (maxSelected < 1) return null;
        final queryBuilder = isar.filterSelects
            .where()
            .filter()
            .keyEqualTo(item.key)
            .and()
            .sourceEqualTo(item.source);
        if (maxSelected == 1) {
          // 如果最大选择数为1，则移除所有符合条件的结果
          await queryBuilder.deleteAll();
        } else {
          // 如果最大选择数大于1,则判断是否已超过选择上限，超过的话则停止选择
          final count = await queryBuilder.count();
          if (count >= maxSelected) return null;
        }
        // 插入过滤条件并返回
        return isar.filterSelects.put(item).then(isar.filterSelects.get);
      });

  // 移除过滤条件
  Future<bool> removeFilterSelect(int id) => isar.writeTxn<bool>(() {
        // 删除过滤条件
        return isar.filterSelects.delete(id);
      });

  // 根据原视频地址获取已缓存播放地址
  Future<String?> getCachePlayUrl(String url) async =>
      (await isar.videoCaches.where().urlEqualTo(url).findFirst())?.playUrl;

  // 缓存视频播放地址
  Future<VideoCache?> cachePlayUrl(String url, String playUrl) =>
      isar.writeTxn<VideoCache?>(() async {
        if (playUrl.isEmpty) return null;
        // 插入视频缓存并返回
        return isar.videoCaches
            .put(VideoCache()
              ..url = url
              ..playUrl = playUrl)
            .then(isar.videoCaches.get);
      });
}

// 单例调用
final db = DBManage();
