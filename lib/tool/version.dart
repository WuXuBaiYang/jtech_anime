import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/notification.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/supabase.dart';
import 'package:jtech_anime/model/version.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/message_dialog.dart';
import 'package:ota_update/ota_update.dart';
import 'log.dart';
import 'permission.dart';

/*
* 应用版本检查
* @author wuxubaiyang
* @Time 2023/3/9 17:57
*/
class AppVersionTool {
  // 更新提示忽略缓存key
  static const String _ignoreUpdateKey = 'ignore_update_key';

  // 检查更新
  static Future<bool> check(BuildContext context,
      {bool immediately = false}) async {
    // 开源版本不公开supabase服务，如果想实现版本更新请接入自己的服务
    if (!supabase.hasSupabaseInfo) return false;
    // 判断是否需要进行版本更新
    if (!immediately && (cache.getBool(_ignoreUpdateKey) ?? false)) {
      return false;
    }
    if (Platform.isAndroid) return _checkAndroidUpdate(context);
    if (Platform.isIOS) return _checkIosUpdate(context);
    return false;
  }

  // 检查android的版本更新
  static Future<bool> _checkAndroidUpdate(BuildContext context) {
    // 获取最新版本号并判断是否需要更新
    return supabase.getLatestAppVersion().then<bool?>((info) {
      return info?.checkUpdate().then((update) {
        if (update) return _showAndroidUpdateDialog(context, info);
        return Future.value(update);
      });
    }).then<bool>((update) => update ?? false);
  }

  // 展示版本更新提示
  static Future<bool?> _showAndroidUpdateDialog(
      BuildContext context, AppVersion info) {
    return MessageDialog.show(
      context,
      title: const Text('应用更新'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info.intro.replaceAll('\\n', '\n')),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),
          Text(
            '${info.nameCN} · v${info.version} · ${info.fileSize}',
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          )
        ],
      ),
      actionLeft: TextButton(
        onPressed: () {
          cache.setBool(_ignoreUpdateKey, true,
              expiration: const Duration(days: 7));
          router.pop();
        },
        child: const Text('一周内不提示'),
      ),
      actionMiddle: TextButton(
        onPressed: () => router.pop(),
        child: const Text('取消'),
      ),
      actionRight: TextButton(
        onPressed: () {
          PermissionTool.checkAllGranted(context, permissions: [
            const PermissionRequest.storage(),
            const PermissionRequest.androidManageExternalStorage(),
            const PermissionRequest.androidRequestInstallPackages(),
          ]).then((v) {
            if (!v) return SnackTool.showMessage(context, message: '未能获取到权限');
            Navigator.pop(context, true);
            _installAndroidApk(context, info);
            SnackTool.showMessage(context, message: '正在下载安装包...');
          });
        },
        child: const Text('更新'),
      ),
    );
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
          .execute(
        await supabase.getAndroidAPKUrl(info.fileId),
        destinationFilename: '${info.name}_${info.versionCode}.apk',
        sha256checksum: info.sha256checksum,
      )
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

  // 检查ios版本更新
  static Future<bool> _checkIosUpdate(BuildContext context) {
    return Future.value(false);
  }
}
