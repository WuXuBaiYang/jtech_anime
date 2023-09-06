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

  // 是否已收藏
  @ignore
  bool collected = true;

  Collect copyWith({
    Id? id,
    String? url,
    String? source,
    String? name,
    String? cover,
    int? order,
    bool? collected,
  }) =>
      Collect()
        ..id = id ?? this.id
        ..url = url ?? this.url
        ..source = source ?? this.source
        ..name = name ?? this.name
        ..cover = cover ?? this.cover
        ..order = order ?? this.order
        ..collected = collected ?? this.collected;

  @override
  bool operator ==(Object other) {
    if (other is! Collect) return false;
    return runtimeType == other.runtimeType &&
        id == other.id &&
        url == other.url &&
        source == other.source &&
        name == other.name &&
        cover == other.cover &&
        order == other.order &&
        collected == other.collected;
  }

  @override
  int get hashCode =>
      id.hashCode +
      url.hashCode +
      source.hashCode +
      name.hashCode +
      cover.hashCode +
      order.hashCode +
      collected.hashCode;
}
