import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/widget/anime_list.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 首页番剧时间表
* @author wuxubaiyang
* @Time 2023/8/29 10:58
*/
class HomeAnimeTimeTable extends StatefulWidget {
  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 番剧时间表对象
  final TimeTableModel? timeTable;

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
  // 滚动控制器
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final timeTable = widget.timeTable;
    if (timeTable == null) {
      return const Center(
        child: StatusBox(
          status: StatusBoxStatus.loading,
        ),
      );
    }
    // 获取本周周一
    final now = DateTime.now();
    final days = Duration(days: now.weekday - 1);
    final monday = now.subtract(days);
    int index = 0;
    _jump2CurrentDay();
    return CustomScrollView(
      controller: controller,
      slivers: timeTable.weekdayAnimeList
          .map<List<Widget>>((e) {
            final today = monday.add(Duration(days: index++));
            final weekdayKey = _weekdayKeys[today.weekday - 1];
            return [
              _buildHeader(today, weekdayKey),
              _buildAnimeList(e),
            ];
          })
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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverList.builder(
        itemCount: animeList.length,
        itemBuilder: (_, i) {
          return _buildAnimeListItem(animeList[i]);
        },
      ),
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

  // 跳转到今天
  void _jump2CurrentDay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext =
          _weekdayKeys[DateTime.now().weekday - 1].currentContext;
      if (currentContext == null) return;
      Scrollable.ensureVisible(currentContext);
    });
  }

  @override
  bool get wantKeepAlive => true;
}
