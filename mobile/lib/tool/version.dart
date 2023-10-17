import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:mobile/manage/notification.dart';
import 'package:ota_update/ota_update.dart';
import 'permission.dart';

class AppVersionTool extends AppVersionToolBase {
  @override
  Future<void> upgradePlatform(BuildContext context, AppVersion info) async {
    if (Platform.isAndroid) _upgradeAndroidPlatform(context, info);
    if (Platform.isIOS) _upgradeIosPlatform(context, info);
  }

  // 更新android平台
  Future<void> _upgradeAndroidPlatform(
      BuildContext context, AppVersion info) async {
    PermissionTool.checkAllGranted(context, permissions: [
      const PermissionRequest.androidManageExternalStorage(),
      const PermissionRequest.androidRequestInstallPackages(),
    ]).then((result) {
      if (!result) return SnackTool.showMessage(message: '未能获取到权限');
      SnackTool.showMessage(message: '正在下载安装包...');
      _installAndroidApk(context, info);
    });
  }

  // 更新ios平台
  Future<void> _upgradeIosPlatform(
      BuildContext context, AppVersion info) async {
    /// TODO 跳转苹果商店实现更新
  }

  // 下载并安装apk
  static Future<void> _installAndroidApk(
      BuildContext context, AppVersion info) async {
    final progress = ValueChangeNotifier<int?>(null);
    const noticeTag = 9527;
    progress.addListener(() async {
      final v = progress.value;
      if (v == null) return notice.cancel(noticeTag);
      notice.showProgress(
        indeterminate: v < 0,
        maxProgress: 100,
        progress: v,
        id: noticeTag,
      );
    });
    progress.setValue(-1);
    try {
      OtaUpdate()
          .execute(info.installUrl,
              destinationFilename: '${info.name}_${info.versionCode}.apk',
              sha256checksum: info.sha256checksum)
          .listen((e) {
        switch (e.status) {
          case OtaStatus.DOWNLOADING:
            return progress.setValue(int.parse(e.value ?? '0'));
          case OtaStatus.INSTALLING:
          case OtaStatus.ALREADY_RUNNING_ERROR:
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
          case OtaStatus.INTERNAL_ERROR:
          case OtaStatus.DOWNLOAD_ERROR:
          case OtaStatus.CHECKSUM_ERROR:
            return progress.setValue(null);
        }
      });
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
      progress.setValue(null);
    }
  }
}
