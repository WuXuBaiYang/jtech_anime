import 'package:jtech_anime_base/common/manage.dart';
import 'package:jtech_anime_base/model/config.dart';

/*
* 配置管理基类
* @author wuxubaiyang
* @Time 2023/10/20 10:26
*/
abstract class BaseConfigManage<C extends BaseJTechConfig,
    T extends BaseJTechThemeData> extends BaseManage {
  // 缓存配置
  C? _config;

  // 缓存样式
  T? _theme;

  // 设置全局配置样式
  void setup({C? config, T? theme}) {
    _config = config;
    _theme = theme;
  }

  // 创建默认配置
  C createDefaultConfig();

  // 获取配置
  C get config => _config ??= createDefaultConfig();

  // 设置配置
  void setConfig(C config) => _config = config;

  // 创建默认样式
  T createDefaultTheme();

  // 获取样式
  T get theme => _theme ??= createDefaultTheme();

  // 设置样式
  void setTheme(T theme) => _theme = theme;
}

/*
* 全局配置管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class RootConfigManage
    extends BaseConfigManage<RootJTechConfig, RootJTechThemeData> {
  static final RootConfigManage _instance = RootConfigManage._internal();

  factory RootConfigManage() => _instance;

  RootConfigManage._internal();

  @override
  RootJTechConfig createDefaultConfig() => RootJTechConfig();

  @override
  RootJTechThemeData createDefaultTheme() => RootJTechThemeData();

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
}

// 单例调用
final rootConfig = RootConfigManage();
