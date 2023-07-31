import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/download_record.dart';
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

  @override
  void initState() {
    super.initState();
    // 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 监听下载完成事件
      download.addDownloadCompleteListener((record) {
        // 移除下载列表
        logic.downloadingList.removeValue(record);
        // 刷新下载完成队列
        logic.loadDownloadRecords(context, false);
      });
      // 请求通知权限
      PermissionTool.checkNotification(context);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('番剧缓存'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              tabs: [Tab(text: '下载队列'), Tab(text: '已下载')],
            ),
          ),
        ),
        body: TabBarView(children: [
          _buildDownloadingList(),
          _buildDownloadRecordList(context),
        ]),
      ),
    );
  }

  // 构建下载队列
  Widget _buildDownloadingList() {
    const status = [DownloadRecordStatus.download, DownloadRecordStatus.fail];
    return ValueListenableBuilder<List<DownloadRecord>>(
      valueListenable: logic.downloadingList,
      builder: (_, recordList, __) {
        return Column(
          children: [
            if (recordList.isNotEmpty) _buildDownloadingHead(recordList),
            Expanded(
              child: DownloadRecordList(
                recordList: recordList,
                onTaskLongTap: (item) =>
                    _showDeleteDialog(context, [item], logic.downloadingList),
                onAnimeLongTap: (item) => logic
                    .getAnimeDownloadRecord(item, status: status)
                    .then((items) => _showDeleteDialog(
                        context, items, logic.downloadingList)),
                onTaskTap: (item) => item.task != null
                    ? download.stopTask(item)
                    : download.startTask(item.copyWith()),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建下载队列头部
  Widget _buildDownloadingHead(List<DownloadRecord> recordList) {
    final padding =
        const EdgeInsets.symmetric(horizontal: 14).copyWith(top: 18);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          _buildDownloadTotalSpeed(),
          const Spacer(),
          IconButton(
            onPressed: download.stopAllTasks,
            icon: const Icon(FontAwesomeIcons.pause),
            color: kPrimaryColor,
          ),
          IconButton(
            onPressed: () => download.startTasks(
              recordList.map((e) => e.copyWith()).toList(),
            ),
            icon: const Icon(FontAwesomeIcons.play),
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  // 构建下载总速度
  Widget _buildDownloadTotalSpeed() {
    return ValueListenableBuilder<int>(
      valueListenable: download.totalSpeed,
      builder: (_, totalSpeed, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('${FileTool.formatSize(totalSpeed)}/s',
              style: TextStyle(color: kPrimaryColor, fontSize: 20)),
        );
      },
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
    // 监听下载队列
    download.downloadQueue.addListener(updateDownloadingList);
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

  // 更新下载队列
  void updateDownloadingList() {
    final downloadMap = download.downloadQueue.value;
    downloadingList.setValue(downloadingList.value
        .map((e) => downloadMap[e.downloadUrl] ?? (e..task = null))
        .toList());
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
      return items
          .map((e) => e.downloadUrl)
          .where((e) => values[i++])
          .toList();
    }).then((records) {
      return notifier.removeWhere(
        (e) => records.contains(e.downloadUrl),
      );
    });
  }
}
