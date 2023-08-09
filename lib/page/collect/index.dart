import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:isar/isar.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/collect.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/refresh/refresh_view.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 收藏页
* @author wuxubaiyang
* @Time 2023/7/12 9:11
*/
class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<StatefulWidget> createState() => _CollectPageState();
}

/*
* 收藏页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:11
*/
class _CollectPageState extends LogicState<CollectPage, _CollectLogic> {
  @override
  _CollectLogic initLogic() => _CollectLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: _buildCollectList(),
    );
  }

  // 构建收藏列表
  Widget _buildCollectList() {
    return CustomRefreshView(
      enableRefresh: true,
      enableLoadMore: true,
      initialRefresh: true,
      onRefresh: (loadMore) => logic.loadCollectList(loadMore),
      child: ValueListenableBuilder<List<Collect>>(
        valueListenable: logic.collectList,
        builder: (_, collectList, __) {
          return Stack(
            children: [
              if (collectList.isEmpty)
                const Center(
                  child: StatusBox(
                    status: StatusBoxStatus.empty,
                    title: Text('还有收藏记录~'),
                  ),
                ),
              StatefulBuilder(builder: (_, setState) {
                return ReorderableListView.builder(
                  itemCount: collectList.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) => setState(() {
                    // 更新排序到数据库
                    if (oldIndex < newIndex) newIndex -= 1;
                    final oldItem = collectList[oldIndex];
                    final newItem = collectList[newIndex];
                    logic.updateCollectOrder(oldItem, newItem.order);
                    // 更新本地列表排序
                    var child = collectList.removeAt(oldIndex);
                    collectList.insert(newIndex, child);
                  }),
                  itemBuilder: (_, i) {
                    final item = collectList[i];
                    return _buildCollectListItem(item, i);
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 16, color: Colors.black87);

  // 内容文本样式
  final subTitleStyle = const TextStyle(fontSize: 12, color: Colors.black38);

  // 构建收藏列表项
  Widget _buildCollectListItem(Collect item, int i) {
    return InkWell(
      key: ValueKey(item),
      child: DefaultTextStyle(
        maxLines: 2,
        style: subTitleStyle,
        overflow: TextOverflow.ellipsis,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageView.net(item.cover,
                    width: 80, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(item.name, style: titleStyle),
                    const SizedBox(height: 8),
                    IconButton(
                      color: kPrimaryColor,
                      icon: Icon(item.collected
                          ? FontAwesomeIcons.heartCircleCheck
                          : FontAwesomeIcons.heart),
                      onPressed: () => logic.updateCollect(item, i),
                    ),
                  ],
                ),
              ),
              ReorderableDragStartListener(
                  index: i, child: const Icon(FontAwesomeIcons.gripLines)),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      onTap: () => logic.goDetail(item, i),
    );
  }
}

/*
* 收藏页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:11
*/
class _CollectLogic extends BaseLogic {
  // 收藏列表
  final collectList = ListValueChangeNotifier<Collect>.empty();

  // 当前页码
  int _pageIndex = 1;

  // 加载收藏列表
  Future<void> loadCollectList(bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final index = loadMore ? _pageIndex + 1 : 1;
      final result = await db.getCollectList(
        parserHandle.currentSource,
        pageIndex: index,
      );
      if (result.isNotEmpty) {
        _pageIndex = index;
        return loadMore
            ? collectList.addValues(result)
            : collectList.setValue(result);
      }
    } catch (e) {
      SnackTool.showMessage(message: '收藏列表加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 更新收藏状态（收藏/取消收藏）
  Future<void> updateCollect(Collect item, int index) async {
    try {
      final result = await db.updateCollect(item);
      collectList.putValue(
          index,
          item
            ..collected = result != null
            ..id = result?.id ?? Isar.autoIncrement);
    } catch (e) {
      SnackTool.showMessage(
          message: '${item.id == Isar.autoIncrement ? '收藏' : '取消收藏'}失败，请重试~');
    }
  }

  // 更新收藏状态（获取最新的状态进行更新）
  Future<void> updateCollectStatus(Collect item, int index) async {
    try {
      final result = await db.getCollect(item.url);
      collectList.putValue(
          index,
          item
            ..collected = result != null
            ..id = result?.id ?? Isar.autoIncrement);
    } catch (e) {
      SnackTool.showMessage(message: '收藏状态更新失败，请重试~');
    }
  }

  // 更新收藏项排序
  Future<void> updateCollectOrder(Collect item, int to) async {
    try {
      await db.updateCollectOrder(item.url,
          source: parserHandle.currentSource, to: to);
    } catch (e) {
      SnackTool.showMessage(message: '排序更新失败,请重试~');
    }
  }

  // 跳转到详情页
  Future<void>? goDetail(Collect item, int i) {
    return router.pushNamed(RoutePath.animeDetail, arguments: {
      'animeDetail': AnimeModel(
        url: item.url,
        name: item.name,
        cover: item.cover,
      ),
    })?.then((_) => updateCollectStatus(item, i));
  }
}
