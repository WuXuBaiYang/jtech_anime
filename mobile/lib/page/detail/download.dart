import 'package:flutter/material.dart';
import 'package:mobile/common/route.dart';
import 'package:mobile/tool/network.dart';
import 'package:mobile/tool/permission.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 资源下载弹窗
* @author wuxubaiyang
* @Time 2023/7/22 11:19
*/
class DownloadSheet extends StatefulWidget {
  // 是否检查网络状态
  final ValueChangeNotifier<bool> checkNetwork;

  // tab控制器
  final TabController? tabController;

  // 番剧信息
  final AnimeModel animeInfo;

  const DownloadSheet({
    super.key,
    required this.animeInfo,
    required this.checkNetwork,
    this.tabController,
  });

  static Future<void> show(
    BuildContext context, {
    required AnimeModel animeInfo,
    required ValueChangeNotifier<bool> checkNetwork,
    TabController? tabController,
  }) {
    PermissionTool.checkNotification(context);
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return DownloadSheet(
          animeInfo: animeInfo,
          checkNetwork: checkNetwork,
          tabController: tabController,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _DownloadSheetState();
}

/*
* 资源下载弹窗-状态
* @author wuxubaiyang
* @Time 2023/7/22 11:23
*/
class _DownloadSheetState extends State<DownloadSheet> {
  // 已选资源回调
  final selectResources = ListValueChangeNotifier<ResourceItemModel>.empty();

  // 缓存控制器
  final cacheController =
      CacheFutureBuilderController<Map<String, DownloadRecord>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildResourceOptions(),
          const Divider(),
          Expanded(child: _buildResourceTabView()),
        ],
      ),
      floatingActionButton: _buildResourceSelectFAB(),
    );
  }

  // 构建资源操作交互栏
  Widget _buildResourceOptions() {
    return Row(
      children: [
        Expanded(child: _buildResourceTab()),
        TextButton(
          onPressed: () => router
              .pushNamed(RoutePath.download)
              ?.then((_) => cacheController.refreshValue()),
          child: const Text('缓存管理'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 构建资源分类tab
  Widget _buildResourceTab() {
    final resources = widget.animeInfo.resources;
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomTabBar(
        isScrollable: true,
        controller: widget.tabController,
        tabs: List.generate(resources.length, (i) {
          return Tab(text: '资源${i + 1}', height: 35);
        }),
      ),
    );
  }

  // 构建动漫资源列表
  Widget _buildResourceTabView() {
    return CacheFutureBuilder<Map<String, DownloadRecord>>(
      controller: cacheController,
      future: _loadDownloadRecordMap,
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();
        final downloadMap = snap.data!;
        final resources = widget.animeInfo.resources;
        return ValueListenableBuilder<List<ResourceItemModel>>(
          valueListenable: selectResources,
          builder: (_, selectList, __) {
            return TabBarView(
              controller: widget.tabController,
              children: List.generate(resources.length, (i) {
                final items = resources[i];
                return _buildResourceTabViewItem(
                    items, downloadMap, selectList);
              }),
            );
          },
        );
      },
    );
  }

  // 构建资源分页列表页面子项
  Widget _buildResourceTabViewItem(
    List<ResourceItemModel> items,
    Map<String, DownloadRecord> downloadMap,
    List<ResourceItemModel> selectList,
  ) {
    const padding = EdgeInsets.all(8);
    return SingleChildScrollView(
      padding: selectList.isNotEmpty
          ? padding.copyWith(bottom: kToolbarHeight * 1.5)
          : padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final selected = selectList.contains(item);
          final downloaded = downloadMap.containsKey(item.url);
          final avatar =
              downloaded ? const Icon(FontAwesomeIcons.circleCheck) : null;
          return ChoiceChip(
            avatar: avatar,
            selected: selected,
            label: Text(item.name),
            onSelected: !downloaded
                ? (_) => selected
                    ? selectResources.removeValue(item)
                    : selectResources.addValue(item)
                : null,
          );
        }),
      ),
    );
  }

  // 加载下载记录表
  Future<Map<String, DownloadRecord>> _loadDownloadRecordMap() async {
    final source = animeParser.currentSource;
    if (source == null) return {};
    return db.getDownloadRecordList(
      source,
      animeList: [widget.animeInfo.url],
    ).then((v) => v.asMap().map((_, v) => MapEntry(v.resUrl, v)));
  }

  // 构建资源选择fab
  Widget _buildResourceSelectFAB() {
    return ValueListenableBuilder<List<ResourceItemModel>>(
      valueListenable: selectResources,
      builder: (_, selectList, __) {
        return AnimatedScale(
          scale: selectList.isNotEmpty ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: FloatingActionButton.extended(
            label: Text('已选 ${selectList.length} 项'),
            extendedTextStyle: const TextStyle(fontSize: 14),
            icon: const Icon(FontAwesomeIcons.download, size: 24),
            onPressed: () => _addDownloadTask(context),
          ),
        );
      },
    );
  }

  // 添加下载任务
  Future<void> _addDownloadTask(BuildContext context) async {
    // 当检查网络状态并且处于流量模式，弹窗未继续则直接返回
    if (!await Network.checkNetwork(context, widget.checkNetwork)) return;
    return Loading.show<void>(
      loadFuture: Future(() async {
        final source = animeParser.currentSource;
        if (source == null) return;
        final selectList = selectResources.value;
        // 获取视频缓存
        final videoCaches = await animeParser.getPlayUrls(
            selectList..sort((l, r) => l.order.compareTo(r.order)));
        if (videoCaches.isEmpty) throw Exception('视频加载失败');
        // 将视频缓存封装为下载记录结构
        final downloadRecords = videoCaches
            .map((e) => DownloadRecord()
              ..resUrl = e.url
              ..source = source.key
              ..downloadUrl = e.playUrl
              ..name = e.item?.name ?? ''
              ..order = e.item?.order ?? 0
              ..url = widget.animeInfo.url
              ..title = widget.animeInfo.name
              ..cover = widget.animeInfo.cover)
            .toList();
        // 使用下载记录启动下载
        final results = await download.startTasks(downloadRecords);
        // 反馈下载结果
        final successCount = results.where((e) => e).length;
        final failCount = results.length - successCount;
        final message = successCount <= 0
            ? '未能成功添加下载任务'
            : '已成功添加 $successCount 条任务'
                '${failCount > 0 ? '，失败 $failCount 条' : ''}';
        SnackTool.showMessage(message: message);
        cacheController.refreshValue();
        selectResources.setValue([]);
      }),
    )?.catchError((_) {
      SnackTool.showMessage(message: '资源解析异常,请更换资源重试');
    });
  }
}
