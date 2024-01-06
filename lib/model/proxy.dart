import 'package:isar/isar.dart';

part 'proxy.g.dart';

/*
* 代理记录
* @author wuxubaiyang
* @Time 2023/10/23 11:09
*/
@Collection()
class ProxyRecord {
  Id id = Isar.autoIncrement;

  // 域名
  String host = '';

  // 端口
  int port = 7890;

  // 完成代理地址
  @Index(type: IndexType.hash, unique: true)
  String proxy = '';

  // 从json加载
  static ProxyRecord from(obj) {
    return ProxyRecord()
      ..host = obj['host'] ?? ''
      ..port = obj['port'] ?? ''
      ..proxy = obj['proxy'] ?? '';
  }

  // 转换为json
  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'proxy': proxy,
      };
}
