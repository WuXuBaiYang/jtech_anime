import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/model/time_table.dart';
import 'package:jtech_anime/widget/status_box.dart';

// 时间表点击回调
typedef AnimeTimeTableTap = void Function(TimeTableItemModel item);

/*
* 番剧时间表
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class AnimeTimeTable extends StatefulWidget {
  // 时间表点击回调
  final AnimeTimeTableTap? onTap;

  const AnimeTimeTable({super.key, this.onTap});

  @override
  State<AnimeTimeTable> createState() => _AnimeTimeTableState();
}

class _AnimeTimeTableState extends State<AnimeTimeTable> {
  // 周/天下标
  final int _weekday = DateTime.now().weekday - 1;

  // 周/天换算表
  final _weekdayMap = <IconData, String>{
    FontAwesomeIcons.faceDizzy: '周一',
    FontAwesomeIcons.faceFrown: '周二',
    FontAwesomeIcons.faceFlushed: '周三',
    FontAwesomeIcons.faceGrimace: '周四',
    FontAwesomeIcons.faceGrinStars: '周五',
    FontAwesomeIcons.faceLaughWink: '周六',
    FontAwesomeIcons.faceSadTear: '周日',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: StatusBoxCacheFuture<List<List<TimeTableItemModel>>>(
          future: parserHandle.loadAnimeTimeTable,
          builder: (dataList) {
            return DefaultTabController(
              initialIndex: _weekday,
              length: dataList.length,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(dataList.length),
                  Expanded(child: _buildTabView(dataList)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 构建时间表TabBar
  Widget _buildTabBar(int length) {
    return TabBar(
      isScrollable: true,
      tabs: List.generate(length, (i) {
        final item = _weekdayMap.entries.elementAt(i);
        return Tab(
          child: Row(
            children: [
              Text(item.value),
              const SizedBox(width: 4),
              Icon(item.key, size: 14),
            ],
          ),
        );
      }),
    );
  }

  // 构建时间表tabView
  Widget _buildTabView(List<List<TimeTableItemModel>> data) {
    return TabBarView(
      children: List.generate(data.length, (i) {
        final items = data[i];
        return ListView.builder(
          primary: false,
          itemCount: items.length,
          padding: EdgeInsets.zero,
          itemBuilder: (_, i) {
            final item = items[i];
            final updateIcon = item.isUpdate
                ? const Icon(
                    FontAwesomeIcons.seedling,
                    color: Colors.green,
                    size: 18,
                  )
                : null;
            return ListTile(
              dense: true,
              trailing: updateIcon,
              title: Text(item.name),
              subtitle: Text(item.status),
              onTap: () => widget.onTap?.call(item),
            );
          },
        );
      }),
    );
  }
}
