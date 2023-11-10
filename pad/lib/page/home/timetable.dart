import 'package:flutter/material.dart';
import 'package:pad/widget/anime_list.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页番剧时间表
* @author wuxubaiyang
* @Time 2023/8/29 10:58
*/
class HomeAnimeTimeTable extends StatefulWidget {
  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 番剧时间表对象
  final TimeTableModel timeTable;

  const HomeAnimeTimeTable({
    super.key,
    required this.timeTable,
    this.itemTap,
  });

  @override
  State<StatefulWidget> createState() => _HomeAnimeTimeTableState();
}

/*
* 首页番剧时间表-状态
* @author wuxubaiyang
* @Time 2023/8/29 10:58
*/
class _HomeAnimeTimeTableState extends State<HomeAnimeTimeTable>
    with AutomaticKeepAliveClientMixin {
  // 控制器
  final controller = ScrollController();

  // 生成本周7天的日期
  late List<DateTime> weekdayTime;

  @override
  void initState() {
    super.initState();
    // 生成一周7天的具体日期
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    weekdayTime = List.generate(7, (i) => monday.add(Duration(days: i)));
    // 组件初始化后加载
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 跳转到当前周天
      final context = _weekdayKeys[DateTime.now().weekday - 1].currentContext;
      if (context != null) await Scrollable.ensureVisible(context);
      controller.jumpTo(controller.position.pixels);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      controller: controller,
      slivers: widget.timeTable.weekdayAnimeList
          .asMap()
          .map((i, v) {
            final dateTime = weekdayTime[i];
            final weekdayKey = _weekdayKeys[dateTime.weekday - 1];
            return MapEntry(i, [
              _buildHeader(dateTime, weekdayKey),
              _buildAnimeList(v),
            ]);
          })
          .values
          .expand((e) => e)
          .toList(),
    );
  }

  // 周天数字对照表
  List<GlobalObjectKey> get _weekdayKeys => [
        const GlobalObjectKey('周一'),
        const GlobalObjectKey('周二'),
        const GlobalObjectKey('周三'),
        const GlobalObjectKey('周四'),
        const GlobalObjectKey('周五'),
        const GlobalObjectKey('周六'),
        const GlobalObjectKey('周日'),
      ];

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
      onTap: () => widget.itemTap?.call(AnimeModel.from({
        'name': item.name,
        'url': item.url,
        'status': item.status,
      })),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
