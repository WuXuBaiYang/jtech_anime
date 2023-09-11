import 'package:desktop/common/route.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页新番时间轴页面
* @author wuxubaiyang
* @Time 2023/9/11 14:30
*/
class HomeTimeTablePage extends StatefulWidget {
  const HomeTimeTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeTimeTablePageState();
}

/*
* 首页新番时间轴页面-状态
* @author wuxubaiyang
* @Time 2023/9/11 14:30
*/
class _HomeTimeTablePageState
    extends LogicState<HomeTimeTablePage, _HomeTimeTableLogic> {
  @override
  _HomeTimeTableLogic initLogic() => _HomeTimeTableLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: _buildTimeTable(),
    );
  }

  // 构建番剧时间表
  Widget _buildTimeTable() {
    return StatusBoxCacheFuture<TimeTableModel?>(
      animSize: 100,
      controller: logic.controller,
      future: animeParser.getTimeTable,
      builder: (timeTable) {
        if (timeTable == null) return const SizedBox();
        return CustomScrollView(
          controller: logic.scrollController,
          slivers: timeTable.weekdayAnimeList
              .asMap()
              .map((i, v) {
                final dateTime = logic.weekdayTime[i];
                final weekdayKey = logic.weekdayKeys[dateTime.weekday - 1];
                return MapEntry(i, [
                  _buildHeader(dateTime, weekdayKey),
                  _buildAnimeList(v),
                ]);
              })
              .values
              .expand((e) => e)
              .toList(),
        );
      },
    );
  }

  // 构建周天头部
  Widget _buildHeader(DateTime dateTime, GlobalObjectKey key) {
    final text = '${dateTime.format(DatePattern.date)} · ${key.value}';
    return SliverList.list(key: key, children: [
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(child: Divider(color: kPrimaryColor)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: kPrimaryColor)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: kPrimaryColor)),
        ],
      ),
      const SizedBox(height: 14),
    ]);
  }

  // 构建周天番剧列表
  Widget _buildAnimeList(List<TimeTableItemModel> animeList) {
    return SliverList.builder(
      itemCount: animeList.length,
      itemBuilder: (_, i) {
        return _buildAnimeListItem(animeList[i]);
      },
    );
  }

  // 构建番剧列表子项
  Widget _buildAnimeListItem(TimeTableItemModel item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.status),
      trailing: item.isUpdate
          ? const Text('new',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ))
          : null,
      onTap: () => logic.goDetail(AnimeModel.from({
        'name': item.name,
        'url': item.url,
        'status': item.status,
      })),
    );
  }
}

/*
* 首页新番时间轴页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/11 14:30
*/
class _HomeTimeTableLogic extends BaseLogic {
  // 番剧时间表控制器
  final controller = CacheFutureBuilderController<TimeTableModel?>();

  // 滚动控制器
  final scrollController = ScrollController();

  // 生成本周7天的日期
  late List<DateTime> weekdayTime;

  // 周天数字对照表
  List<GlobalObjectKey> get weekdayKeys => [
        const GlobalObjectKey('周一'),
        const GlobalObjectKey('周二'),
        const GlobalObjectKey('周三'),
        const GlobalObjectKey('周四'),
        const GlobalObjectKey('周五'),
        const GlobalObjectKey('周六'),
        const GlobalObjectKey('周日'),
      ];

  @override
  void init() {
    super.init();
    // 监听解析源切换
    event.on<SourceChangeEvent>().listen((_) async {
      controller.refreshValue();
    });
    // 生成一周7天的具体日期
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    weekdayTime = List.generate(7, (i) => monday.add(Duration(days: i)));
    // 组件初始化后加载
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 跳转到当前周天
      final context = weekdayKeys[DateTime.now().weekday - 1].currentContext;
      if (context != null) await Scrollable.ensureVisible(context);
      scrollController.jumpTo(scrollController.position.pixels);
    });
  }

  // 跳转到详情
  Future<void>? goDetail(AnimeModel item) {
    return router.pushNamed(
      RoutePath.animeDetail,
      arguments: {'animeDetail': item},
    );
  }
}
