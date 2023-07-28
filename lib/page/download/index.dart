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
import 'package:jtech_anime/tool/snack.dart';
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
          actions: [
            _buildDownloadTotalSpeed(),
          ],
        ),
        body: TabBarView(children: [
          _buildDownloadingList(),
          _buildDownloadRecordList(context),
        ]),
      ),
    );
  }

  // 构建下载总速度
  Widget _buildDownloadTotalSpeed() {
    return ValueListenableBuilder(
      valueListenable: logic.downloadingList,
      builder: (_, recordList, __) {
        if (recordList.isEmpty) return const SizedBox();
        int? totalSpeed;
        recordList
            .where((e) => e.task != null)
            .map((e) => e.task!.speed)
            .forEach((e) => totalSpeed = (totalSpeed ?? 0) + e);
        if (totalSpeed == null) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('${FileTool.formatSize(totalSpeed!)}/s',
              style: TextStyle(color: kPrimaryColor, fontSize: 20)),
        );
      },
    );
  }

  // 构建下载队列
  Widget _buildDownloadingList() {
    return ValueListenableBuilder<List<DownloadRecord>>(
      valueListenable: logic.downloadingList,
      builder: (_, recordList, __) {
        return Column(
          children: [
            if (recordList.isNotEmpty) _buildDownloadingHead(recordList),
            Expanded(
              child: DownloadRecordList(
                recordList: recordList,
                onTaskTap: (item) {
                  (item.task != null && item.task!.downloading)
                      ? download.stopTask(item)
                      : download.startTask(item.copyWith());
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建下载队列头部
  Widget _buildDownloadingHead(List<DownloadRecord> recordList) {
    const padding = EdgeInsets.only(top: 18, left: 14, right: 4);
    final downloadCount = download.downloadQueue.length;
    final prepareCount = download.prepareQueue.length;
    final canPause = downloadCount != 0 || prepareCount != 0;
    final canPlay = downloadCount + prepareCount < recordList.length;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text('$downloadCount / $prepareCount / ${recordList.length}',
              style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const Spacer(),
          IconButton(
            onPressed: canPause ? () => download.stopAllTasks() : null,
            icon: const Icon(FontAwesomeIcons.pause),
            color: kPrimaryColor,
          ),
          IconButton(
            onPressed: canPlay
                ? () => download
                    .startAllTasks(recordList.map((e) => e.copyWith()).toList())
                : null,
            icon: const Icon(FontAwesomeIcons.play),
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  // 构建下载记录列表
  Widget _buildDownloadRecordList(BuildContext context) {
    return ValueListenableBuilder<List<DownloadRecord>>(
      valueListenable: logic.downloadRecordList,
      builder: (_, recordList, __) {
        return CustomRefreshView(
          enableRefresh: true,
          enableLoadMore: true,
          initialRefresh: true,
          child: DownloadRecordList(
            recordList: recordList,
            onTaskTap: (item) =>
                router.pushNamed(RoutePath.animeDetail, arguments: {
              'animeDetail': AnimeModel(
                url: item.url,
                name: item.name,
                cover: item.cover,
              ),
              'downloadRecord': item,
            }),
          ),
          onRefresh: (loadMore) => logic.loadDownloadRecords(context, loadMore),
        );
      },
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
    // 监听下载队列与等待队列
    download.downloadQueue.addListener(
        () => _updateDownloadingList(download.downloadQueue.value));
    download.prepareQueue.addListener(
        () => _updateDownloadingList(download.downloadQueue.value));
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
  void _updateDownloadingList(Map<String, DownloadRecord> downloadMap) {
    return downloadingList.setValue(downloadingList.value
        .map((e) => downloadMap[e.downloadUrl] ?? (e..task = null))
        .toList());
  }
}
