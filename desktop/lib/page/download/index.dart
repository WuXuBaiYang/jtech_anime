import 'package:desktop/common/route.dart';
import 'package:desktop/model/event.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

import 'list.dart';

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
    extends LogicState<HomeDownloadPage, _HomeDownloadLogic>
    with SingleTickerProviderStateMixin {
  // tab控制器
  late TabController tabController = TabController(length: 2, vsync: this);

  @override
  _HomeDownloadLogic initLogic() => _HomeDownloadLogic();

  @override
  void initState() {
    super.initState();
    // 初始化获取下载记录，获取到之后判断跳转tab页
    logic.loadDownloadRecords().then((_) {
      // 如果下载队列为空，并且已下载页面有数据，则展示下载队列，否则展示已下载队列
      final showDownloading =
          logic.downloadingList.isNotEmpty || logic.downloadedList.isEmpty;
      tabController.animateTo(showDownloading ? 0 : 1);
    });
    // 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 监听下载完成事件
      download.addDownloadCompleteListener((_) {
        if (!mounted) return;
        logic.loadDownloadRecords();
        logic.playRecordController.refreshValue();
      });
      // 主动推送一次最新的下载进度
      download.pushLatestProgress();
    });
    // 监听tab变化
    tabController.animation?.addListener(() {
      if (tabController.animation == null) return;
      final inDownloadingTab = tabController.animation!.value <= 0.5;
      logic.downloadingTab.setValue(inDownloadingTab);
    });
    // 监听新增下载事件
    event.on<NewDownloadEvent>().listen((event) {
      if (!mounted) return;
      logic.loadDownloadRecords();
    });
    // 监听播放记录事件
    event.on<PlayRecordEvent>().listen((event) {
      if (!mounted) return;
      logic.playRecordController.refreshValue();
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.downloadingTab,
      builder: (_, downloadingTab, __) {
        return Scaffold(
          body: Column(
            children: [
              CustomTabBar(
                controller: tabController,
                tabs: ['下载队列', '已下载'].map((e) {
                  return Tab(text: e);
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _buildDownloadingList(context),
                    _buildDownloadedList(context),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildDownloadingStatusFAB(downloadingTab),
        );
      },
    );
  }

  // 构建下载状态fab
  Widget? _buildDownloadingStatusFAB(bool showFAB) {
    if (!showFAB) return null;
    return StreamBuilder<DownloadTask?>(
      stream: download.downloadProgress,
      builder: (_, snap) {
        final task = snap.data;
        final hasDownloadTask = download.downloadQueue.isNotEmpty ||
            download.prepareQueue.isNotEmpty;
        final totalSpeed = '${FileTool.formatSize(task?.totalSpeed ?? 0)}/s';
        return FloatingActionButton.extended(
          label: Text(totalSpeed),
          isExtended: hasDownloadTask,
          icon: Center(
            child: Icon(hasDownloadTask
                ? FontAwesomeIcons.pause
                : FontAwesomeIcons.play),
          ),
          onPressed: () {
            final records = logic.downloadingList.value
                .expand<DownloadRecord>((e) => e.records)
                .toList();
            hasDownloadTask
                ? download.stopTasks(records)
                : download.startTasks(records);
          },
        );
      },
    );
  }

  // 构建下载队列
  Widget _buildDownloadingList(BuildContext context) {
    return ValueListenableBuilder<List<DownloadGroup>>(
      valueListenable: logic.downloadingList,
      builder: (_, groups, __) {
        final expandedList = groups.map((e) => e.url).toList();
        final padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            .copyWith(bottom: kToolbarHeight * 1.5);
        return StreamBuilder<DownloadTask?>(
          stream: download.downloadProgress,
          builder: (_, snap) {
            return DownloadRecordListView(
              padding: padding,
              groupList: groups,
              initialExpanded: expandedList,
              onStopDownloads: download.stopTasks,
              onStartDownloads: download.startTasks,
              downloadTask: snap.data ?? DownloadTask(),
              onRemoveRecords: (records) {
                _showDeleteDialog(context, records);
              },
            );
          },
        );
      },
    );
  }

  // 构建下载记录列表
  Widget _buildDownloadedList(BuildContext context) {
    return CacheFutureBuilder<Map<String, PlayRecord>>(
      future: logic.loadDownloadedPlayRecord,
      controller: logic.playRecordController,
      builder: (_, snap) {
        final playRecordMap = snap.data ?? {};
        return ValueListenableBuilder<List<DownloadGroup>>(
          valueListenable: logic.downloadedList,
          builder: (_, groups, __) {
            return DownloadRecordListView(
              groupList: groups,
              playRecordMap: playRecordMap,
              onRemoveRecords: (records) => _showDeleteDialog(context, records),
              onPlayRecords: (records) {
                if (records.isEmpty) return;
                final item = records.first;
                final playRecord = playRecordMap[item.url];
                logic.goPlay(item, playRecord?.resUrl == item.resUrl);
              },
            );
          },
        );
      },
    );
  }

  // 展示删除弹窗
  Future<void> _showDeleteDialog(
      BuildContext context, List<DownloadRecord> records) async {
    if (records.isEmpty) return;
    final item = records.first;
    final content = '是否删除 ${item.title} ${item.name} '
        '${records.length > 1 ? '等${records.length}条下载记录' : ''}';
    return MessageDialog.show(
      context,
      title: const Text('删除'),
      content: Text(content),
      actionMiddle: TextButton(
        child: const Text('取消'),
        onPressed: () => router.pop(),
      ),
      actionRight: TextButton(
        child: const Text('删除'),
        onPressed: () {
          logic.removeDownloadRecord(records);
          router.pop();
        },
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
