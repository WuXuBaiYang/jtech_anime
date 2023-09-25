import 'package:flutter/foundation.dart';

/*
* 全局配置
* @author wuxubaiyang
* @Time 2023/9/25 9:16
*/
class JTechAnimeConfig with Diagnosticable {
  // 状态组件默认尺寸
  final double defaultStatusSize;

  // 加载弹窗默认尺寸
  final double defaultLoadingSize;

  // 加载弹窗是否可取消
  final bool loadingDismissible;

  // 是否无图模式
  final bool noPictureMode;

  // 基础缓存路径
  final String baseCachePath;

  JTechAnimeConfig({
    this.defaultStatusSize = 120,
    this.defaultLoadingSize = 100,
    this.loadingDismissible = false,
    this.noPictureMode = false,
    this.baseCachePath = '',
  });

  copyWith({
    double? defaultStatusSize,
    double? defaultLoadingSize,
    bool? loadingDismissible,
    bool? noPictureMode,
    String? baseCachePath,
  }) {
    return JTechAnimeConfig(
      defaultStatusSize: defaultStatusSize ?? this.defaultStatusSize,
      defaultLoadingSize: defaultLoadingSize ?? this.defaultLoadingSize,
      loadingDismissible: loadingDismissible ?? this.loadingDismissible,
      noPictureMode: noPictureMode ?? this.noPictureMode,
      baseCachePath: baseCachePath ?? this.baseCachePath,
    );
  }
}

/*
* 全局自定义样式
* @author wuxubaiyang
* @Time 2023/9/25 9:16
*/
class JTechAnimeThemeData with Diagnosticable {}
