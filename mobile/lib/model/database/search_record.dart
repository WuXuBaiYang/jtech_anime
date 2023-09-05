import 'package:isar/isar.dart';

part 'search_record.g.dart';

/*
* 搜索记录
* @author wuxubaiyang
* @Time 2023/7/13 16:06
*/
@collection
class SearchRecord {
  Id id = Isar.autoIncrement;

  // 搜索内容
  @Index(type: IndexType.hash)
  String keyword = '';

  // 搜索热度
  int heat = 0;
}
