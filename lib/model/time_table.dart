import 'package:jtech_anime/common/model.dart';

/*
* 番剧时间表
* @author wuxubaiyang
* @Time 2023/8/10 15:59
*/
class TimeTableModel extends BaseModel {
  // 周一
  final List<TimeTableItemModel> monday;

  // 周二
  final List<TimeTableItemModel> tuesday;

  // 周三
  final List<TimeTableItemModel> wednesday;

  // 周四
  final List<TimeTableItemModel> thursday;

  // 周五
  final List<TimeTableItemModel> friday;

  // 周六
  final List<TimeTableItemModel> saturday;

  // 周七
  final List<TimeTableItemModel> sunday;

  TimeTableModel.from(obj)
      : monday = (obj['monday'] ?? []).map(TimeTableItemModel.from).toList(),
        tuesday = (obj['tuesday'] ?? []).map(TimeTableItemModel.from).toList(),
        wednesday =
            (obj['wednesday'] ?? []).map(TimeTableItemModel.from).toList(),
        thursday =
            (obj['thursday'] ?? []).map(TimeTableItemModel.from).toList(),
        friday = (obj['friday'] ?? []).map(TimeTableItemModel.from).toList(),
        saturday =
            (obj['saturday'] ?? []).map(TimeTableItemModel.from).toList(),
        sunday = (obj['sunday'] ?? []).map(TimeTableItemModel.from).toList();

  // 根据下标获取对应周天的番剧列表
  List<TimeTableItemModel> getAnimeListByWeekday(int weekday) =>
      [monday, tuesday, wednesday, thursday, friday, saturday, sunday][weekday];
}

/*
* 番剧时间表子项
* @author wuxubaiyang
* @Time 2023/7/7 10:51
*/
class TimeTableItemModel extends BaseModel {
  // 名字
  String name;

  // 地址
  String url;

  // 状态
  String status;

  // 最近是否更新
  bool isUpdate;

  TimeTableItemModel.from(obj)
      : name = obj['name'] ?? '',
        url = obj['url'] ?? '',
        status = obj['status'] ?? '',
        isUpdate = obj['isUpdate'] ?? false;
}
