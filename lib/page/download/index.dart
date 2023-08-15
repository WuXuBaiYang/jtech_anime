import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/download.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/model/download.dart';
import 'package:jtech_anime/model/download_group.dart';
import 'package:jtech_anime/page/download/listview.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/permission.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/message_dialog.dart';

/*
* 下载管理页
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _DownloadPageState();
}

/*
* 下载管理页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class _DownloadPageState extends LogicState<DownloadPage, _DownloadLogic>
    with SingleTickerProviderStateMixin {
  // tab控制器
  late TabController tabController = TabController(length: 2, vsync: this);

  @override
  _DownloadLogic initLogic() => _DownloadLogic();

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
      // 请求通知权限
      PermissionTool.checkNotification(context);
      // 监听下载完成事件
      download.addDownloadCompleteListener((_) {
        if (!mounted) return;
        logic.loadDownloadRecords();
        logic.playRecordController.refreshValue();
      });
      // 主动推送一次最新的下载进度
      download.pushLatestProgress();
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('番剧缓存'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            controller: tabController,
            tabs: ['下载队列', '已下载'].map((e) => Tab(text: e)).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildDownloadingList(context),
          _buildDownloadedList(context),
        ],
      ),
    );
  }

  // 构建下载队列
  Widget _buildDownloadingList(BuildContext context) {
    return ValueListenableBuilder<List<DownloadGroup>>(
      valueListenable: logic.downloadingList,
      builder: (_, groups, __) {
        final expandedList = groups.map((e) => e.url).toList();
        return StreamBuilder<DownloadTask?>(
          stream: download.downloadProgress,
          builder: (_, snap) {
            return Column(
              children: [
                if (groups.isNotEmpty)
                  _buildDownloadingListHead(groups, snap.data),
                Expanded(
                  child: DownloadRecordListView(
                    groupList: groups,
                    initialExpanded: expandedList,
                    downloadTask: snap.data ?? DownloadTask(),
                    onRemoveRecords: (records) =>
                        _showDeleteDialog(context, records),
                    onStartDownloads: (records) async {
                      // 当检查网络状态并且处于流量模式，弹窗未继续则直接返回
                      if (logic.checkNetwork.value &&
                          await Tool.checkNetworkInMobile() &&
                          !await _showNetworkStatusDialog(context)) return;
                      download.startTasks(records);
                    },
                    onStopDownloads: download.stopTasks,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 构建下载队列头部
  Widget _buildDownloadingListHead(
      List<DownloadGroup> groups, DownloadTask? task) {
    final padding =
        const EdgeInsets.symmetric(horizontal: 14).copyWith(top: 18, right: 8);
    final textStyle = TextStyle(color: kPrimaryColor, fontSize: 20);
    final totalSpeed = '${FileTool.formatSize(task?.totalSpeed ?? 0)}/s';
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(totalSpeed, style: textStyle),
          const Spacer(),
          IconButton(
            onPressed: () => download.stopTasks(
                groups.expand<DownloadRecord>((e) => e.records).toList()),
            icon: const Icon(FontAwesomeIcons.pause),
            color: kPrimaryColor,
          ),
          IconButton(
            onPressed: () async {
              // 当检查网络状态并且处于流量模式，弹窗未继续则直接返回
              if (logic.checkNetwork.value &&
                  await Tool.checkNetworkInMobile() &&
                  !await _showNetworkStatusDialog(context)) return;
              download.startTasks(
                  groups.expand<DownloadRecord>((e) => e.records).toList());
            },
            icon: const Icon(FontAwesomeIcons.play),
            color: kPrimaryColor,
          ),
        ],
      ),
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

  // 展示网络状态提示dialog
  Future<bool> _showNetworkStatusDialog(BuildContext context) {
    return MessageDialog.show<bool>(
      context,
      title: const Text('流量提醒'),
      content: const Text('当前正在使用手机流量下载，是否继续？'),
      actionLeft: TextButton(
        child: const Text('不再提醒'),
        onPressed: () {
          cache.setBool(Common.checkNetworkStatusKey, false);
          logic.checkNetwork.setValue(false);
          router.pop(true);
        },
      ),
      actionMiddle: TextButton(
        child: const Text('取消'),
        onPressed: () => router.pop(false),
      ),
      actionRight: TextButton(
        child: const Text('继续下载'),
        onPressed: () {
          logic.checkNetwork.setValue(false);
          router.pop(true);
        },
      ),
    ).then((v) => v ?? false);
  }
}

/*
* 下载管理页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class _DownloadLogic extends BaseLogic {
  // 下载队列
  final downloadingList = ListValueChangeNotifier<DownloadGroup>.empty();

  // 已下载记录
  final downloadedList = ListValueChangeNotifier<DownloadGroup>.empty();

  // 是否检查网络状态
  final checkNetwork = ValueChangeNotifier<bool>(
      cache.getBool(Common.checkNetworkStatusKey) ?? true);

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
    return groupList..sort((l, r) => l.updateTime.compareTo(r.updateTime));
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
