import 'package:jtech_anime_base/base.dart';
import 'package:screen_fusion/model/config.dart';

/*
* 平台配置管理
* @author wuxubaiyang
* @Time 2023/10/20 10:39
*/
class PlatformConfigManage
    extends BaseConfigManage<JTechConfig, JTechThemeData> {
  static final PlatformConfigManage _instance =
      PlatformConfigManage._internal();

  factory PlatformConfigManage() => _instance;

  PlatformConfigManage._internal();

  @override
  JTechConfig createDefaultConfig() => JTechConfig();

  @override
  JTechThemeData createDefaultTheme() => JTechThemeData();
}

// 单例调用
final platformConfig = PlatformConfigManage();
