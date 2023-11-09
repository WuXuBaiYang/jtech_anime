import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

// 回调请求失败的请求
typedef OnPermissionCheckFail = void Function(
    List<PermissionResult> failRequests);

/*
* 权限管理工具方法
* @author wuxubaiyang
* @Time 2022/3/18 13:48
*/
class PermissionTool {
  // 检查集合中的权限是否全部通过
  static Future<bool> checkAllGranted(BuildContext context,
      {required List<PermissionRequest> permissions,
      OnPermissionCheckFail? onCheckFail}) async {
    final failResults = <PermissionResult>[];
    for (final item in permissions) {
      if (await item.isGranted) continue;
      final result = await item.request();
      if (!result.isGranted) failResults.add(result);
    }
    if (failResults.isNotEmpty) {
      onCheckFail?.call(failResults);
    }
    return failResults.isEmpty;
  }

  // 检查日历权限
  static Future<bool> checkCalendar(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.calendar(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查摄像头权限
  static Future<bool> checkCamera(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.camera(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查通讯录权限
  static Future<bool> checkContacts(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.contacts(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查定位权限
  static Future<bool> checkLocation(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.location(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查麦克风权限
  static Future<bool> checkMicrophone(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.microphone(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查传感器权限
  static Future<bool> checkSensors(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.sensors(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查麦克风权限
  static Future<bool> checkSpeech(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.speech(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查存储权限
  static Future<bool> checkStorage(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.storage(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查通知权限
  static Future<bool> checkNotification(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.notification(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查蓝牙权限
  static Future<bool> checkBluetooth(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.bluetooth(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查ios媒体库权限
  static Future<bool> checkIosMediaLibrary(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.iosMediaLibrary(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查ios图片库权限
  static Future<bool> checkIosPhotos(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.iosPhotos(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查ios提醒事项权限
  static Future<bool> checkIosReminders(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.iosReminders(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查android外部存储权限
  static Future<bool> checkAndroidManageExternalStorage(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.androidManageExternalStorage(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查android系统通知权限
  static Future<bool> checkAndroidSystemAlertWindow(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.androidSystemAlertWindow(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查android安装包权限
  static Future<bool> checkAndroidRequestInstallPackages(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.androidRequestInstallPackages(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查android短信权限
  static Future<bool> checkAndroidSms(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.androidSms(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );

  // 检查android拨打电话权限
  static Future<bool> checkAndroidPhone(
    BuildContext context, {
    OnPermissionCheckFail? onCheckFail,
    String? requestMessage,
    String? requestFail,
  }) =>
      checkAllGranted(
        context,
        permissions: [
          PermissionRequest.androidPhone(
            requestMessage: requestMessage,
            requestFail: requestFail,
          )
        ],
        onCheckFail: onCheckFail,
      );
}

/*
* 权限请求实体
* @author wuxubaiyang
* @Time 2022/3/18 13:49
*/
class PermissionRequest {
  // 要申请的权限
  final Permission _permission;

  // 权限申请描述
  final String requestMessage;

  // 权限申请失败提示
  final String requestFail;

  // 请求权限
  Future<PermissionResult> request() async {
    final status = await _permission.request();
    return PermissionResult.from(status,
        message: !status.isGranted ? requestFail : '');
  }

  // 判断是否有权限
  Future<bool> get isGranted => _permission.isGranted;

  // 日历权限
  const PermissionRequest.calendar({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.calendar,
        requestMessage = requestMessage ?? '请求日历权限',
        requestFail = requestFail ?? '日历权限请求失败';

  // 摄像头权限
  const PermissionRequest.camera({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.camera,
        requestMessage = requestMessage ?? '请求摄像头权限',
        requestFail = requestFail ?? '摄像头权限请求失败';

  // 请求通讯录权限
  const PermissionRequest.contacts({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.contacts,
        requestMessage = requestMessage ?? '请求通讯录权限',
        requestFail = requestFail ?? '通讯录权限请求失败';

  // 请求定位权限(locationAlways、locationWhenInUse)
  const PermissionRequest.location({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.location,
        requestMessage = requestMessage ?? '请求定位权限',
        requestFail = requestFail ?? '定位权限请求失败';

  // 请求麦克风权限
  const PermissionRequest.microphone({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.microphone,
        requestMessage = requestMessage ?? '请求麦克风权限',
        requestFail = requestFail ?? '麦克风权限请求失败';

  // 请求传感器权限
  const PermissionRequest.sensors({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.sensors,
        requestMessage = requestMessage ?? '请求传感器权限',
        requestFail = requestFail ?? '传感器权限请求失败';

  // 请求麦克风权限
  const PermissionRequest.speech({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.speech,
        requestMessage = requestMessage ?? '请求麦克风权限',
        requestFail = requestFail ?? '麦克风权限请求失败';

  // 请求存储权限
  const PermissionRequest.storage({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.storage,
        requestMessage = requestMessage ?? '请求存储权限',
        requestFail = requestFail ?? '存储权限请求失败';

  // 请求通知权限
  const PermissionRequest.notification({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.notification,
        requestMessage = requestMessage ?? '请求通知权限',
        requestFail = requestFail ?? '通知权限请求失败';

  // 请求通知权限
  const PermissionRequest.accessNotificationPolicy({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.accessNotificationPolicy,
        requestMessage = requestMessage ?? '允许开关通知权限',
        requestFail = requestFail ?? '允许开关通知权限';

  // 请求蓝牙权限
  const PermissionRequest.bluetooth({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.bluetooth,
        requestMessage = requestMessage ?? '请求蓝牙权限',
        requestFail = requestFail ?? '蓝牙权限请求失败';

  // 请求媒体库权限
  const PermissionRequest.iosMediaLibrary({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.mediaLibrary,
        requestMessage = requestMessage ?? '请求媒体库权限',
        requestFail = requestFail ?? '媒体库权限请求失败';

  // 请求图片库权限
  const PermissionRequest.iosPhotos({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.photos,
        requestMessage = requestMessage ?? '请求图片库权限',
        requestFail = requestFail ?? '图片库权限请求失败';

  // 请求提醒事项权限
  const PermissionRequest.iosReminders({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.reminders,
        requestMessage = requestMessage ?? '请求提醒事项权限',
        requestFail = requestFail ?? '提醒事项权限请求失败';

  // 请求外部存储权限
  const PermissionRequest.androidManageExternalStorage({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.manageExternalStorage,
        requestMessage = requestMessage ?? '请求外部存储权限',
        requestFail = requestFail ?? '外部存储权限请求失败';

  // 请求系统通知权限
  const PermissionRequest.androidSystemAlertWindow({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.systemAlertWindow,
        requestMessage = requestMessage ?? '请求系统通知权限',
        requestFail = requestFail ?? '系统通知权限请求失败';

  // 请求安装包权限
  const PermissionRequest.androidRequestInstallPackages({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.requestInstallPackages,
        requestMessage = requestMessage ?? '请求安装包权限',
        requestFail = requestFail ?? '安装包权限请求失败';

  // 请求短信权限
  const PermissionRequest.androidSms({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.sms,
        requestMessage = requestMessage ?? '请求短信权限',
        requestFail = requestFail ?? '短信权限请求失败';

  // 请求拨打电话权限
  const PermissionRequest.androidPhone({
    String? requestMessage,
    String? requestFail,
  })  : _permission = Permission.phone,
        requestMessage = requestMessage ?? '请求拨打电话权限',
        requestFail = requestFail ?? '拨打电话权限请求失败';
}

/*
* 权限请求结果
* @author wuxubaiyang
* @Time 2022/3/18 13:49
*/
class PermissionResult {
  // 存储权限申请结果
  final PermissionStatus _status;

  // 提示消息
  final String message;

  const PermissionResult.from(
    PermissionStatus status, {
    this.message = '',
  }) : _status = status;

  // 判断是否通过
  bool get isGranted => _status.isGranted;

  // 判断是否失败
  bool get isDenied => _status.isDenied;
}
