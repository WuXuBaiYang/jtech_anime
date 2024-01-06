/*
* 屏幕类型
* @author wuxubaiyang
* @Time 2023/11/14 13:50
*/
enum ScreenType { mobile, pad, desktop, fusion }

/*
* 扩展屏幕类型方法
* @author wuxubaiyang
* @Time 2023/11/14 13:51
*/
extension ScreenTypeExtension on ScreenType {
  // 是否是移动端
  bool get isMobile => this == ScreenType.mobile;

  // 是否是平板
  bool get isPad => this == ScreenType.pad;

  // 是否是桌面端
  bool get isDesktop => this == ScreenType.desktop;

  // 是否是融合端
  bool get isFusion => this == ScreenType.fusion;
}
