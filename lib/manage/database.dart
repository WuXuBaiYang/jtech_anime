import 'package:isar/isar.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/model/collect.dart';
import 'package:jtech_anime/model/download_record.dart';
import 'package:jtech_anime/model/filter_select.dart';
import 'package:jtech_anime/model/play_record.dart';
import 'package:jtech_anime/model/proxy.dart';
import 'package:jtech_anime/model/search_record.dart';
import 'package:jtech_anime/model/source.dart';
import 'package:jtech_anime/model/video_cache.dart';
import 'package:jtech_anime/tool/file.dart';

/*
* 数据库管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DatabaseManage extends BaseManage {
  static final DatabaseManage _instance = DatabaseManage._internal();

  factory DatabaseManage() => _instance;

  DatabaseManage._internal();

  // 数据库对象
  late Isar isar;

  @override
  Future<void> initialize() async {
    final dir = await FileTool.getDirPath(Common.baseCachePath,
        root: FileDir.applicationDocuments);
    isar = await Isar.open([
      VideoCacheSchema,
      FilterSelectSchema,
      SearchRecordSchema,
      PlayRecordSchema,
      CollectSchema,
      DownloadRecordSchema,
      AnimeSourceSchema,
      ProxyRecordSchema,
    ], directory: dir ?? '');
  }


  // 获取代理记录
  Future<List<ProxyRecord>> getProxyList() =>
      isar.proxyRecords.where().findAll();

  // 添加或更新代理记录
  Future<ProxyRecord?> updateProxy(ProxyRecord item) =>
      isar.writeTxn<ProxyRecord?>(() {
        return isar.proxyRecords.put(item).then((id) => item..id = id);
      });

  // 删除代理记录
  Future<bool> removeProxy(int id) =>
      isar.writeTxn<bool>(() => isar.proxyRecords.delete(id));

  // 获取所有数据源配置
  Future<List<AnimeSource>> getAnimeSourceList() =>
      isar.animeSources.where().sortByKey().findAll();

  // 根据数据源key获取数据源信息
  Future<AnimeSource?> getAnimeSource(String key) =>
      isar.animeSources.filter().keyEqualTo(key).findFirst();

  // 删除数据源
  Future<bool> removeAnimeSource(int id) =>
      isar.writeTxn<bool>(() => isar.animeSources.delete(id));

  // 添加数据源
  Future<AnimeSource?> updateAnimeSource(AnimeSource item) =>
      isar.writeTxn<AnimeSource?>(() {
        return isar.animeSources.put(item).then((id) => item..id = id);
      });

  // 删除下载记录
  Future<bool> removeDownloadRecord(int id) =>
      isar.writeTxn<bool>(() => isar.downloadRecords.delete(id));

  // 添加或更新下载记录
  Future<DownloadRecord?> updateDownload(DownloadRecord item) =>
      isar.writeTxn<DownloadRecord?>(() {
        return isar.downloadRecords.put(item).then((id) => item..id = id);
      });

  // 获取下载记录(根据番剧的播放地址，不是访问地址)
  Future<DownloadRecord?> getDownloadRecord(
      String playUrl, {
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
      AnimeSource source, {
        List<DownloadRecordStatus> status = const [],
        List<String> animeList = const [],
      }) =>
      isar.downloadRecords
          .where()
          .sourceEqualTo(source.key)
          .filter()
          .anyOf(status, (q, e) => q.statusEqualTo(e))
          .and()
          .anyOf(animeList, (q, e) => q.urlEqualTo(e))
          .sortByUrl()
          .findAll();

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
            .then((id) => item..id = id);
      });

  // 更新排序
  Future<bool> updateCollectOrder(String url,
      {required AnimeSource source, required int to}) =>
      isar.writeTxn<bool>(() async {
        // 查出全部收藏列表
        final items = await isar.collects
            .where()
            .sourceEqualTo(source.key)
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
  Future<List<Collect>> getCollectList(AnimeSource source,
      {int pageIndex = 1, int pageSize = 25}) async {
    if (pageIndex < 1 || pageSize < 1) return [];
    return isar.collects
        .where()
        .sourceEqualTo(source.key)
        .sortByOrderDesc()
        .offset((--pageIndex) * pageSize)
        .limit(pageSize)
        .findAll();
  }

  // 更新播放记录
  Future<PlayRecord?> updatePlayRecord(PlayRecord item) =>
      isar.writeTxn<PlayRecord?>(() {
        return isar.playRecords.put(item).then((id) => item..id = id);
      });

  // 根据播放地址获取播放记录
  Future<PlayRecord?> getPlayRecord(String url) =>
      isar.playRecords.where().urlEqualTo(url).findFirst();

  // 根据播放地址集合获取播放记录
  Future<List<PlayRecord>> getPlayRecords(List<String> urls) => isar.playRecords
      .filter()
      .anyOf(urls, (q, e) => q.urlEqualTo(e))
      .findAll();

  // 获取播放记录(分页)
  Future<List<PlayRecord>> getPlayRecordList(AnimeSource source,
      {int pageIndex = 1, int pageSize = 25}) async {
    if (pageIndex < 1 || pageSize < 1) return [];
    return isar.playRecords
        .where()
        .sourceEqualTo(source.key)
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
  Future<bool> removeSearchRecord(int id) =>
      isar.writeTxn<bool>(() => isar.searchRecords.delete(id));

  // 获取已选过滤条件
  Future<List<FilterSelect>> getFilterSelectList(AnimeSource source) =>
      isar.filterSelects.where().sourceEqualTo(source.key).findAll();

  // 添加过滤条件
  Future<FilterSelect?> addFilterSelect(FilterSelect item) =>
      isar.filterSelects.put(item).then((id) => item..id = id);

  // 移除过滤条件
  Future<bool> removeFilterSelect(int id) =>
      isar.writeTxn<bool>(() => isar.filterSelects.delete(id));

  // 替换现有的过滤条件
  Future<List<FilterSelect>> replaceFilterSelectList(
      AnimeSource source, List<FilterSelect> filters) {
    return isar.writeTxn<List<FilterSelect>>(() async {
      // 先移除该资源下的全部选择再添加新的部分
      await isar.filterSelects.where().sourceEqualTo(source.key).deleteAll();
      final ids = await isar.filterSelects.putAll(filters);
      ids.asMap().forEach((i, id) => filters[i].id = id);
      return filters;
    });
  }

  // 根据原视频地址获取已缓存播放地址
  Future<VideoCache?> getCachePlayUrl(String url) async =>
      (await isar.videoCaches.where().urlEqualTo(url).findFirst());

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
final database = DatabaseManage();
