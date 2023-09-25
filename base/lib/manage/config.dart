import 'package:jtech_anime_base/common/manage.dart';
import 'package:jtech_anime_base/model/config.dart';

/*
* 全局配置管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class GlobalConfigManage extends BaseManage {
  static final GlobalConfigManage _instance = GlobalConfigManage._internal();

  factory GlobalConfigManage() => _instance;

  GlobalConfigManage._internal();

  // 配置缓存
  JTechAnimeConfig? _config;

  // 样式缓存
  JTechAnimeThemeData? _theme;

  // 设置全局配置与样式
  void setup({
    JTechAnimeConfig? config,
    JTechAnimeThemeData? theme,
  }) {
    _config = config;
    _theme = theme;
  }

  // 获取配置
  JTechAnimeConfig get config => _config ?? JTechAnimeConfig();

  // 设置配置
  void setConfig(JTechAnimeConfig config) => _config = config;

  // 获取样式
  JTechAnimeThemeData get theme => _theme ?? JTechAnimeThemeData();

  // 设置样式
  void setTheme(JTechAnimeThemeData theme) => _theme = theme;

  // 判断是否为无图模式
  bool get isNoPictureMode => config.noPictureMode;

  // 获取状态组件默认尺寸
  double get defaultStatusSize => config.defaultStatusSize;

  // 获取加载弹窗默认尺寸
  double get defaultLoadingSize => config.defaultLoadingSize;

  // 获取加载弹窗是否可取消
  bool get loadingDismissible => config.loadingDismissible;
}

// 单例调用
final globalConfig = GlobalConfigManage();
