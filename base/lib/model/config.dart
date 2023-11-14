import 'package:flutter/foundation.dart';
import 'package:jtech_anime_base/tool/screen_type.dart';

/*
* 全局配置
* @author wuxubaiyang
* @Time 2023/9/25 9:16
*/
class JTechConfig with Diagnosticable {
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

  // 是否展示debug日志
  final bool showDebugLog;

  // 当前屏幕类型
  final ScreenType screenType;

  JTechConfig({
    required this.screenType,
    this.baseCachePath = '',
    this.showDebugLog = true,
    this.noPictureMode = false,
    this.noPlayerContent = true,
    this.loadingDismissible = false,
    this.m3u8DownloadBatchSize = 25,
  });

  copyWith({
    bool? loadingDismissible,
    bool? noPictureMode,
    bool? noPlayerContent,
    String? baseCachePath,
    int? m3u8DownloadBatchSize,
    bool? showDebugLog,
    ScreenType? screenType,
  }) {
    return JTechConfig(
      loadingDismissible: loadingDismissible ?? this.loadingDismissible,
      noPictureMode: noPictureMode ?? this.noPictureMode,
      noPlayerContent: noPlayerContent ?? this.noPlayerContent,
      baseCachePath: baseCachePath ?? this.baseCachePath,
      m3u8DownloadBatchSize:
          m3u8DownloadBatchSize ?? this.m3u8DownloadBatchSize,
      showDebugLog: showDebugLog ?? this.showDebugLog,
      screenType: screenType ?? this.screenType,
    );
  }
}

/*
* 全局自定义样式
* @author wuxubaiyang
* @Time 2023/9/25 9:16
*/
class JTechThemeData with Diagnosticable {
  // 状态组件默认尺寸
  final double statusSize;

  // 加载弹窗默认尺寸
  final double loadingSize;

  JTechThemeData({
    this.statusSize = 120,
    this.loadingSize = 100,
  });

  copyWith({
    double? statusSize,
    double? loadingSize,
  }) {
    return JTechThemeData(
      statusSize: statusSize ?? this.statusSize,
      loadingSize: loadingSize ?? this.loadingSize,
    );
  }
}
