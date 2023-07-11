import 'package:isar/isar.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/model/filter_select.dart';
import 'package:jtech_anime/model/search_record.dart';
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
      [
        VideoCacheSchema,
        FilterSelectSchema,
        SearchRecordSchema,
      ],
      directory: dir.path,
    );
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
            .keywordEqualTo(
              keyword,
            )
            .findFirst();
        // 不存在则创建新的搜索记录并热度+1
        item ??= SearchRecord();
        return isar.searchRecords
            .put(item
              ..heat += 1
              ..keyword = keyword)
            .then((id) => isar.searchRecords.get(id));
      });

  // 移除搜索记录
  Future<bool> removeSearchRecord(int id) => isar.writeTxn<bool>(() {
        // 移除搜索记录
        return isar.searchRecords.delete(id);
      });

  // 获取已选过滤条件
  Future<List<FilterSelect>> getFilterSelectList(AnimeSource source) =>
      isar.filterSelects.where().sourceEqualTo(source.name).findAll();

  // 添加过滤条件
  Future<FilterSelect?> addFilterSelect(
    AnimeFilterModel parent,
    AnimeFilterItemModel item, {
    AnimeSource source = AnimeSource.yhdmz,
  }) =>
      isar.writeTxn<FilterSelect?>(() async {
        final maxSelected = parent.maxSelected;
        if (maxSelected < 1) return null;
        final queryBuilder = isar.filterSelects
            .where()
            .filter()
            .keyEqualTo(parent.key)
            .and()
            .sourceEqualTo(source.name);
        if (maxSelected == 1) {
          // 如果最大选择数为1，则移除所有符合条件的结果
          await queryBuilder.deleteAll();
        } else {
          // 如果最大选择数大于1,则判断是否已超过选择上限，超过的话则停止选择
          final count = await queryBuilder.count();
          if (count >= maxSelected) return null;
        }
        // 插入过滤条件并返回
        return isar.filterSelects
            .put(FilterSelect()
              ..key = parent.key
              ..value = item.value
              ..source = source.name
              ..name = item.name
              ..parentName = parent.name)
            .then((id) => isar.filterSelects.get(id));
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
      isar.writeTxn<VideoCache?>(() {
        // 插入视频缓存并返回
        return isar.videoCaches
            .put(VideoCache()
              ..url = url
              ..playUrl = playUrl)
            .then((id) => isar.videoCaches.get(id));
      });
}

// 单例调用
final db = DBManage();
