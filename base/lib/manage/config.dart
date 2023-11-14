import 'package:jtech_anime_base/common/manage.dart';
import 'package:jtech_anime_base/model/config.dart';
import 'package:jtech_anime_base/tool/screen_type.dart';

/*
* 配置管理基类
* @author wuxubaiyang
* @Time 2023/10/20 10:26
*/
class ConfigManage extends BaseManage {
  static final ConfigManage _instance = ConfigManage._internal();

  factory ConfigManage() => _instance;

  ConfigManage._internal();

  // 缓存配置
  JTechConfig? _config;

  // 缓存样式
  JTechThemeData? _theme;

  // 设置全局配置样式
  void setup(JTechConfig config, JTechThemeData theme) {
    _config = config;
    _theme = theme;
  }

  // 获取当前配置
  JTechConfig get config =>
      _config ?? JTechConfig(screenType: ScreenType.mobile);

  // 获取当前样式
  JTechThemeData get theme => _theme ?? JTechThemeData();

  // 判断是否为无图模式
  bool get isNoPictureMode => config.noPictureMode;

  // 判断是否为无播放模式
  bool get isNoPlayerContent => config.noPlayerContent;

  // 获取加载弹窗是否可取消
  bool get loadingDismissible => config.loadingDismissible;

  // 获取基础缓存路径
  String get baseCachePath => config.baseCachePath;

  // 获取m3u8文件下载时的并发数
  int get m3u8DownloadBatchSize => config.m3u8DownloadBatchSize;

  // 获取是否展示debug日志
  bool get showDebugLog => config.showDebugLog;

  // 获取当前屏幕类型
  ScreenType get screenType => config.screenType;
}

// 单例调用
final rootConfig = ConfigManage();
