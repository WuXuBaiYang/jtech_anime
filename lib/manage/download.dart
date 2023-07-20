import 'package:jtech_anime/common/manage.dart';

/*
* 下载管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DownloadManage extends BaseManage {
  static final DownloadManage _instance = DownloadManage._internal();

  factory DownloadManage() => _instance;

  DownloadManage._internal();

  // 队列表

  @override
  Future<void> init() async {}
}

// 单例调用
final download = DownloadManage();
