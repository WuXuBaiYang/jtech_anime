/*
* 安卓通知相关字段
* @author wuxubaiyang
* @Time 2022/3/29 10:46
*/
class AndroidNotificationConfig {
  // 渠道id
  final String? channelId;

  // 渠道名称
  final String? channelName;

  // 渠道描述
  final String? channelDescription;

  // 图标
  final String? icon;

  // 是否播放声音
  final bool playSound;

  // 是否启用震动
  final bool enableVibration;

  // 分组key
  final String? groupKey;

  // 是否聚合分组信息
  final bool setAsGroupSummary;

  // 是否自动取消
  final bool autoCancel;

  // 是否常驻显示
  final bool ongoing;

  // 是否仅显示单次
  final bool onlyAlertOnce;

  // 是否启用灯光
  final bool enableLights;

  // 超时后取消
  final Duration? timeoutAfter;

  // 定时显示
  final Duration? when;

  // 是否显示渠道标记
  final bool channelShowBadge;

  // 是否显示进度条
  final bool showProgress;

  // 进度条最大进度
  final int maxProgress;

  // 进度条进度
  final int progress;

  // 进度条无进度状态
  final bool indeterminate;

  const AndroidNotificationConfig({
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.channelShowBadge = false,
    this.icon,
    this.playSound = true,
    this.enableVibration = true,
    this.groupKey,
    this.setAsGroupSummary = true,
    this.autoCancel = false,
    this.ongoing = false,
    this.onlyAlertOnce = false,
    this.enableLights = true,
    this.timeoutAfter,
    this.when,
    this.showProgress = false,
    this.maxProgress = 0,
    this.progress = 0,
    this.indeterminate = true,
  });
}

/*
* IOS通知相关字段
* @author wuxubaiyang
* @Time 2021/8/31 2:06 下午
*/
class IOSNotificationConfig {
  // 是否通知
  final bool? presentAlert;

  // 是否标记
  final bool? presentBadge;

  // 是否有声音
  final bool? presentSound;

  // 声音文件
  final String? sound;

  // 标记数字
  final int? badgeNumber;

  // 子标题
  final String? subtitle;

  // 线程标识
  final String? threadIdentifier;

  const IOSNotificationConfig({
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.sound,
    this.badgeNumber,
    this.subtitle,
    this.threadIdentifier,
  });
}
