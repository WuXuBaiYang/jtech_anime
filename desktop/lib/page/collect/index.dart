import 'package:desktop/common/route.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页番剧收藏页面
* @author wuxubaiyang
* @Time 2023/9/11 15:00
*/
class HomeCollectPage extends StatefulWidget {
  const HomeCollectPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeCollectPageState();
}

/*
* 首页番剧收藏列表页面-状态
* @author wuxubaiyang
* @Time 2023/9/11 15:00
*/
class _HomeCollectPageState
    extends LogicState<HomeCollectPage, _HomeCollectLogic> {
  @override
  _HomeCollectLogic initLogic() => _HomeCollectLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: _buildCollectList(),
    );
  }

  // 构建收藏列表
  Widget _buildCollectList() {
    return CustomRefreshView(
      enableRefresh: true,
      enableLoadMore: true,
      header: CustomRefreshViewHeader.classic,
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
                    title: Text('还没有喜欢的番剧~'),
                    animSize: 100,
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

  // 构建收藏列表项
  Widget _buildCollectListItem(Collect item, int i) {
    const titleStyle = TextStyle(fontSize: 16, color: Colors.black87);
    const subTitleStyle = TextStyle(fontSize: 12, color: Colors.black38);
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
* 首页番剧收藏列表页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/11 15:00
*/
class _HomeCollectLogic extends BaseLogic {
  // 收藏列表
  final collectList = ListValueChangeNotifier<Collect>.empty();

  // 当前页码
  int _pageIndex = 1;

  @override
  void init() {
    super.init();
    // 初始化加载收藏列表
    loadCollectList(false);
  }

  // 加载收藏列表
  Future<void> loadCollectList(bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final index = loadMore ? _pageIndex + 1 : 1;
      final source = animeParser.currentSource;
      if (source == null) throw Exception('数据源不存在');
      final result = await db.getCollectList(source, pageIndex: index);
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
            ..id = result?.id ?? dbAutoIncrementId);
    } catch (e) {
      SnackTool.showMessage(
          message: '${item.id == dbAutoIncrementId ? '收藏' : '取消收藏'}失败，请重试~');
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
            ..id = result?.id ?? dbAutoIncrementId);
    } catch (e) {
      SnackTool.showMessage(message: '收藏状态更新失败，请重试~');
    }
  }

  // 更新收藏项排序
  Future<void> updateCollectOrder(Collect item, int to) async {
    try {
      final source = animeParser.currentSource;
      if (source == null) return;
      await db.updateCollectOrder(item.url, source: source, to: to);
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
