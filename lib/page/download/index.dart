import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/download.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/download.dart';
import 'package:jtech_anime/page/download/list.dart';
import 'package:jtech_anime/tool/file.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/permission.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/message_dialog.dart';
import 'package:jtech_anime/widget/refresh/refresh_view.dart';

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
class _DownloadPageState extends LogicState<DownloadPage, _DownloadLogic> {
  @override
  _DownloadLogic initLogic() => _DownloadLogic();

  // 分页控制表
  late Map<String, Widget Function(BuildContext context)> tabsMap = {
    '下载队列': _buildDownloadingList,
    '已下载': _buildDownloadRecordList,
  };

  @override
  void initState() {
    super.initState();
    // 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 监听下载完成事件
      download.addDownloadCompleteListener((record) {
        // 移除下载列表
        logic.downloadingList.removeWhere((e) {
          return e.downloadUrl == record.downloadUrl;
        });
        // 刷新下载完成队列
        logic.loadDownloadRecords(context, false);
      });
      // 请求通知权限
      PermissionTool.checkNotification(context);
      // 主动推送一次最新的下载进度
      download.pushLatestProgress();
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    final tabs = tabsMap.keys.map((e) => Tab(text: e)).toList();
    final views = tabsMap.values.map((e) => e.call(context)).toList();
    return DefaultTabController(
      length: tabsMap.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('番剧缓存'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(tabs: tabs),
          ),
        ),
        body: TabBarView(children: views),
      ),
    );
  }

  // 构建下载队列
  Widget _buildDownloadingList(BuildContext context) {
    const status = [DownloadRecordStatus.download, DownloadRecordStatus.fail];
    return ValueListenableBuilder<List<DownloadRecord>>(
      valueListenable: logic.downloadingList,
      builder: (_, recordList, __) {
        return StreamBuilder<DownloadTask?>(
          stream: download.downloadProgress,
          builder: (_, snap) {
            return Column(
              children: [
                if (recordList.isNotEmpty)
                  _buildDownloadingHead(recordList, snap.data),
                Expanded(
                  child: DownloadRecordList(
                    recordList: recordList,
                    downloadTask: snap.data,
                    onTaskLongTap: (item) => _showDeleteDialog(
                        context, [item], logic.downloadingList),
                    onAnimeLongTap: (item) => logic
                        .getAnimeDownloadRecord(item, status: status)
                        .then((items) => _showDeleteDialog(
                            context, items, logic.downloadingList)),
                    onTaskTap: download.toggleTask,
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
  Widget _buildDownloadingHead(
      List<DownloadRecord> recordList, DownloadTask? task) {
    final padding =
        const EdgeInsets.symmetric(horizontal: 14).copyWith(top: 18);
    final textStyle = TextStyle(color: kPrimaryColor, fontSize: 20);
    final totalSpeed = '${FileTool.formatSize(task?.totalSpeed ?? 0)}/s';
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(totalSpeed, style: textStyle),
          const Spacer(),
          IconButton(
            onPressed: () => download.stopTasks(recordList),
            icon: const Icon(FontAwesomeIcons.pause),
            color: kPrimaryColor,
          ),
          IconButton(
            onPressed: () => download.startTasks(recordList),
            icon: const Icon(FontAwesomeIcons.play),
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  // 构建下载记录列表
  Widget _buildDownloadRecordList(BuildContext context) {
    const status = [DownloadRecordStatus.complete];
    return ValueListenableBuilder<List<DownloadRecord>>(
      valueListenable: logic.downloadRecordList,
      builder: (_, recordList, __) {
        return CustomRefreshView(
          enableRefresh: true,
          enableLoadMore: true,
          initialRefresh: true,
          child: DownloadRecordList(
            recordList: recordList,
            onTaskLongTap: (item) =>
                _showDeleteDialog(context, [item], logic.downloadRecordList),
            onAnimeLongTap: (item) => logic
                .getAnimeDownloadRecord(item, status: status)
                .then((items) => _showDeleteDialog(
                    context, items, logic.downloadRecordList)),
            onTaskTap: (item) => router.pushNamed(
              RoutePath.animeDetail,
              arguments: {
                'animeDetail': AnimeModel(
                  url: item.url,
                  name: item.name,
                  cover: item.cover,
                ),
                'downloadRecord': item,
              },
            ),
          ),
          onRefresh: (loadMore) => logic.loadDownloadRecords(context, loadMore),
        );
      },
    );
  }

  // 展示删除弹窗
  Future<void> _showDeleteDialog(
    BuildContext context,
    List<DownloadRecord> items,
    ListValueChangeNotifier<DownloadRecord> notifier,
  ) {
    final item = items.firstOrNull;
    final content =
        '是否删除 ${item?.title} ${item?.name} ${items.length > 1 ? '等${items.length}条下载记录' : ''}';
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
          logic.removeDownloadRecord(items, notifier);
          router.pop();
        },
      ),
    );
  }
}

/*
* 下载管理页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class _DownloadLogic extends BaseLogic {
  // 下载队列
  final downloadingList = ListValueChangeNotifier<DownloadRecord>.empty();

  // 已下载记录
  final downloadRecordList = ListValueChangeNotifier<DownloadRecord>.empty();

  // 当前页码
  int _pageIndex = 1;

  @override
  void init() {
    super.init();
    // 获取下载队列基础数据
    loadDownloadingList();
  }

  // 获取下载队列列表
  Future<void> loadDownloadingList() async {
    try {
      final results = await db.getDownloadRecordList(
        parserHandle.currentSource,
        // 最大可显示下载队列为999
        pageSize: 999,
        status: [
          DownloadRecordStatus.download,
          DownloadRecordStatus.fail,
        ],
      );
      downloadingList.setValue(results);
    } catch (e) {
      LogTool.e('获取下载记录失败', error: e);
    }
  }

  // 获取下载记录
  Future<void> loadDownloadRecords(BuildContext context, bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final index = loadMore ? _pageIndex + 1 : 1;
      final result = await db.getDownloadRecordList(
        status: [DownloadRecordStatus.complete],
        parserHandle.currentSource,
        pageIndex: index,
      );
      if (result.isNotEmpty) {
        _pageIndex = index;
        return loadMore
            ? downloadRecordList.addValues(result)
            : downloadRecordList.setValue(result);
      }
    } catch (e) {
      SnackTool.showMessage(message: '下载记录加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 获取番剧对应的下载任务
  Future<List<DownloadRecord>> getAnimeDownloadRecord(DownloadRecord item,
      {List<DownloadRecordStatus> status = const []}) {
    return db.getDownloadRecordList(
      item.source,
      pageSize: 999,
      status: status,
      animeList: [item.url],
    );
  }

  // 删除下载记录
  Future<void> removeDownloadRecord(List<DownloadRecord> items,
      ListValueChangeNotifier<DownloadRecord> notifier) {
    int i = 0;
    return download.removeTasks(items).then((values) {
      return items.map((e) => e.downloadUrl).where((e) => values[i++]).toList();
    }).then((records) {
      return notifier.removeWhere(
        (e) => records.contains(e.downloadUrl),
      );
    });
  }
}
