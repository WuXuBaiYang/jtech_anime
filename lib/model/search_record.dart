import 'package:isar/isar.dart';

part 'search_record.g.dart';

@collection
class SearchRecord {
  Id id = Isar.autoIncrement;

  // 搜索内容
  @Index(type: IndexType.hash)
  String keyword = '';

  // 搜索热度
  int heat = 0;
}
