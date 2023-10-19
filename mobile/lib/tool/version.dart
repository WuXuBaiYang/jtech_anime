import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:mobile/manage/notification.dart';
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
      const PermissionRequest.notification(),
      const PermissionRequest.androidManageExternalStorage(),
      const PermissionRequest.androidRequestInstallPackages(),
    ]).then((result) {
      if (!result) return SnackTool.showMessage(message: '未能获取到权限');
      SnackTool.showMessage(message: '正在下载安装包...');
      _installAndroidApk(context, info);
    });
  }

  // 下载并安装apk
  Future<void> _installAndroidApk(BuildContext context, AppVersion info) async {
    const noticeTag = 9527;
    try {
      // 创建缓存路径
      final baseDir = await getDownloadsDirectory();
      if (baseDir == null) return;
      final saveDir = Directory(join(baseDir.path, 'jtech_anime', 'updates'));
      if (!saveDir.existsSync()) saveDir.createSync(recursive: true);
      // 启动下载
      _showProgressNotice(-1, info.fileLength, noticeTag);
      final downloadFilePath = await downloadUpdateFile(
        info,
        saveDir: saveDir.path,
        onReceiveProgress: (count, total) {
          _showProgressNotice(count, total, noticeTag);
        },
      );
      if (downloadFilePath == null) return;
      // 下载成功后启动安装apk
      InstallPlugin.installApk(downloadFilePath);
      SnackTool.showMessage(message: '正在启动安装...');
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
    } finally {
      notice.cancel(noticeTag);
    }
  }

  // 展示进度通知
  Future<void> _showProgressNotice(int count, int total, [int noticeTag = -1]) {
    count = ((count / total) * 100).toInt();
    return notice.showProgress(
      indeterminate: count <= 0,
      maxProgress: 100,
      progress: count,
      id: noticeTag,
    );
  }

  // 更新ios平台
  Future<void> _upgradeIosPlatform(
      BuildContext context, AppVersion info) async {
    /// TODO 跳转苹果商店实现更新
  }
}
