import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/download.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/tool/loading.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/future_builder.dart';

/*
* 资源下载弹窗
* @author wuxubaiyang
* @Time 2023/7/22 11:19
*/
class DownloadSheet extends StatefulWidget {
  // 番剧信息
  final AnimeModel animeInfo;

  const DownloadSheet({super.key, required this.animeInfo});

  static Future<void> show(BuildContext context,
      {required AnimeModel animeInfo}) {
    return showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      context: context,
      builder: (_) {
        return DownloadSheet(animeInfo: animeInfo);
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
    return DefaultTabController(
      length: widget.animeInfo.resources.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResourceTab(),
          const Divider(color: Colors.white, thickness: 0.1, height: 1),
          Expanded(child: _buildResourceTabView()),
        ],
      ),
    );
  }

  // 构建资源分类tab
  Widget _buildResourceTab() {
    return Row(
      children: [
        TabBar(
          isScrollable: true,
          indicatorColor: kPrimaryColor,
          dividerColor: Colors.transparent,
          tabs: List.generate(widget.animeInfo.resources.length, (i) {
            return Tab(text: '资源${i + 1}');
          }),
        ),
        const Spacer(),
        ValueListenableBuilder<List<ResourceItemModel>>(
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
                  onPressed:
                      selectList.isNotEmpty ? () => _addDownloadTask() : null,
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
      ],
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final selected = selectList.contains(item);
          final downloaded = downloadMap.containsKey(item.url);
          return ChoiceChip(
            avatar:
                downloaded ? const Icon(FontAwesomeIcons.circleCheck) : null,
            selected: selected,
            label: Text(item.name),
            onSelected: !downloaded
                ? (v) => selected
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
    final result = await db.getDownloadRecordList(
      parserHandle.currentSource,
      animeList: [widget.animeInfo.url],
    );
    return result.asMap().map((_, v) => MapEntry(v.resUrl, v));
  }

  // 添加下载任务
  void _addDownloadTask() {
    final title = ValueChangeNotifier<String>('正在解析~');
    Loading.show<List<bool>>(
      title: title,
      loadFuture: parserHandle
          // 获取视频缓存
          .getAnimeVideoCache(
            selectResources.value,
            progress: (count, total) => title.setValue('正在解析($count/$total)'),
          )
          // 将视频缓存封装为下载记录结构
          .then((videoCaches) => videoCaches.map((e) => DownloadRecord()
            ..title = widget.animeInfo.name
            ..cover = widget.animeInfo.cover
            ..url = widget.animeInfo.url
            ..source = parserHandle.currentSource
            ..resUrl = e.url
            ..downloadUrl = e.playUrl
            ..name = e.item?.name ?? ''))
          // 使用下载记录启动下载
          .then((records) => Future.wait(records.map(download.startTask))),
    )?.then((results) {
      final success = results?.where((e) => e).length ?? 0;
      final fail = (results?.length ?? 0) - success;
      SnackTool.showMessage(message: '已添加到下载，成功 $success 个/失败 $fail 个');
    }).whenComplete(() => cacheController.refreshValue());
  }
}
