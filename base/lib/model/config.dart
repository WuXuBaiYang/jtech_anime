import 'package:flutter/foundation.dart';

/*
* 全局配置基类
* @author wuxubaiyang
* @Time 2023/10/20 10:24
*/
abstract class BaseJTechConfig with Diagnosticable {}

/*
* 全局样式基类
* @author wuxubaiyang
* @Time 2023/10/20 10:25
*/
abstract class BaseJTechThemeData with Diagnosticable {}

/*
* 全局配置
* @author wuxubaiyang
* @Time 2023/9/25 9:16
*/
class RootJTechConfig extends BaseJTechConfig {
  // 加载弹窗是否可取消
  final bool loadingDismissible;

  // 是否无图模式
  final bool noPictureMode;

  // 是否展示播放器内容
  final bool noPlayerContent;

  // 基础缓存路径
  final String baseCachePath;

  // m3u8文件下载时的并发数
  final int m3u8DownloadBatchSize;

  RootJTechConfig({
    this.loadingDismissible = false,
    this.noPictureMode = false,
    this.noPlayerContent = true,
    this.baseCachePath = '',
    this.m3u8DownloadBatchSize = 30,
  });

  copyWith({
    bool? loadingDismissible,
    bool? noPictureMode,
    bool? noPlayerContent,
    String? baseCachePath,
    int? m3u8DownloadBatchSize,
  }) {
    return RootJTechConfig(
      loadingDismissible: loadingDismissible ?? this.loadingDismissible,
      noPictureMode: noPictureMode ?? this.noPictureMode,
      noPlayerContent: noPlayerContent ?? this.noPlayerContent,
      baseCachePath: baseCachePath ?? this.baseCachePath,
      m3u8DownloadBatchSize:
          m3u8DownloadBatchSize ?? this.m3u8DownloadBatchSize,
    );
  }
}

/*
* 全局自定义样式
* @author wuxubaiyang
* @Time 2023/9/25 9:16
*/
class RootJTechThemeData extends BaseJTechThemeData {
  // 状态组件默认尺寸
  final double statusSize;

  // 加载弹窗默认尺寸
  final double loadingSize;

  RootJTechThemeData({
    this.statusSize = 120,
    this.loadingSize = 100,
  });

  copyWith({
    double? statusSize,
    double? loadingSize,
  }) {
    return RootJTechThemeData(
      statusSize: statusSize ?? this.statusSize,
      loadingSize: loadingSize ?? this.loadingSize,
    );
  }
}
