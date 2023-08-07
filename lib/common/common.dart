import 'dart:math';

import 'package:jtech_anime/tool/file.dart';

/*
* 静态资源/通用静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:54
*/
class Common {
  // app名称
  static const String appName = '看番咩?';

  // 动画-加载动画
  static String get statusLoadingAsset => [
        'assets/anime/status_loading1.json',
        'assets/anime/status_loading2.json',
        'assets/anime/status_loading3.json',
        'assets/anime/status_loading4.json',
      ][Random().nextInt(4)];

  // 动画-空内容
  static const String statusEmptyAsset = 'assets/anime/status_empty.json';

  // 动画-错误
  static const String statusErrorAsset = 'assets/anime/status_error.json';

  // 是否检查网络状态
  static const String checkNetworkStatusKey = 'check_network_status';

  // 视频缓存根目录
  static const FileDir videoCacheRoot = FileDir.applicationDocuments;

  // m3u8视频中需要忽略的碎片列表（插入的广告）
  static const List<String> m3u8FileIgnores = [
    '1o357.ts',
    '1o358.ts',
    '1o359.ts',
    '1o360.ts',
    '1o361.ts',
  ];
}

/*
* 目录管理
* @author wuxubaiyang
* @Time 2022/9/9 17:57
*/
class FileDirPath {
  // 图片缓存路径
  static const String imageCachePath = 'image_cache';

  // 视频缓存路径
  static const String videoCachePath = 'video_cache';

  // 音频缓存路径
  static const String audioCachePath = 'audio_cache';
}
