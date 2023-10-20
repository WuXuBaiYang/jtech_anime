import 'package:jtech_anime_base/base.dart';

/*
* 平台配置
* @author wuxubaiyang
* @Time 2023/10/20 10:38
*/
class JTechConfig extends RootJTechConfig {
  JTechConfig({
    super.loadingDismissible,
    super.noPictureMode,
    super.noPlayerContent,
    super.baseCachePath,
    super.m3u8DownloadBatchSize,
  });
}

/*
* 平台样式
* @author wuxubaiyang
* @Time 2023/10/20 10:39
*/
class JTechThemeData extends RootJTechThemeData {
  JTechThemeData({
    super.statusSize,
    super.loadingSize,
  });
}
