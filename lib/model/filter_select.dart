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
  String key = '';

  // 子分类值
  String value = '';
}
