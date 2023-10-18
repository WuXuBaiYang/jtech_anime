import 'package:desktop/model/event.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 资源下载弹窗
* @author wuxubaiyang
* @Time 2023/7/22 11:19
*/
class DownloadSheet extends StatefulWidget {
  // tab控制器
  final TabController? tabController;

  // 排序方向变化
  final ValueChangeNotifier<bool> sortUp;

  // 番剧信息
  final ValueChangeNotifier<AnimeModel> animeInfo;

  const DownloadSheet({
    super.key,
    required this.animeInfo,
    required this.sortUp,
    this.tabController,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChangeNotifier<AnimeModel> animeInfo,
    required ValueChangeNotifier<bool> sortUp,
    TabController? tabController,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return DownloadSheet(
          sortUp: sortUp,
          animeInfo: animeInfo,
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
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 220,
          ),
          child: _buildResourceTab(),
        ),
        const Spacer(),
        ValueListenableBuilder<bool>(
          valueListenable: widget.sortUp,
          builder: (_, sortUp, __) {
            return IconButton(
              iconSize: 24,
              icon: Icon(sortUp
                  ? FontAwesomeIcons.arrowUpShortWide
                  : FontAwesomeIcons.arrowDownWideShort),
              onPressed: () => widget.sortUp.setValue(!sortUp),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 构建资源分类tab
  Widget _buildResourceTab() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<AnimeModel>(
        valueListenable: widget.animeInfo,
        builder: (_, animeInfo, __) {
          return CustomTabBar(
            isScrollable: true,
            controller: widget.tabController,
            overlayColor: Colors.transparent,
            tabs: List.generate(animeInfo.resources.length, (i) {
              return Tab(text: '资源${i + 1}', height: 35);
            }),
          );
        },
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
        return ValueListenableBuilder2<AnimeModel, List<ResourceItemModel>>(
          first: widget.animeInfo,
          second: selectResources,
          builder: (_, animeInfo, selectList, __) {
            final resources = animeInfo.resources;
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
          final avatar = downloaded
              ? const Icon(
                  FontAwesomeIcons.circleCheck,
                  size: 14,
                )
              : null;
          return ChoiceChip(
            avatar: avatar,
            selected: selected,
            label: Text(item.name),
            clipBehavior: Clip.antiAlias,
            labelPadding: (selected || avatar != null)
                ? const EdgeInsets.only(left: 4)
                : null,
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
    final animeInfo = widget.animeInfo.value;
    return db.getDownloadRecordList(
      source,
      animeList: [animeInfo.url],
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
    final animeInfo = widget.animeInfo.value;
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
              ..url = animeInfo.url
              ..title = animeInfo.name
              ..cover = animeInfo.cover)
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
        event.send(NewDownloadEvent(downloadRecords: downloadRecords));
        SnackTool.showMessage(message: message);
        cacheController.refreshValue();
        selectResources.setValue([]);
        router.pop();
      }),
    )?.catchError((_) {
      SnackTool.showMessage(message: '资源解析异常,请更换资源重试');
    });
  }
}
