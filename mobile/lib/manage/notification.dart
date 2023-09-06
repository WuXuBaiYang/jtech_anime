import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jtech_anime_base/base.dart';

// 当收到消息通知时的回调
typedef OnNotificationReceive = Future Function(
    int id, String? title, String? body, String? payload);

// 当通知消息被点击触发时
typedef OnNotificationSelect = Future Function(String? payload);

/*
* 本地通知管理
* @author wuxubaiyang
* @Time 2022/3/29 10:46
*/
class NotificationManage extends BaseManage {
  static final NotificationManage _instance = NotificationManage._internal();

  factory NotificationManage() => _instance;

  NotificationManage._internal();

  // 默认图标名称
  final String _defaultIconName = 'ic_launcher';

  // 接受通知消息回调集合
  final List<OnNotificationReceive> _notificationReceiveListeners = [];

  // 通知推送管理
  FlutterLocalNotificationsPlugin? _localNotification;

  // 通知栏初始化状态记录
  bool? _initialized;

  @override
  Future<void> init() async {
    _localNotification ??= FlutterLocalNotificationsPlugin();
  }

  // 获取初始化状态
  bool get initialized => _initialized ?? false;

  // 初始化通知栏消息
  Future<bool?> initNotification(String icon) async {
    final settings = InitializationSettings(
      android: AndroidInitializationSettings(icon),
      iOS: DarwinInitializationSettings(
        onDidReceiveLocalNotification: _onReceiveNotification,
      ),
    );
    return _initialized = await _localNotification?.initialize(settings);
  }

  // 显示进度通知
  Future<void> showProgress({
    required int maxProgress,
    required int progress,
    required bool indeterminate,
    // 基础参数
    required int id,
    String? title,
    String? body,
    String? payload,
  }) {
    if (null == body && !indeterminate) {
      double ratio = (progress / maxProgress.toDouble()) * 100;
      body = '${ratio.toStringAsFixed(1)}%';
    }
    return show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      androidConfig: AndroidNotificationConfig(
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        indeterminate: indeterminate,
        playSound: false,
        enableLights: false,
        enableVibration: false,
        ongoing: true,
        onlyAlertOnce: true,
      ),
      iosConfig: const IOSNotificationConfig(
        presentSound: false,
        presentBadge: false,
      ),
    );
  }

  // 显示通知栏消息
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    AndroidNotificationConfig? androidConfig,
    IOSNotificationConfig? iosConfig,
  }) async {
    if (!initialized) _initialized = await initNotification(_defaultIconName);
    assert(
        initialized,
        '请在 android/app/src/main/res/drawable 目录下添加 ic_launcher 图片文件；'
        '或者调用 jNotificationManage.initNotification() 自行指定默认图标');
    // 申请ios权限
    if (Platform.isIOS) {
      final result = await _localNotification
          ?.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      if (result != null && !result) return;
    }
    androidConfig ??= const AndroidNotificationConfig();
    iosConfig ??= const IOSNotificationConfig();
    return _localNotification?.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidConfig.channelId ?? '$id',
          androidConfig.channelName ?? '$id',
          channelDescription: androidConfig.channelDescription ?? '$id',
          channelShowBadge: androidConfig.channelShowBadge,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: androidConfig.when != null,
          when: androidConfig.when?.inMilliseconds ?? 0,
          icon: androidConfig.icon,
          playSound: androidConfig.playSound,
          enableVibration: androidConfig.enableVibration,
          groupKey: androidConfig.groupKey,
          setAsGroupSummary: androidConfig.setAsGroupSummary,
          autoCancel: androidConfig.autoCancel,
          ongoing: androidConfig.ongoing,
          onlyAlertOnce: androidConfig.onlyAlertOnce,
          enableLights: androidConfig.enableLights,
          timeoutAfter: androidConfig.timeoutAfter?.inMilliseconds,
          showProgress: androidConfig.showProgress,
          maxProgress: androidConfig.maxProgress,
          progress: androidConfig.progress,
          indeterminate: androidConfig.indeterminate,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: iosConfig.presentAlert,
          presentBadge: iosConfig.presentBadge,
          presentSound: iosConfig.presentSound,
          sound: iosConfig.sound,
          badgeNumber: iosConfig.badgeNumber,
          subtitle: iosConfig.subtitle,
          threadIdentifier: iosConfig.threadIdentifier,
        ),
      ),
      payload: payload,
    );
  }

  // 取消通知
  Future<void>? cancel(int id, {String? tag}) =>
      _localNotification?.cancel(id, tag: tag);

  // 取消所有通知
  Future<void>? cancelAll() => _localNotification?.cancelAll();

  // 添加接受消息监听
  void addReceiveListener(OnNotificationReceive listener) =>
      _notificationReceiveListeners.add(listener);

  // 当接收到通知消息回调
  Future _onReceiveNotification(
      int id, String? title, String? body, String? payload) async {
    for (final item in _notificationReceiveListeners) {
      await item(id, title, body, payload);
    }
  }
}

// 单例调用
final notice = NotificationManage();

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
