import 'package:jtech_anime/common/model.dart';

/*
* 番剧时间表
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
