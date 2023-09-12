import 'package:desktop/common/route.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页下载管理页面
* @author wuxubaiyang
* @Time 2023/9/12 14:09
*/
class HomeDownloadPage extends StatefulWidget {
  const HomeDownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeDownloadPageState();
}

/*
* 首页下载管理页面-状态
* @author wuxubaiyang
* @Time 2023/9/12 14:09
*/
class _HomeDownloadPageState
    extends LogicState<HomeDownloadPage, _HomeDownloadLogic> {
  @override
  _HomeDownloadLogic initLogic() => _HomeDownloadLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页下载管理页面'),
      ),
    );
  }
}

/*
* 首页下载管理页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/12 14:09
*/
class _HomeDownloadLogic extends BaseLogic {
  // 下载队列
  final downloadingList = ListValueChangeNotifier<DownloadGroup>.empty();

  // 已下载记录
  final downloadedList = ListValueChangeNotifier<DownloadGroup>.empty();

  // 判断当前是否在下载tab
  final downloadingTab = ValueChangeNotifier(true);

  // 播放记录缓存控制
  final playRecordController =
  CacheFutureBuilderController<Map<String, PlayRecord>>();

  // 获取下载队列与已下载队列
  Future<void> loadDownloadRecords() async {
    try {
      // 加载下载队列记录
      downloadingList.setValue(await _getDownloadRecords([
        DownloadRecordStatus.download,
        DownloadRecordStatus.fail,
      ]));
      // 加载已下载记录
      downloadedList.setValue(await _getDownloadRecords([
        DownloadRecordStatus.complete,
      ]));
    } catch (e) {
      LogTool.e('获取下载记录失败', error: e);
    }
  }

  // 获取下载记录
  Future<List<DownloadGroup>> _getDownloadRecords(
      List<DownloadRecordStatus> status) async {
    final source = animeParser.currentSource;
    if (source == null) return [];
    final result = await db.getDownloadRecordList(source, status: status);
    // 遍历下载记录并将记录分组排序
    String? lastUrl;
    final groupList = <DownloadGroup>[], subList = <DownloadRecord>[];
    for (int i = 0; i < result.length; i++) {
      final item = result[i];
      if ((lastUrl ??= item.url) != item.url) {
        final group = DownloadGroup.fromRecords(List.of(subList));
        if (group != null) groupList.add(group);
        lastUrl = item.url;
        subList.clear();
      }
      subList.add(item);
    }
    final group = DownloadGroup.fromRecords(subList);
    if (group != null) groupList.add(group);
    // 对分组数据进行排序(按时间)
    return groupList..sort((l, r) => r.updateTime.compareTo(l.updateTime));
  }

  // 根据已下载列表获取播放记录并转换成map
  Future<Map<String, PlayRecord>> loadDownloadedPlayRecord() async {
    final urls = downloadedList.value.map((e) => e.url).toList();
    final result = await db.getPlayRecords(urls);
    return result.asMap().map((_, v) => MapEntry(v.url, v));
  }

  // 跳转到播放详情页
  Future<void> goPlay(DownloadRecord item, [bool playTheRecord = false]) async {
    await router.pushNamed(
      RoutePath.animeDetail,
      arguments: {
        'downloadRecord': item,
        'playTheRecord': playTheRecord,
        'animeDetail': AnimeModel(
          url: item.url,
          name: item.name,
          cover: item.cover,
        ),
      },
    );
    // 页面返回之后刷新播放记录
    playRecordController.refreshValue();
  }

  // 删除下载记录
  Future<void> removeDownloadRecord(List<DownloadRecord> records) async {
    // 移除目标任务并重新获取下载记录
    await download.removeTasks(records);
    await loadDownloadRecords();
  }
}
