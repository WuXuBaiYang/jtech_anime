import 'package:isar/isar.dart';

part 'collect.g.dart';

@collection
class Collect {
  Id id = Isar.autoIncrement;

  // 番剧地址
  @Index(type: IndexType.hash)
  String url = '';

  // 数据源
  @Index(type: IndexType.hash)
  String source = '';

  // 番剧名称
  String name = '';

  // 番剧封面
  String cover = '';

  // 排序
  int order = 0;
}
