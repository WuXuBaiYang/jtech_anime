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

  // 协议
  String protocol = '';

  // 域名
  String host = '';

  // 端口
  int port = 80;

  // 完整代理
  @Ignore()
  String get proxy => '$protocol://$host:$port';

  // 从json加载
  static ProxyRecord from(obj) {
    return ProxyRecord()
      ..protocol = obj['protocol'] ?? ''
      ..host = obj['host'] ?? ''
      ..port = obj['port'] ?? '';
  }

  // 转换为json
  Map<String, dynamic> toJson() => {
        'protocol': protocol,
        'host': host,
        'port': port,
      };
}
