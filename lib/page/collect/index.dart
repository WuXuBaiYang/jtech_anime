import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
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
      body: _buildCollectList(context),
    );
  }

  // 构建收藏列表
  Widget _buildCollectList(BuildContext context) {
    return CustomRefreshView(
      enableRefresh: true,
      enableLoadMore: true,
      initialRefresh: true,
      onRefresh: (loadMore) => logic.loadCollectList(context, loadMore),
      child: ValueListenableBuilder<List<Collect>>(
        valueListenable: logic.collectList,
        builder: (_, collectList, __) {
          return Stack(
            children: [
              if (collectList.isEmpty)
                const Center(
                  child: StatusBox(
                    status: StatusBoxStatus.empty,
                    title: Text('还没有播放记录~'),
                  ),
                ),
              ListView.builder(
                itemCount: collectList.length,
                itemBuilder: (_, i) {
                  final item = collectList[i];
                  return _buildCollectListItem(context, item);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 14, color: Colors.black87);

  // 内容文本样式
  final subTitleStyle = const TextStyle(fontSize: 12, color: Colors.black38);

  // 构建收藏列表项
  Widget _buildCollectListItem(BuildContext context, Collect item) {
    return InkWell(
      child: DefaultTextStyle(
        maxLines: 2,
        style: subTitleStyle,
        overflow: TextOverflow.ellipsis,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageView.net(item.cover,
                    width: 80, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(item.name, style: titleStyle),
                    // const SizedBox(height: 18),
                    // Text(item.resName, style: TextStyle(color: kPrimaryColor)),
                    // const SizedBox(height: 8),
                    // Text('播放至：${progress.format(DurationPattern.fullTime)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => router.pushNamed(RoutePath.animeDetail, arguments: {
        'animeDetail': AnimeModel(
          url: item.url,
          name: item.name,
          cover: item.cover,
        ),
        'playTheRecord': true,
      })?.then((_) => logic.loadCollectList(context, false)),
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
  var _pageIndex = 1;

  // 加载收藏列表
  Future<void> loadCollectList(BuildContext context, bool loadMore) async {
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
      SnackTool.showMessage(context, message: '收藏列表加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }
}
