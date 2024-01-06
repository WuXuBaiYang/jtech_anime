import 'package:isar/isar.dart';

part 'filter_select.g.dart';

@collection
class FilterSelect {
  Id id = Isar.autoIncrement;

  // 夫分类名称
  String parentName = '';

  // 子分类名称
  String name = '';

  // 父分类key
  @Index(type: IndexType.hash)
  String key = '';

  // 子分类值
  @Index(type: IndexType.hash)
  String value = '';

  // 过滤数据源
  @Index(type: IndexType.hash)
  String source = '';
}
