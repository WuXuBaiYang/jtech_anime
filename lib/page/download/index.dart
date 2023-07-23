import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/snack.dart';

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
      // 初始化加载完成下载记录
      logic.loadDownloadRecords(context, false);
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
        ),
        body: TabBarView(children: [
          _buildDownloadingList(),
          _buildDownloadRecordList(),
        ]),
      ),
    );
  }

  // 构建下载队列
  Widget _buildDownloadingList() {
    return SizedBox();
  }

  // 构建下载记录列表
  Widget _buildDownloadRecordList() {
    return SizedBox();
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
        status: DownloadRecordStatus.values
          ..remove(DownloadRecordStatus.complete),
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
      SnackTool.showMessage(context, message: '下载记录加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 更新下载队列
  void _updateDownloadingList(Map<String, DownloadRecord> downloadMap) {
    return downloadingList.setValue(downloadingList.value
        .map((e) => downloadMap[e.downloadUrl] ?? e)
        .toList());
  }
}
