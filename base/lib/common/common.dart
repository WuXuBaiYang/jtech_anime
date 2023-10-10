import 'dart:math';

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
        // 'packages/jtech_anime_base/assets/anime/status_loading1.json',
        // 'packages/jtech_anime_base/assets/anime/status_loading2.json',
        'packages/jtech_anime_base/assets/anime/status_loading3.json',
        // 'packages/jtech_anime_base/assets/anime/status_loading4.json',
      ][Random().nextInt(1)];

  // 动画-空内容
  static const String statusEmptyAsset =
      'packages/jtech_anime_base/assets/anime/status_empty.json';

  // 动画-错误
  static const String statusErrorAsset =
      'packages/jtech_anime_base/assets/anime/status_error.json';
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

  // 番剧解析js缓存目录
  static const String animeParserCachePath = 'anime_parser_cache';
}
