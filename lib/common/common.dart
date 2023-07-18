/*
* 静态资源/通用静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:54
*/
class Common {
  // app名称
  static const String appName = '看番咩?';

  // 动画-加载动
  static const String statusLoadingAsset = 'assets/anime/status_loading.json';

  // 动画-空内容
  static const String statusEmptyAsset = 'assets/anime/status_empty.json';

  // 动画-错误
  static const String statusErrorAsset = 'assets/anime/status_error.json';
}

/*
* 目录管理
* @author wuxubaiyang
* @Time 2022/9/9 17:57
*/
class FileDirPath {
  // 图片缓存路径
  static const String imageCachePath = 'imageCache';

  // 视频缓存路径
  static const String videoCachePath = 'videoCache';

  // 音频缓存路径
  static const String audioCachePath = 'audioCache';
}
