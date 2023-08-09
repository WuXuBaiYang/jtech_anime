import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download/download.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/tool/loading.dart';
import 'package:jtech_anime/tool/permission.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/message_dialog.dart';

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
      clipBehavior: Clip.hardEdge,
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () => router.pop(),
        ),
        title: const Text('番剧缓存'),
        actions: [
          TextButton(
            onPressed: () => router
                .pushNamed(RoutePath.download)
                ?.then((_) => cacheController.refreshValue()),
            child: const Text('缓存管理'),
          ),
          _buildSubmitButton(context),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildResourceTab(),
        ),
      ),
      body: _buildResourceTabView(),
    );
  }

  // 构建提交按钮
  Widget _buildSubmitButton(BuildContext context) {
    return ValueListenableBuilder<List<ResourceItemModel>>(
      valueListenable: selectResources,
      builder: (_, selectList, __) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (selectList.isNotEmpty)
              Text(
                '${selectList.length}',
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 10),
              ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.check),
              onPressed: selectList.isNotEmpty
                  ? () => _addDownloadTask(context)
                  : null,
            ),
          ],
        );
      },
    );
  }

  // 构建资源分类tab
  Widget _buildResourceTab() {
    final resources = widget.animeInfo.resources;
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        isScrollable: true,
        indicatorColor: kPrimaryColor,
        controller: widget.tabController,
        dividerColor: Colors.transparent,
        tabs: List.generate(resources.length, (i) {
          return Tab(text: '资源${i + 1}');
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
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
  Future<Map<String, DownloadRecord>> _loadDownloadRecordMap() {
    return db.getDownloadRecordList(
      parserHandle.currentSource,
      animeList: [widget.animeInfo.url],
    ).then((v) => v.asMap().map((_, v) => MapEntry(v.resUrl, v)));
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
          widget.checkNetwork.setValue(false);
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
          widget.checkNetwork.setValue(false);
          router.pop(true);
        },
      ),
    ).then((v) => v ?? false);
  }

  // 添加下载任务
  Future<void> _addDownloadTask(BuildContext context) async {
    // 当检查网络状态并且处于流量模式，弹窗未继续则直接返回
    if (widget.checkNetwork.value &&
        await Tool.checkNetworkInMobile() &&
        !await _showNetworkStatusDialog(context)) return;
    final title = ValueChangeNotifier<String>('');
    title.setValue('正在解析(1/${selectResources.length})');
    return Loading.show<void>(
      title: title,
      loadFuture: Future(() async {
        final selectList = selectResources.value;
        // 获取视频缓存
        final videoCaches = await parserHandle.getAnimeVideoCache(
          progress: (count, total) => title.setValue('正在解析($count/$total)'),
          selectList..sort((l, r) => l.order.compareTo(r.order)),
        );
        // 将视频缓存封装为下载记录结构
        final downloadRecords = videoCaches
            .map((e) => DownloadRecord()
              ..title = widget.animeInfo.name
              ..cover = widget.animeInfo.cover
              ..url = widget.animeInfo.url
              ..source = parserHandle.currentSource
              ..resUrl = e.url
              ..downloadUrl = e.playUrl
              ..name = e.item?.name ?? ''
              ..order = e.item?.order ?? 0)
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
    );
  }
}
